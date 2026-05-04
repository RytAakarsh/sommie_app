// import { sendEmail } from "../config/ses.js";

// /**
//  * Send OTP email for various purposes
//  */
// export const sendOtpEmail = async (email, otp, purpose = "signup") => {
//   const purposes = {
//     signup: {
//       subject: "Verify Your Email - Sommie",
//       html: `
//         <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
//           <h2 style="color: #4B2B5F;">Welcome to Sommie!</h2>
//           <p>Please use the following OTP to verify your email address:</p>
//           <div style="background: #f4f4f4; padding: 20px; text-align: center; margin: 20px 0;">
//             <h1 style="color: #4B2B5F; letter-spacing: 10px; font-size: 32px;">${otp}</h1>
//           </div>
//           <p>This OTP is valid for 5 minutes.</p>
//           <p>If you didn't request this, please ignore this email.</p>
//           <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
//           <p style="color: #666; font-size: 12px;">© ${new Date().getFullYear()} Sommie. All rights reserved.</p>
//         </div>
//       `,
//     },
//     forgot_password: {
//       subject: "Reset Your Password - Sommie",
//       html: `
//         <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
//           <h2 style="color: #4B2B5F;">Password Reset Request</h2>
//           <p>You requested to reset your password. Use the following OTP:</p>
//           <div style="background: #f4f4f4; padding: 20px; text-align: center; margin: 20px 0;">
//             <h1 style="color: #4B2B5F; letter-spacing: 10px; font-size: 32px;">${otp}</h1>
//           </div>
//           <p>This OTP is valid for 5 minutes.</p>
//           <p>If you didn't request a password reset, please ignore this email.</p>
//           <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
//           <p style="color: #666; font-size: 12px;">© ${new Date().getFullYear()} Sommie. All rights reserved.</p>
//         </div>
//       `,
//     },
//   };

//   const template = purposes[purpose] || purposes.signup;
  
//   try {
//     await sendEmail({
//       to: email,
//       subject: template.subject,
//       html: template.html,
//     });
//     return true;
//   } catch (error) {
//     console.error("Failed to send OTP email:", error);
//     throw new Error("Failed to send email");
//   }
// };


import { sendEmail } from "../config/ses.js";

/**
 * Send OTP email for various purposes
 */
export const sendOtpEmail = async (email, otp, purpose = "signup") => {
  const purposes = {
    signup: {
      subject: "Verify Your Email - Sommie",
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #4B2B5F;">Welcome to Sommie!</h2>
          <p>Please use the following OTP to verify your email address:</p>
          <div style="background: #f4f4f4; padding: 20px; text-align: center; margin: 20px 0;">
            <h1 style="color: #4B2B5F; letter-spacing: 10px; font-size: 32px;">${otp}</h1>
          </div>
          <p>This OTP is valid for 5 minutes.</p>
          <p>If you didn't request this, please ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #666; font-size: 12px;">© ${new Date().getFullYear()} Sommie. All rights reserved.</p>
        </div>
      `,
    },
    forgot_password: {
      subject: "Reset Your Password - Sommie",
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #4B2B5F;">Password Reset Request</h2>
          <p>You requested to reset your password. Use the following OTP:</p>
          <div style="background: #f4f4f4; padding: 20px; text-align: center; margin: 20px 0;">
            <h1 style="color: #4B2B5F; letter-spacing: 10px; font-size: 32px;">${otp}</h1>
          </div>
          <p>This OTP is valid for 5 minutes.</p>
          <p>If you didn't request a password reset, please ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="color: #666; font-size: 12px;">© ${new Date().getFullYear()} Sommie. All rights reserved.</p>
        </div>
      `,
    },
  };

  const template = purposes[purpose] || purposes.signup;
  
  try {
    await sendEmail({
      to: email,
      subject: template.subject,
      html: template.html,
    });
    return true;
  } catch (error) {
    console.error("Failed to send OTP email:", error);
    throw new Error("Failed to send email");
  }
};

