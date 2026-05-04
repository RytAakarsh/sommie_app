import { createSession, getSession } from "../utils/mobileSessionStore.js";

/**
 * Create checkout session for mobile app
 * POST /api/mobile/create-checkout-session
 * Requires: Auth token in headers
 */
export const createCheckoutSession = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?.userId;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "User not authenticated",
      });
    }
    
    const token = createSession(userId);
    
    console.log(`✅ Created mobile session for user: ${userId}`);
    
    return res.json({
      success: true,
      auth_token: token,
      expires_in: 300, // 5 minutes
    });
  } catch (err) {
    console.error("❌ Create checkout session error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to create session",
    });
  }
};

/**
 * Validate mobile session token
 * POST /api/mobile/validate-session
 * Public endpoint (no auth required)
 */
export const validateSession = async (req, res) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({
        success: false,
        message: "Token is required",
      });
    }
    
    const session = getSession(token);
    
    if (!session) {
      return res.status(401).json({
        success: false,
        message: "Invalid or expired token",
      });
    }
    
    console.log(`✅ Validated session for user: ${session.userId}`);
    
    return res.json({
      success: true,
      userId: session.userId,
    });
  } catch (err) {
    console.error("❌ Validate session error:", err);
    res.status(500).json({
      success: false,
      message: "Validation failed",
    });
  }
};