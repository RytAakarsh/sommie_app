import crypto from "crypto";

// ⚠️ In production, replace with Redis
const sessions = new Map();

/**
 * Create a new mobile session token
 * @param {string} userId - User ID from auth
 * @returns {string} - 32-byte hex token
 */
export function createSession(userId) {
  const token = crypto.randomBytes(32).toString("hex");
  
  sessions.set(token, {
    userId,
    expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
    createdAt: new Date().toISOString(),
  });
  
  // Clean up expired sessions periodically
  setTimeout(() => {
    for (const [key, value] of sessions.entries()) {
      if (Date.now() > value.expiresAt) {
        sessions.delete(key);
      }
    }
  }, 60000); // Clean every minute
  
  return token;
}

/**
 * Get session by token
 * @param {string} token - Session token
 * @returns {object|null} - Session object or null
 */
export function getSession(token) {
  const session = sessions.get(token);
  
  if (!session) return null;
  
  // Check expiration
  if (Date.now() > session.expiresAt) {
    sessions.delete(token);
    return null;
  }
  
  return session;
}

/**
 * Delete session
 * @param {string} token - Session token
 */
export function deleteSession(token) {
  sessions.delete(token);
}