import express from "express";
import {
  sendVerificationOTP,
  verifyEmailOTP,
  resendVerificationOTP,
} from "../controllers/auth.controller.js";

const router = express.Router();

router.post("/send-otp", sendVerificationOTP);
router.post("/verify-otp", verifyEmailOTP);
router.post("/resend-otp", resendVerificationOTP);

export default router;