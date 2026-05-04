import express from "express";
import {
  signup,
  login,
  forgotPassword,
   resetPassword,
  verifyResetOTP
} from "../controllers/auth.controller.js";

const router = express.Router();

// Signup
router.post("/signup", signup);

// Login
router.post("/login", login);

// Forgot Password (simple reset without OTP for now)
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.post("/verify-reset-otp", verifyResetOTP);

export default router;

