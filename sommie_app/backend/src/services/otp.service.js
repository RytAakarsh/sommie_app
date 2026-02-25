// import { dynamo } from "../config/dynamo.js";

// const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;

// /**
//  * Generate 6 digit OTP
//  */
// export const generateOTP = () => {
//   return Math.floor(100000 + Math.random() * 900000).toString();
// };

// /**
//  * Save OTP to user record
//  */
// export const saveOTP = async ({
//   userId,
//   purpose, // "signup" | "forgot_password"
// }) => {
//   const otp = generateOTP();
//   const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

//   await dynamo.update({
//     TableName: USERS_TABLE,
//     Key: { userId },
//     UpdateExpression: `
//       SET otpCode = :otp,
//           otpExpiresAt = :exp,
//           otpPurpose = :purpose,
//           emailVerified = :false
//     `,
//     ExpressionAttributeValues: {
//       ":otp": otp,
//       ":exp": expiresAt,
//       ":purpose": purpose,
//       ":false": false,
//     },
//   });

//   return otp;
// };


import { dynamo } from "../config/dynamo.js";
import { sendOtpEmail } from "./email.service.js";

const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;

/**
 * Generate 6 digit OTP
 */
export const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Save OTP to user record and send email
 */
export const saveOTP = async ({ userId, email, purpose }) => {
  const otp = generateOTP();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

  await dynamo.send(
    new UpdateCommand({
      TableName: USERS_TABLE,
      Key: { userId },
      UpdateExpression: `
        SET otpCode = :otp,
            otpExpiresAt = :exp,
            otpPurpose = :purpose
      `,
      ExpressionAttributeValues: {
        ":otp": otp,
        ":exp": expiresAt,
        ":purpose": purpose,
      },
    })
  );

  // Send email
  await sendOtpEmail(email, otp, purpose);

  return otp;
};

/**
 * Validate OTP
 */
export const validateOTP = async (userId, otp, purpose) => {
  const result = await dynamo.send(
    new GetCommand({
      TableName: USERS_TABLE,
      Key: { userId },
    })
  );

  const user = result.Item;
  
  if (!user) return false;
  if (!user.otpCode || user.otpCode !== otp) return false;
  if (!user.otpExpiresAt || Date.now() > user.otpExpiresAt) return false;
  if (user.otpPurpose !== purpose) return false;
  
  return true;
};