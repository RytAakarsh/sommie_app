import express from "express";
import Stripe from "stripe";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = express.Router();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2025-02-24.acacia',
});

const VALID_AMOUNTS = {
  monthly: 100,  // $1.00 in cents
  annual: 1000,  // $10.00 in cents
};

router.post("/create-payment-intent", authMiddleware, async (req, res) => {
  try {
    const { amount, currency, planId, userId, userEmail, userName } = req.body;

    console.log("📦 Creating payment intent:", { amount, planId, userId });

    // Validate inputs
    if (!amount || !currency || !planId || !userId || !userEmail) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    if (userId === 'guest') {
      console.error('❌ Invalid userId: guest');
      return res.status(401).json({
        success: false,
        message: 'User not authenticated'
      });
    }

    const expectedAmount = VALID_AMOUNTS[planId];
    if (!expectedAmount) {
      return res.status(400).json({
        success: false,
        message: 'Invalid plan'
      });
    }

    if (amount <= 0 || amount > expectedAmount) {
      console.error(`Invalid amount: ${amount}. Expected between 1 and ${expectedAmount}`);
      return res.status(400).json({
        success: false,
        message: 'Invalid payment amount'
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      automatic_payment_methods: { enabled: true },
      metadata: {
        userId: userId,
        planId: planId,
        email: userEmail,
        name: userName || '',
      },
      receipt_email: userEmail,
    });

    console.log("✅ Payment intent created:", paymentIntent.id);

    res.json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error('❌ Error creating payment intent:', error);
    res.status(500).json({
      success: false,
      message: error instanceof Error ? error.message : 'Internal server error'
    });
  }
});

export default router;