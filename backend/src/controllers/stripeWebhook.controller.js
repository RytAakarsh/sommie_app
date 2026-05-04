// // backend/src/controllers/stripeWebhook.controller.js
// import Stripe from 'stripe';
// import { dynamo } from '../config/dynamo.js';
// import { PutCommand, GetCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';

// // Initialize Stripe with proper error handling
// if (!process.env.STRIPE_SECRET_KEY) {
//   console.error('❌ STRIPE_SECRET_KEY is not set');
//   throw new Error('STRIPE_SECRET_KEY is required');
// }

// const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
//   apiVersion: '2025-02-24.acacia',
// });

// const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;
// const PROFILES_TABLE = process.env.DYNAMO_PROFILES_TABLE || "SommieProfiles";
// const PAYMENTS_TABLE = process.env.DYNAMO_PAYMENTS_TABLE || "SommiePayments";

// export const stripeWebhook = async (req, res) => {
//   const sig = req.headers['stripe-signature'];
//   const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

//   if (!endpointSecret) {
//     console.error('❌ STRIPE_WEBHOOK_SECRET is not set');
//     return res.status(500).json({ error: 'Webhook secret not configured' });
//   }

//   let event;

//   try {
//     // Get raw body
//     const rawBody = req.rawBody || req.body;
    
//     let rawBodyString;
//     if (typeof rawBody === 'string') {
//       rawBodyString = rawBody;
//     } else if (Buffer.isBuffer(rawBody)) {
//       rawBodyString = rawBody.toString();
//     } else {
//       rawBodyString = JSON.stringify(rawBody);
//     }
    
//     event = stripe.webhooks.constructEvent(rawBodyString, sig, endpointSecret);
//     console.log('✅ Webhook signature verified');
//   } catch (err) {
//     console.error('❌ Webhook signature verification failed:', err.message);
//     return res.status(400).send(`Webhook Error: ${err.message}`);
//   }

//   console.log(`📦 Webhook event received: ${event.type}`);

//   try {
//     if (event.type === 'payment_intent.succeeded') {
//       const paymentIntent = event.data.object;
//       const { userId, planId } = paymentIntent.metadata || {};

//       console.log(`💰 PaymentIntent succeeded: ${paymentIntent.id}`);
//       console.log(`   User: ${userId}, Plan: ${planId}, Amount: ${paymentIntent.amount / 100} ${paymentIntent.currency}`);

//       if (!userId || !planId) {
//         console.log('⚠️ Missing metadata in payment intent');
//         return res.json({ received: true });
//       }

//       // Validate userId is not 'guest'
//       if (userId === 'guest') {
//         console.error('❌ Invalid userId: guest');
//         return res.json({ received: true });
//       }

//       // ✅ FIXED: Check if payment already processed using userId (matches table schema)
//       const existingPayment = await dynamo.send(
//         new GetCommand({
//           TableName: PAYMENTS_TABLE,
//           Key: { userId: userId },
//         })
//       );

//       if (existingPayment.Item && existingPayment.Item.paymentIntentId === paymentIntent.id) {
//         console.log(`⚠️ Payment ${paymentIntent.id} already processed, skipping`);
//         return res.json({ received: true });
//       }

//       // ✅ FIXED: Save payment using userId as PK
//       await dynamo.send(
//         new PutCommand({
//           TableName: PAYMENTS_TABLE,
//           Item: {
//             userId: userId,
//             paymentIntentId: paymentIntent.id,
//             planId: planId,
//             amount: paymentIntent.amount / 100,
//             originalAmount: paymentIntent.metadata?.originalAmount ? parseInt(paymentIntent.metadata.originalAmount) / 100 : null,
//             discountedAmount: paymentIntent.metadata?.discountedAmount ? parseInt(paymentIntent.metadata.discountedAmount) / 100 : null,
//             currency: paymentIntent.currency,
//             status: 'succeeded',
//             createdAt: new Date().toISOString(),
//             metadata: paymentIntent.metadata,
//           },
//         })
//       );

//       console.log(`✅ Payment saved for user ${userId}`);

//       // ✅ CRITICAL: UPGRADE USER AUTOMATICALLY VIA WEBHOOK
//       console.log(`🔄 Upgrading user ${userId} to PRO...`);

