import express from "express";
import { createCheckoutSession, validateSession } from "../controllers/mobile.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = express.Router();

// ✅ Protected route - user must be logged in
router.post(
  "/create-checkout-session",
  authMiddleware,
  createCheckoutSession
);

// ✅ Public route - no auth required (called from website)
router.post(
  "/validate-session",
  validateSession
);

export default router;