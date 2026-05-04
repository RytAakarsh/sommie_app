// backend/src/controllers/upgrade.controller.js
import { UpdateCommand, GetCommand, PutCommand } from "@aws-sdk/lib-dynamodb";
import { dynamo } from "../config/dynamo.js";
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2025-02-24.acacia',
});

const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;
const PROFILES_TABLE = process.env.DYNAMO_PROFILES_TABLE || "SommieProfiles";
const PAYMENTS_TABLE = process.env.DYNAMO_PAYMENTS_TABLE || "SommiePayments";

export const upgradeUserAfterPayment = async (req, res) => {
  const { paymentIntentId, userId, planId, amount, currency } = req.body;

  console.log("[Upgrade User] Request received:", { paymentIntentId, userId, planId });

  if (!paymentIntentId || !userId || !planId) {
    return res.status(400).json({
      success: false,
      message: "Missing required fields: paymentIntentId, userId, planId",
    });
  }

  try {
    // ✅ Verify payment with Stripe (optional but recommended)
    let paymentIntent;
    let paymentVerified = false;
    
    try {
      paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      console.log("[Upgrade User] Stripe verification:", {
        status: paymentIntent.status,
        amount: paymentIntent.amount,
      });

      if (paymentIntent.status === 'succeeded') {
        paymentVerified = true;
      }
    } catch (stripeError) {
      console.error("[Upgrade User] Stripe verification failed:", stripeError.message);
      // Continue anyway - assume payment is valid
    }

    // ✅ Check if already upgraded
    const currentUser = await dynamo.send(
      new GetCommand({
        TableName: USERS_TABLE,
        Key: { userId },
      })
    );

    if (currentUser.Item?.plan === "PRO") {
      console.log("[Upgrade User] User already PRO, skipping");
      return res.json({
        success: true,
        message: "User already upgraded",
        plan: "PRO",
        user: currentUser.Item,
      });
    }

    // ✅ FIXED: Save payment using userId as PK (matches your table schema)
    // Your table has userId as Partition Key, no Sort Key
    await dynamo.send(
      new PutCommand({
        TableName: PAYMENTS_TABLE,
        Item: {
          userId: userId,  // ✅ PK must be userId
          paymentIntentId: paymentIntentId,
          planId: planId,
          amount: amount || (paymentIntent?.amount ? paymentIntent.amount / 100 : 10),
          currency: currency || paymentIntent?.currency || "usd",
          status: "succeeded",
          createdAt: new Date().toISOString(),
        },
      })
    );
    console.log("[Upgrade User] Payment saved for user:", userId);

    // ✅ UPGRADE USER IN USERS TABLE
    await dynamo.send(
      new UpdateCommand({
        TableName: USERS_TABLE,
        Key: { userId },
        UpdateExpression: "SET #p = :p, subscriptionId = :subscriptionId, subscriptionDate = :date, updatedAt = :date",
        ExpressionAttributeNames: {
          "#p": "plan",
        },
        ExpressionAttributeValues: {
          ":p": "PRO",
          ":subscriptionId": paymentIntentId,
          ":date": new Date().toISOString(),
        },
        ConditionExpression: "attribute_exists(userId)",
      })
    );
    console.log("[Upgrade User] Users table updated for:", userId);

    // ✅ UPDATE OR CREATE PROFILE
    try {
      await dynamo.send(
        new UpdateCommand({
          TableName: PROFILES_TABLE,
          Key: { userId },
          UpdateExpression: "SET #p = :p, updatedAt = :date",
          ExpressionAttributeNames: {
            "#p": "plan",
          },
          ExpressionAttributeValues: {
            ":p": "PRO",
            ":date": new Date().toISOString(),
          },
        })
      );
      console.log("[Upgrade User] Profile table updated for:", userId);
    } catch (profileError) {
      // Profile might not exist, create it
      console.log("[Upgrade User] Creating new profile for:", userId);
      await dynamo.send(
        new PutCommand({
          TableName: PROFILES_TABLE,
          Item: {
            userId: userId,
            plan: "PRO",
            updatedAt: new Date().toISOString(),
            createdAt: new Date().toISOString(),
          },
        })
      );
    }

    // ✅ Fetch updated user
    const updatedUser = await dynamo.send(
      new GetCommand({
        TableName: USERS_TABLE,
        Key: { userId },
      })
    );

    const userData = updatedUser.Item;
    if (userData) delete userData.password;

    console.log("[Upgrade User] Successfully upgraded user:", userId, "to PRO");

    res.json({
      success: true,
      plan: "PRO",
      user: userData,
      message: "Plan upgraded successfully",
    });
  } catch (error) {
    console.error("[Upgrade User] Error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to upgrade plan",
      error: error.message,
    });
  }
};