//       try {
//         // Update users table
//         await dynamo.send(
//           new UpdateCommand({
//             TableName: USERS_TABLE,
//             Key: { userId },
//             UpdateExpression: "SET #p = :p, subscriptionId = :subscriptionId, subscriptionDate = :date, updatedAt = :date",
//             ExpressionAttributeNames: {
//               "#p": "plan",
//             },
//             ExpressionAttributeValues: {
//               ":p": "PRO",
//               ":subscriptionId": paymentIntent.id,
//               ":date": new Date().toISOString(),
//             },
//             ConditionExpression: "attribute_exists(userId)",
//           })
//         );

//         // Update profile table
//         try {
//           await dynamo.send(
//             new UpdateCommand({
//               TableName: PROFILES_TABLE,
//               Key: { userId },
//               UpdateExpression: "SET #p = :p, updatedAt = :date",
//               ExpressionAttributeNames: {
//                 "#p": "plan",
//               },
//               ExpressionAttributeValues: {
//                 ":p": "PRO",
//                 ":date": new Date().toISOString(),
//               },
//             })
//           );
//         } catch (profileError) {
//           // Profile might not exist, create it
//           console.log(`Creating profile for user ${userId}`);
//           await dynamo.send(
//             new PutCommand({
//               TableName: PROFILES_TABLE,
//               Item: {
//                 userId: userId,
//                 plan: "PRO",
//                 updatedAt: new Date().toISOString(),
//                 createdAt: new Date().toISOString(),
//               },
//             })
//           );
//         }

//         console.log(`✅ User ${userId} upgraded to PRO via webhook`);
//       } catch (upgradeError) {
//         console.error(`❌ Failed to upgrade user ${userId}:`, upgradeError);
//         // Don't fail the webhook - payment is still saved
//       }

//     } 
//     else if (event.type === 'payment_intent.payment_failed') {
//       const paymentIntent = event.data.object;
//       const { userId } = paymentIntent.metadata || {};
      
//       console.log(`❌ Payment failed for user ${userId || 'unknown'}: ${paymentIntent.id}`);
//       console.log(`   Error: ${paymentIntent.last_payment_error?.message}`);
      
//       // ✅ FIXED: Save failed payment using userId as PK
//       await dynamo.send(
//         new PutCommand({
//           TableName: PAYMENTS_TABLE,
//           Item: {
//             userId: userId || 'unknown',
//             paymentIntentId: paymentIntent.id,
//             planId: paymentIntent.metadata?.planId || 'unknown',
//             amount: paymentIntent.amount / 100,
//             currency: paymentIntent.currency,
//             status: 'failed',
//             error: paymentIntent.last_payment_error?.message,
//             createdAt: new Date().toISOString(),
//           },
//         })
//       );
//     } 
//     else {
//       console.log(`📦 Unhandled event type: ${event.type}`);
//     }

//     res.json({ received: true });
//   } catch (error) {
//     console.error('Error processing webhook:', error);
//     res.status(500).json({ error: 'Webhook handler failed' });
//   }
// };



import Stripe from 'stripe';
import { dynamo } from '../config/dynamo.js';
import { PutCommand, GetCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2025-02-24.acacia',
});

const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;
const PROFILES_TABLE = process.env.DYNAMO_PROFILES_TABLE || "SommieProfiles";
const PAYMENTS_TABLE = process.env.DYNAMO_PAYMENTS_TABLE || "SommiePaymentsNew";

