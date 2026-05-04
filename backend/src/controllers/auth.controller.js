
import bcrypt from "bcryptjs";
import { v4 as uuidv4 } from "uuid";
import { PutCommand, QueryCommand, UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
import { dynamo } from "../config/dynamo.js";
import { generateToken } from "../config/jwt.js";
import { sendEmail } from "../config/ses.js";
import { generateOTP, storeOTP, verifyOTP } from "../services/otp.service.js";

const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;

/* ================= SEND VERIFICATION OTP ================= */
// backend/controllers/auth.controller.js (Updated sendVerificationOTP)

export const sendVerificationOTP = async (req, res) => {
  try {
    const { email, name, language } = req.body; // ✅ Accept language

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    // Find user by email using GSI
    const existingUser = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :e",
        ExpressionAttributeValues: {
          ":e": email,
        },
        Limit: 1,
      })
    );

    // Check if email already verified
    if (existingUser.Items?.length && existingUser.Items[0].emailVerified) {
      return res.status(400).json({
        success: false,
        message: "Email already verified",
      });
    }

    const otp = generateOTP();
    await storeOTP(email, otp, "email_verification");

    // Send email using SES with language
    const emailResult = await sendEmail(email, "verification", {
      otp,
      userName: name || (existingUser.Items?.[0]?.name) || "User",
      language: language || "en", // ✅ Pass language to SES
    });

    if (!emailResult.success) {
      return res.status(500).json({
        success: false,
        message: "Failed to send verification email",
        error: emailResult.error,
      });
    }

    res.json({
      success: true,
      message: "Verification code sent to your email",
    });
  } catch (error) {
    console.error("Send OTP error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send verification code",
      error: error.message,
    });
  }
};


/* ================= VERIFY EMAIL OTP ================= */
export const verifyEmailOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP are required",
      });
    }

    // First, find the user by email using the GSI
    const userResult = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :email",
        ExpressionAttributeValues: {
          ":email": email,
        },
        Limit: 1,
      })
    );

    const user = userResult.Items?.[0];

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Verify OTP
    const verification = await verifyOTP(email, otp, "email_verification");

    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.reason === "OTP expired" 
          ? "Verification code has expired. Please request a new one."
          : "Invalid verification code",
      });
    }

    // Update user's emailVerified status using userId as key
    const updateResult = await dynamo.send(
      new UpdateCommand({
        TableName: USERS_TABLE,
        Key: { userId: user.userId },
        UpdateExpression: "SET emailVerified = :verified, updatedAt = :date",
        ExpressionAttributeValues: {
          ":verified": true,
          ":date": new Date().toISOString(),
        },
        ReturnValues: "ALL_NEW",
      })
    );

    const updatedUser = updateResult.Attributes;

    // Generate token for the user
    const token = generateToken({
      userId: updatedUser.userId,
      email: updatedUser.email,
      plan: updatedUser.plan,
    });

    const userResponse = { ...updatedUser };
    delete userResponse.password;

    res.json({
      success: true,
      message: "Email verified successfully",
      token,
      user: userResponse,
    });
  } catch (error) {
    console.error("Verify OTP error:", error);
    
    if (error.name === "ConditionalCheckFailedException") {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to verify email",
      error: error.message,
    });
  }
};

/* ================= RESEND VERIFICATION OTP ================= */
/* ================= RESEND VERIFICATION OTP ================= */
export const resendVerificationOTP = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    // Find user by email using GSI
    const existingUser = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :e",
        ExpressionAttributeValues: {
          ":e": email,
        },
        Limit: 1,
      })
    );

    if (!existingUser.Items?.length) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (existingUser.Items[0].emailVerified) {
      return res.status(400).json({
        success: false,
        message: "Email already verified",
      });
    }

    const otp = generateOTP();
    await storeOTP(email, otp, "email_verification");

    const emailResult = await sendEmail(email, "verification", {
      otp,
      userName: existingUser.Items[0].name || "User",
    });

    if (!emailResult.success) {
      return res.status(500).json({
        success: false,
        message: "Failed to send verification email",
      });
    }

    res.json({
      success: true,
      message: "New verification code sent to your email",
    });
  } catch (error) {
    console.error("Resend OTP error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to resend verification code",
    });
  }
};
/* ================= SIGNUP (Modified for email verification) ================= */
export const signup = async (req, res) => {
  try {
    const { name, email, password, age, gender, phone, dob } = req.body;

    if (!name || !email || !password || !age || !gender) {
      return res.status(400).json({ 
        success: false,
        message: "Missing required fields" 
      });
    }

    // Check if user exists
    const existing = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :e",
        ExpressionAttributeValues: {
          ":e": email,
        },
        Limit: 1,
      })
    );

    if (existing.Items?.length) {
      return res.status(409).json({ 
        success: false,
        message: "Email already exists" 
      });
    }

    const userId = uuidv4();
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = {
      userId,
      name,
      email,
      password: hashedPassword,
      age: Number(age),
      gender: gender.toLowerCase(),
      plan: "FREE",
      emailVerified: false, // Changed to false - requires verification
      phone: phone || "",
      dob: dob || "",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    // Save user
    await dynamo.send(
      new PutCommand({
        TableName: USERS_TABLE,
        Item: user,
      })
    );

    // Generate and send OTP
    const otp = generateOTP();
    await storeOTP(email, otp, "email_verification");

    const emailResult = await sendEmail(email, "verification", {
      otp,
      userName: name,
    });

    if (!emailResult.success) {
      console.error("Failed to send welcome email:", emailResult.error);
      // Don't fail signup if email fails, but log it
    }

    // Prepare user response (without sensitive data)
    const userResponse = {
      userId: user.userId,
      name: user.name,
      email: user.email,
      plan: user.plan,
      emailVerified: false,
      age: user.age,
      gender: user.gender,
      createdAt: user.createdAt,
    };

    res.status(201).json({
      success: true,
      message: "Signup successful! Please verify your email with the code sent to your inbox.",
      requiresVerification: true,
      email: user.email,
      user: userResponse,
    });

  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ 
      success: false,
      message: "Signup failed" 
    });
  }
};

