import express from "express";
import {
  signup,
  login,
  forgotPassword,
} from "../controllers/auth.controller.js";

const router = express.Router();

// Signup
router.post("/signup", signup);

// Login
router.post("/login", login);

// Forgot Password (simple reset without OTP for now)
router.post("/forgot-password", forgotPassword);

export default router;


// import express from "express";
// import {
//   signup,
//   login,
//   verifySignupOtp,
//   forgotPassword,
//   verifyForgotPasswordOtp,
//   resetPassword,
//   resendOtp,
// } from "../controllers/auth.controller.js";

// const router = express.Router();

// // Signup
// router.post("/signup", signup);

// // Verify Signup OTP
// router.post("/verify-signup-otp", verifySignupOtp);

// // Login
// router.post("/login", login);

// // Forgot Password
// router.post("/forgot-password", forgotPassword);

// // Verify Forgot Password OTP
// router.post("/verify-forgot-password-otp", verifyForgotPasswordOtp);

// // Reset Password
// router.post("/reset-password", resetPassword);

// // Resend OTP
// router.post("/resend-otp", resendOtp);

// export default router;