export const stripeWebhook = async (req, res) => {
  console.log('🔥🔥🔥 WEBHOOK HIT! 🔥🔥🔥');
  console.log('📅 Time:', new Date().toISOString());
  
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  console.log('🔐 Webhook secret exists:', !!endpointSecret);
  console.log('📨 Signature present:', !!sig);

  if (!endpointSecret) {
    console.error('❌ STRIPE_WEBHOOK_SECRET is not set');
    return res.status(500).json({ error: 'Webhook secret not configured' });
  }

  let event;

  try {
    // ✅ CRITICAL FIX: Use req.body directly (raw buffer)
    // DO NOT stringify or modify the body in any way
    event = stripe.webhooks.constructEvent(
      req.body,  // ← raw buffer directly from express.raw()
      sig,
      endpointSecret
    );
    console.log('✅ Webhook signature verified successfully!');
  } catch (err) {
    console.error('❌ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  console.log(`📦 Webhook event received: ${event.type}`);

  try {
    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object;
      const { userId, planId } = paymentIntent.metadata || {};

      console.log(`💰💰💰 PaymentIntent succeeded: ${paymentIntent.id}`);
      console.log(`👤 User: ${userId}`);
      console.log(`📋 Plan: ${planId}`);
      console.log(`💵 Amount: ${paymentIntent.amount / 100} ${paymentIntent.currency}`);

      if (!userId || !planId) {
        console.log('⚠️ Missing metadata in payment intent');
        return res.json({ received: true });
      }

      if (userId === 'guest') {
        console.error('❌ Invalid userId: guest');
        return res.json({ received: true });
      }

      // Check if already processed
      console.log(`🔍 Checking if payment already processed...`);
      const existingPayment = await dynamo.send(
        new GetCommand({
          TableName: PAYMENTS_TABLE,
          Key: { paymentIntentId: paymentIntent.id },
        })
      );

      if (existingPayment.Item) {
        console.log(`⚠️ Payment ${paymentIntent.id} already processed, skipping`);
        return res.json({ received: true });
      }

      // Save payment
      console.log(`💾 Saving payment to DynamoDB...`);
      await dynamo.send(
        new PutCommand({
          TableName: PAYMENTS_TABLE,
          Item: {
            paymentIntentId: paymentIntent.id,
            userId: userId,
            planId: planId,
            amount: paymentIntent.amount,
            currency: paymentIntent.currency,
            status: 'succeeded',
            createdAt: new Date().toISOString(),
          },
        })
      );
      console.log(`✅ Payment saved for user ${userId}`);

      // Upgrade user
      console.log(`🔄 Upgrading user ${userId} to PRO...`);

      // Update users table
      const updateResult = await dynamo.send(
        new UpdateCommand({
          TableName: USERS_TABLE,
          Key: { userId },
          UpdateExpression: "SET #p = :p, subscriptionId = :subscriptionId, subscriptionDate = :date, updatedAt = :date",
          ExpressionAttributeNames: { "#p": "plan" },
          ExpressionAttributeValues: {
            ":p": "PRO",
            ":subscriptionId": paymentIntent.id,
            ":date": new Date().toISOString(),
          },
          ConditionExpression: "attribute_exists(userId)",
          ReturnValues: "ALL_NEW",
        })
      );
      console.log(`✅ Users table updated for ${userId}`);

      // Update or create profile table
      try {
        await dynamo.send(
          new UpdateCommand({
            TableName: PROFILES_TABLE,
            Key: { userId },
            UpdateExpression: "SET #p = :p, updatedAt = :date",
            ExpressionAttributeNames: { "#p": "plan" },
            ExpressionAttributeValues: {
              ":p": "PRO",
              ":date": new Date().toISOString(),
            },
          })
        );
        console.log(`✅ Profile table updated for ${userId}`);
      } catch (profileError) {
        console.log(`📝 Profile not found, creating...`);
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
        console.log(`✅ Profile created for ${userId}`);
      }

      console.log(`🎉🎉🎉 User ${userId} successfully upgraded to PRO via webhook! 🎉🎉🎉`);
    } 
    else if (event.type === 'payment_intent.payment_failed') {
      const paymentIntent = event.data.object;
      const { userId } = paymentIntent.metadata || {};
      
      console.log(`❌ Payment failed for user ${userId || 'unknown'}: ${paymentIntent.id}`);
      
      await dynamo.send(
        new PutCommand({
          TableName: PAYMENTS_TABLE,
          Item: {
            paymentIntentId: paymentIntent.id,
            userId: userId || 'unknown',
            planId: paymentIntent.metadata?.planId || 'unknown',
            amount: paymentIntent.amount,
            currency: paymentIntent.currency,
            status: 'failed',
            error: paymentIntent.last_payment_error?.message,
            createdAt: new Date().toISOString(),
          },
        })
      );
    }
    else {
      console.log(`📦 Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('❌ Error processing webhook:', error);
    console.error('📚 Error stack:', error.stack);
    res.status(500).json({ error: 'Webhook handler failed' });
  }
};