/* ================= LOGIN (Check verification status) ================= */
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ 
        success: false,
        message: "Email and password are required" 
      });
    }

    const result = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :e",
        ExpressionAttributeValues: {
          ":e": email,
        },
        Limit: 1,
      })
    );

    const user = result.Items?.[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Check if email is verified
    if (!user.emailVerified) {
      // Generate new OTP and send
      const otp = generateOTP();
      await storeOTP(email, otp, "email_verification");
      
      await sendEmail(email, "verification", {
        otp,
        userName: user.name,
      });

      return res.status(403).json({
        success: false,
        requiresVerification: true,
        message: "Please verify your email first. A new verification code has been sent to your email.",
        email: user.email,
      });
    }

    const token = generateToken({
      userId: user.userId,
      email: user.email,
      plan: user.plan,
    });

    const userResponse = { ...user };
    delete userResponse.password;

    res.json({
      success: true,
      message: "Login successful",
      token,
      user: userResponse,
    });

  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ 
      success: false,
      message: "Login failed",
      error: error.message 
    });
  }
};

/* ================= FORGOT PASSWORD ================= */
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    const result = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :e",
        ExpressionAttributeValues: {
          ":e": email,
        },
        Limit: 1,
      })
    );

    const user = result.Items?.[0];

    if (!user) {
      // Don't reveal that user doesn't exist for security
      return res.json({
        success: true,
        message: "If your email is registered, you will receive a password reset code.",
      });
    }

    const otp = generateOTP();
    await storeOTP(email, otp, "password_reset");

    const emailResult = await sendEmail(email, "passwordReset", {
      otp,
      userName: user.name,
    });

    if (!emailResult.success) {
      return res.status(500).json({
        success: false,
        message: "Failed to send reset email",
      });
    }

    res.json({
      success: true,
      message: "Password reset code sent to your email",
    });
  } catch (error) {
    console.error("Forgot password error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to process request",
    });
  }
};

// backend/controllers/auth.controller.js

/* ================= RESET PASSWORD ================= */
export const resetPassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body; // ✅ Removed OTP from here - already verified

    if (!email || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Email and new password are required",
      });
    }

    // Find user by email using GSI
    const userResult = await dynamo.send(
      new QueryCommand({
        TableName: USERS_TABLE,
        IndexName: "email-index",
        KeyConditionExpression: "email = :email",
        ExpressionAttributeValues: {
          ":email": email,
        },
        Limit: 1,
      })
    );

    const user = userResult.Items?.[0];

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Validate password strength
    const hasUpperCase = /[A-Z]/.test(newPassword);
    const hasNumber = /[0-9]/.test(newPassword);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(newPassword);
    
    if (newPassword.length < 8 || !hasUpperCase || !hasNumber || !hasSpecialChar) {
      return res.status(400).json({
        success: false,
        message: "Password must contain at least 8 characters, one uppercase letter, one number, and one special character",
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password using userId as PK
    await dynamo.send(
      new UpdateCommand({
        TableName: USERS_TABLE,
        Key: { userId: user.userId },
        UpdateExpression: "SET password = :password, updatedAt = :date",
        ExpressionAttributeValues: {
          ":password": hashedPassword,
          ":date": new Date().toISOString(),
        },
      })
    );

    res.json({
      success: true,
      message: "Password reset successful. You can now login with your new password.",
    });
  } catch (error) {
    console.error("Reset password error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to reset password",
      error: error.message,
    });
  }
};

/* ================= VERIFY RESET OTP ================= */
export const verifyResetOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP are required",
      });
    }

    // Verify OTP
    const verification = await verifyOTP(email, otp, "password_reset");

    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.reason === "OTP expired" 
          ? "Reset code has expired. Please request a new one."
          : "Invalid reset code",
      });
    }

    res.json({
      success: true,
      message: "OTP verified successfully",
    });
  } catch (error) {
    console.error("Verify reset OTP error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify OTP",
      error: error.message,
    });
  }
};

