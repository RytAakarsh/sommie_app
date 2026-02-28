// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";

// const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;

// /**
//  * SIGN UP
//  */
// export const signup = async (req, res) => {
//   try {
//     const { name, email, password } = req.body;

//     if (!name || !email || !password)
//       return res.status(400).json({ message: "All fields required" });

//     // Check if email already exists
//     const existingUser = await dynamo.send(
//       new ScanCommand({
//         TableName: USERS_TABLE,
//         FilterExpression: "email = :email",
//         ExpressionAttributeValues: {
//           ":email": email,
//         },
//       })
//     );

//     if (existingUser.Items.length > 0)
//       return res.status(409).json({ message: "Email already registered" });

//     const hashedPassword = await bcrypt.hash(password, 10);

//     const user = {
//       userId: uuidv4(),
//       name,
//       email,
//       password: hashedPassword,
//       plan: "FREE",
//       createdAt: new Date().toISOString(),
//     };

//     await dynamo.send(
//       new PutCommand({
//         TableName: USERS_TABLE,
//         Item: user,
//       })
//     );

//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     res.status(201).json({
//       message: "Signup successful",
//       token,
//       user: {
//         userId: user.userId,
//         name: user.name,
//         email: user.email,
//         plan: user.plan,
//       },
//     });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: "Signup failed" });
//   }
// };

// /**
//  * LOGIN
//  */
// export const login = async (req, res) => {
//   try {
//     const { email, password } = req.body;

//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: USERS_TABLE,
//         FilterExpression: "email = :email",
//         ExpressionAttributeValues: {
//           ":email": email,
//         },
//       })
//     );

//     if (result.Items.length === 0)
//       return res.status(401).json({ message: "Invalid credentials" });

//     const user = result.Items[0];

//     const isMatch = await bcrypt.compare(password, user.password);
//     if (!isMatch)
//       return res.status(401).json({ message: "Invalid credentials" });

//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     res.json({
//       message: "Login successful",
//       token,
//       user: {
//         userId: user.userId,
//         name: user.name,
//         email: user.email,
//         plan: user.plan,
//       },
//     });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: "Login failed" });
//   }
// };


// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";

// const TABLE = process.env.DYNAMO_USERS_TABLE;
// console.log("USERS TABLE =", process.env.DYNAMO_USERS_TABLE);


// export const signup = async (req, res) => {
//   const { name, email, password } = req.body;
//   if (!name || !email || !password)
//     return res.status(400).json({ message: "All fields required" });

//   const existing = await dynamo.send(
//     new ScanCommand({
//       TableName: TABLE,
//       FilterExpression: "email = :e",
//       ExpressionAttributeValues: { ":e": email },
//     })
//   );

//   if (existing.Items.length)
//     return res.status(409).json({ message: "Email already exists" });

//   const user = {
//     userId: uuidv4(),
//     name,
//     email,
//     password: await bcrypt.hash(password, 10),
//     plan: "FREE",
//     createdAt: new Date().toISOString(),
//   };

//   await dynamo.send(new PutCommand({ TableName: TABLE, Item: user }));

//   const token = generateToken({
//     userId: user.userId,
//     email: user.email,
//     plan: user.plan,
//   });

//   res.status(201).json({ token, user });
// };

// export const login = async (req, res) => {
//   const { email, password } = req.body;

//   const result = await dynamo.send(
//     new ScanCommand({
//       TableName: TABLE,
//       FilterExpression: "email = :e",
//       ExpressionAttributeValues: { ":e": email },
//     })
//   );

//   const user = result.Items[0];
//   if (!user || !(await bcrypt.compare(password, user.password)))
//     return res.status(401).json({ message: "Invalid credentials" });

//   const token = generateToken({
//     userId: user.userId,
//     email: user.email,
//     plan: user.plan,
//   });

//   res.json({ token, user });
// };

// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";


// export const signup = async (req, res) => {
//   // Define TABLE inside the function
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   console.log("USERS TABLE (signup) =", TABLE);
  
//   if (!TABLE) {
//     console.error("ERROR: DYNAMO_USERS_TABLE is not defined!");
//     return res.status(500).json({ message: "Server configuration error" });
//   }
  
//   const { name, email, password } = req.body;
//   if (!name || !email || !password)
//     return res.status(400).json({ message: "All fields required" });

//   const existing = await dynamo.send(
//     new ScanCommand({
//       TableName: TABLE,
//       FilterExpression: "email = :e",
//       ExpressionAttributeValues: { ":e": email },
//     })
//   );

//   if (existing.Items.length)
//     return res.status(409).json({ message: "Email already exists" });

//   const user = {
//     userId: uuidv4(),
//     name,
//     email,
//     password: await bcrypt.hash(password, 10),
//     plan: "FREE",
//     createdAt: new Date().toISOString(),
//   };

//   await dynamo.send(new PutCommand({ TableName: TABLE, Item: user }));

//   const token = generateToken({
//     userId: user.userId,
//     email: user.email,
//     plan: user.plan,
//   });

//   res.status(201).json({ token, user });
// };

// export const login = async (req, res) => {
//   // Define TABLE inside the function
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   console.log("USERS TABLE (login) =", TABLE);
  
//   if (!TABLE) {
//     console.error("ERROR: DYNAMO_USERS_TABLE is not defined!");
//     return res.status(500).json({ message: "Server configuration error" });
//   }
  
//   const { email, password } = req.body;

//   const result = await dynamo.send(
//     new ScanCommand({
//       TableName: TABLE,
//       FilterExpression: "email = :e",
//       ExpressionAttributeValues: { ":e": email },
//     })
//   );

//   const user = result.Items[0];
//   if (!user || !(await bcrypt.compare(password, user.password)))
//     return res.status(401).json({ message: "Invalid credentials" });

//   const token = generateToken({
//     userId: user.userId,
//     email: user.email,
//     plan: user.plan,
//   });

//   res.json({ token, user });
// };

// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";

// /* ================= SIGNUP ================= */
// export const signup = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   console.log("USERS TABLE (signup) =", TABLE);

//   if (!TABLE) {
//     console.error("ERROR: DYNAMO_USERS_TABLE is not defined!");
//     return res.status(500).json({ message: "Server configuration error" });
//   }

//   const { name, email, password } = req.body;
//   if (!name || !email || !password) {
//     return res.status(400).json({ message: "All fields required" });
//   }

//   // Check existing user
//   const existing = await dynamo.send(
//     new ScanCommand({
//       TableName: TABLE,
//       FilterExpression: "email = :e",
//       ExpressionAttributeValues: { ":e": email },
//     })
//   );

//   if (existing.Items?.length) {
//     return res.status(409).json({ message: "Email already exists" });
//   }

//   // ✅ USER OBJECT (EXTENDED FOR PROFILE)
//   const user = {
//     userId: uuidv4(),
//     name,
//     email,
//     password: await bcrypt.hash(password, 10),

//     // 🔥 profile defaults
//     role: "Precision Sommelier",
//     avatar: "",
//     phone: "",
//     address: "",
//     gender: "",
//     dob: "",

//     plan: "FREE",
//     createdAt: new Date().toISOString(),
//   };

//   await dynamo.send(
//     new PutCommand({
//       TableName: TABLE,
//       Item: user,
//     })
//   );

//   const token = generateToken({
//     userId: user.userId,
//     email: user.email,
//     plan: user.plan,
//   });

//   // ❗ IMPORTANT: send full user back
//   res.status(201).json({ token, user });
// };

// /* ================= LOGIN ================= */
// export const login = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   console.log("USERS TABLE (login) =", TABLE);

//   if (!TABLE) {
//     console.error("ERROR: DYNAMO_USERS_TABLE is not defined!");
//     return res.status(500).json({ message: "Server configuration error" });
//   }

//   const { email, password } = req.body;

//   const result = await dynamo.send(
//     new ScanCommand({
//       TableName: TABLE,
//       FilterExpression: "email = :e",
//       ExpressionAttributeValues: { ":e": email },
//     })
//   );

//   const user = result.Items?.[0];

//   if (!user || !(await bcrypt.compare(password, user.password))) {
//     return res.status(401).json({ message: "Invalid credentials" });
//   }

//   const token = generateToken({
//     userId: user.userId,
//     email: user.email,
//     plan: user.plan,
//   });

//   // ❗ send FULL user again
//   res.json({ token, user });
// };

// import { saveOTP } from "../services/otp.service.js";
// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand } from "@aws-sdk/lib-dynamodb";
// import { UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";

// /* ================= SIGNUP ================= */
// // export const signup = async (req, res) => {
// //   try {
// //     const TABLE = process.env.DYNAMO_USERS_TABLE;

// //     const { name, email, password, age, country, gender } = req.body;

// //     if (!name || !email || !password || !age || !country || !gender) {
// //       return res.status(400).json({ message: "Missing required fields" });
// //     }

// //     const existing = await dynamo.send(
// //       new ScanCommand({
// //         TableName: TABLE,
// //         FilterExpression: "email = :e",
// //         ExpressionAttributeValues: { ":e": email },
// //       })
// //     );

// //     if (existing.Items?.length) {
// //       return res.status(409).json({ message: "Email already exists" });
// //     }

// //     const userId = uuidv4();
// //     const hashedPassword = await bcrypt.hash(password, 10);

// //     const user = {
// //       userId,
// //       name,
// //       email,
// //       password: hashedPassword,

// //       // 🔥 DEMOGRAPHICS (REAL DATA)
// //       age: Number(age),
// //       gender: gender.toLowerCase(),
// //       country,

// //       plan: "FREE",
// //       createdAt: new Date().toISOString(),
// //     };

// //     await dynamo.send(
// //       new PutCommand({
// //         TableName: TABLE,
// //         Item: user,
// //       })
// //     );

// //     const token = generateToken({
// //       userId,
// //       email,
// //       plan: user.plan,
// //     });

// //     delete user.password;

// //     res.status(201).json({ token, user });
// //   } catch (err) {
// //     console.error("Signup error:", err);
// //     res.status(500).json({ message: "Signup failed" });
// //   }
// // };


// export const signup = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;

//     const { name, email, password, age, country, gender } = req.body;

//     if (!name || !email || !password || !age || !country || !gender) {
//       return res.status(400).json({ message: "Missing required fields" });
//     }

//     const existing = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     if (existing.Items?.length) {
//       return res.status(409).json({ message: "Email already exists" });
//     }

//     const userId = uuidv4();
//     const hashedPassword = await bcrypt.hash(password, 10);

//     const user = {
//       userId,
//       name,
//       email,
//       password: hashedPassword,
//       age: Number(age),
//       gender: gender.toLowerCase(),
//       country,
//       plan: "FREE",
//       createdAt: new Date().toISOString(),
//       emailVerified: false,
//     };

//     await dynamo.send(
//       new PutCommand({
//         TableName: TABLE,
//         Item: user,
//       })
//     );

//     // 🔐 OTP for signup
//     const otp = await saveOTP({
//       userId,
//       purpose: "signup",
//     });

//     console.log("Signup OTP:", otp); // REMOVE later

//     delete user.password;

//     res.status(201).json({
//       success: true,
//       message: "Signup successful. OTP sent to email.",
//       userId,
//       requiresVerification: true,
//     });
//   } catch (err) {
//     console.error("Signup error:", err);
//     res.status(500).json({ message: "Signup failed" });
//   }
// };


// /* ================= LOGIN ================= */
// export const login = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     console.log("USERS TABLE (login) =", TABLE);

//     if (!TABLE) {
//       console.error("ERROR: DYNAMO_USERS_TABLE is not defined!");
//       return res.status(500).json({ 
//         success: false,
//         message: "Server configuration error" 
//       });
//     }

//     const { email, password } = req.body;

//     if (!email || !password) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and password are required" 
//       });
//     }

//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     // if (!user || !(await bcrypt.compare(password, user.password))) {
//     //   return res.status(401).json({ 
//     //     success: false,
//     //     message: "Invalid credentials" 
//     //   });
//     // }
//     if (!user || !(await bcrypt.compare(password, user.password))) {
//   return res.status(401).json({
//     success: false,
//     message: "Invalid credentials",
//   });
// }

// if (!user.emailVerified) {
//   return res.status(403).json({
//     success: false,
//     message: "Email not verified",
//     requiresOtp: true,
//     purpose: "signup",
//   });
// }


//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     // ❗ send FULL user (exclude password)
//     const userResponse = { ...user };
//     delete userResponse.password;
    
//     res.json({ 
//       success: true,
//       token, 
//       user: userResponse 
//     });

//   } catch (error) {
//     console.error("Login error:", error);
//     res.status(500).json({ 
//       success: false,
//       message: "Login failed", 
//       error: error.message 
//     });
//   }
// };

// /* ================= VERIFY OTP ================= */
// export const verifyOtp = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, otp, purpose } = req.body;

//     if (!email || !otp || !purpose) {
//       return res.status(400).json({
//         message: "Email, OTP and purpose are required",
//       });
//     }

//     // 1️⃣ Find user by email
//     const scanResult = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: {
//           ":e": email,
//         },
//       })
//     );

//     const user = scanResult.Items?.[0];

//     if (!user) {
//       return res.status(404).json({ message: "User not found" });
//     }

//     // 2️⃣ Validate OTP
//     if (!user.otpCode || user.otpCode !== otp) {
//       return res.status(400).json({ message: "Invalid OTP" });
//     }

//     if (!user.otpExpiresAt || Date.now() > user.otpExpiresAt) {
//       return res.status(400).json({ message: "OTP expired" });
//     }

//     if (user.otpPurpose !== purpose) {
//       return res.status(400).json({ message: "OTP purpose mismatch" });
//     }

//     // 3️⃣ Update user: verify email + clear OTP
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET emailVerified = :true
//           REMOVE otpCode, otpExpiresAt, otpPurpose
//         `,
//         ExpressionAttributeValues: {
//           ":true": true,
//         },
//       })
//     );

//     // 4️⃣ Issue JWT
//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     // 5️⃣ Send response
//     const userResponse = {
//       userId: user.userId,
//       name: user.name,
//       email: user.email,
//       plan: user.plan,
//       emailVerified: true,
//     };

//     return res.json({
//       success: true,
//       token,
//       user: userResponse,
//     });

//   } catch (err) {
//     console.error("Verify OTP error:", err);
//     return res.status(500).json({
//       message: "OTP verification failed",
//     });
//   }
// };

// export const forgotPassword = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email } = req.body;

//     if (!email) {
//       return res.status(400).json({ message: "Email is required" });
//     }

//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     // ❗ SECURITY: Do not reveal if user exists
//     if (!user) {
//       return res.json({
//         success: true,
//         message: "If this email exists, an OTP has been sent",
//       });
//     }

//     const otp = generateOtp();
//     const expiresAt = Date.now() + 5 * 60 * 1000; // 5 min

//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET otpCode = :otp,
//               otpExpiresAt = :exp,
//               otpPurpose = :purpose
//         `,
//         ExpressionAttributeValues: {
//           ":otp": otp,
//           ":exp": expiresAt,
//           ":purpose": "forgot_password",
//         },
//       })
//     );

//     await sendOtpEmail(email, otp, "forgot_password");

//     res.json({
//       success: true,
//       message: "OTP sent to email",
//     });
//   } catch (err) {
//     console.error("Forgot password error:", err);
//     res.status(500).json({ message: "Failed to send OTP" });
//   }
// };


// export const verifyForgotPasswordOtp = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, otp } = req.body;

//     if (!email || !otp) {
//       return res.status(400).json({ message: "Email and OTP required" });
//     }

//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (
//       !user ||
//       user.otpCode !== otp ||
//       user.otpPurpose !== "forgot_password" ||
//       Date.now() > user.otpExpiresAt
//     ) {
//       return res.status(400).json({ message: "Invalid or expired OTP" });
//     }

//     // Mark OTP as verified (soft)
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: "SET otpVerified = :true",
//         ExpressionAttributeValues: {
//           ":true": true,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "OTP verified",
//     });
//   } catch (err) {
//     console.error("Verify forgot OTP error:", err);
//     res.status(500).json({ message: "OTP verification failed" });
//   }
// };


// export const resetPassword = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, newPassword } = req.body;

//     if (!email || !newPassword) {
//       return res.status(400).json({ message: "Missing data" });
//     }

//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (!user || !user.otpVerified) {
//       return res.status(403).json({ message: "OTP not verified" });
//     }

//     const hashed = await bcrypt.hash(newPassword, 10);

//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET password = :pwd
//           REMOVE otpCode, otpExpiresAt, otpPurpose, otpVerified
//         `,
//         ExpressionAttributeValues: {
//           ":pwd": hashed,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Password reset successful",
//     });
//   } catch (err) {
//     console.error("Reset password error:", err);
//     res.status(500).json({ message: "Password reset failed" });
//   }
// };


// import { saveOTP, validateOTP } from "../services/otp.service.js";
// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand, UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";
// import { sendOtpEmail } from "../services/email.service.js";
// import { generateOTP } from "../services/otp.service.js";

// /* ================= SIGNUP ================= */
// export const signup = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;

//     const { name, email, password, age, country, gender } = req.body;

//     if (!name || !email || !password || !age || !country || !gender) {
//       return res.status(400).json({ message: "Missing required fields" });
//     }

//     // Check if user exists
//     const existing = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     if (existing.Items?.length) {
//       return res.status(409).json({ 
//         success: false,
//         message: "Email already exists" 
//       });
//     }

//     const userId = uuidv4();
//     const hashedPassword = await bcrypt.hash(password, 10);

//     const user = {
//       userId,
//       name,
//       email,
//       password: hashedPassword,
//       age: Number(age),
//       gender: gender.toLowerCase(),
//       country,
//       plan: "FREE",
//       emailVerified: false,
//       createdAt: new Date().toISOString(),
//     };

//     // Save user
//     await dynamo.send(
//       new PutCommand({
//         TableName: TABLE,
//         Item: user,
//       })
//     );

//     // Generate and send OTP
//     const otp = generateOTP();
//     const expiresAt = Date.now() + 5 * 60 * 1000;

//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: `
//           SET otpCode = :otp,
//               otpExpiresAt = :exp,
//               otpPurpose = :purpose
//         `,
//         ExpressionAttributeValues: {
//           ":otp": otp,
//           ":exp": expiresAt,
//           ":purpose": "signup",
//         },
//       })
//     );

//     // Send OTP email
//     await sendOtpEmail(email, otp, "signup");

//     res.status(201).json({
//       success: true,
//       message: "Signup successful. OTP sent to email.",
//       userId,
//       email,
//       requiresVerification: true,
//     });

//   } catch (err) {
//     console.error("Signup error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Signup failed" 
//     });
//   }
// };

// /* ================= VERIFY SIGNUP OTP ================= */
// export const verifySignupOtp = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, otp } = req.body;

//     if (!email || !otp) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and OTP are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];
    
//     if (!user) {
//       return res.status(404).json({ 
//         success: false,
//         message: "User not found" 
//       });
//     }

//     // Validate OTP
//     if (!user.otpCode || user.otpCode !== otp) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Invalid OTP" 
//       });
//     }

//     if (!user.otpExpiresAt || Date.now() > user.otpExpiresAt) {
//       return res.status(400).json({ 
//         success: false,
//         message: "OTP expired" 
//       });
//     }

//     if (user.otpPurpose !== "signup") {
//       return res.status(400).json({ 
//         success: false,
//         message: "Invalid OTP purpose" 
//       });
//     }

//     // Update user - verify email and clear OTP
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET emailVerified = :true,
//               otpCode = :null,
//               otpExpiresAt = :null,
//               otpPurpose = :null
//         `,
//         ExpressionAttributeValues: {
//           ":true": true,
//           ":null": null,
//         },
//       })
//     );

//     // Generate token
//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     // Prepare user response
//     const userResponse = {
//       userId: user.userId,
//       name: user.name,
//       email: user.email,
//       plan: user.plan,
//       emailVerified: true,
//       age: user.age,
//       country: user.country,
//       gender: user.gender,
//     };

//     res.json({
//       success: true,
//       message: "Email verified successfully",
//       token,
//       user: userResponse,
//     });

//   } catch (err) {
//     console.error("Verify OTP error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "OTP verification failed" 
//     });
//   }
// };

// /* ================= LOGIN ================= */
// export const login = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, password } = req.body;

//     if (!email || !password) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and password are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (!user || !(await bcrypt.compare(password, user.password))) {
//       return res.status(401).json({
//         success: false,
//         message: "Invalid credentials",
//       });
//     }

//     // Check if email is verified
//     if (!user.emailVerified) {
//       return res.status(403).json({
//         success: false,
//         message: "Email not verified",
//         requiresVerification: true,
//         purpose: "signup",
//       });
//     }

//     // Generate token
//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     // Prepare user response
//     const userResponse = { ...user };
//     delete userResponse.password;

//     res.json({
//       success: true,
//       message: "Login successful",
//       token,
//       user: userResponse,
//     });

//   } catch (error) {
//     console.error("Login error:", error);
//     res.status(500).json({ 
//       success: false,
//       message: "Login failed",
//       error: error.message 
//     });
//   }
// };

// /* ================= FORGOT PASSWORD ================= */
// export const forgotPassword = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email } = req.body;

//     if (!email) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email is required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     // Security: Don't reveal if user exists
//     if (!user) {
//       return res.json({
//         success: true,
//         message: "If this email exists, an OTP has been sent",
//       });
//     }

//     // Generate OTP
//     const otp = generateOTP();
//     const expiresAt = Date.now() + 5 * 60 * 1000; // 5 min

//     // Save OTP to user
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET otpCode = :otp,
//               otpExpiresAt = :exp,
//               otpPurpose = :purpose,
//               otpVerified = :false
//         `,
//         ExpressionAttributeValues: {
//           ":otp": otp,
//           ":exp": expiresAt,
//           ":purpose": "forgot_password",
//           ":false": false,
//         },
//       })
//     );

//     // Send OTP email
//     await sendOtpEmail(email, otp, "forgot_password");

//     res.json({
//       success: true,
//       message: "OTP sent to email",
//     });

//   } catch (err) {
//     console.error("Forgot password error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Failed to send OTP" 
//     });
//   }
// };

// /* ================= VERIFY FORGOT PASSWORD OTP ================= */
// export const verifyForgotPasswordOtp = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, otp } = req.body;

//     if (!email || !otp) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and OTP are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     // Validate OTP
//     if (!user || 
//         !user.otpCode || 
//         user.otpCode !== otp || 
//         user.otpPurpose !== "forgot_password" ||
//         Date.now() > user.otpExpiresAt) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Invalid or expired OTP" 
//       });
//     }

//     // Mark OTP as verified
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: "SET otpVerified = :true",
//         ExpressionAttributeValues: {
//           ":true": true,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "OTP verified successfully",
//     });

//   } catch (err) {
//     console.error("Verify forgot OTP error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "OTP verification failed" 
//     });
//   }
// };

// /* ================= RESET PASSWORD ================= */
// export const resetPassword = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, newPassword } = req.body;

//     if (!email || !newPassword) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and new password are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (!user || !user.otpVerified) {
//       return res.status(403).json({ 
//         success: false,
//         message: "OTP not verified or expired" 
//       });
//     }

//     // Hash new password
//     const hashedPassword = await bcrypt.hash(newPassword, 10);

//     // Update password and clear OTP fields
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET password = :pwd,
//               otpCode = :null,
//               otpExpiresAt = :null,
//               otpPurpose = :null,
//               otpVerified = :null
//         `,
//         ExpressionAttributeValues: {
//           ":pwd": hashedPassword,
//           ":null": null,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Password reset successful",
//     });

//   } catch (err) {
//     console.error("Reset password error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Password reset failed" 
//     });
//   }
// };

// /* ================= RESEND OTP ================= */
// export const resendOtp = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, purpose } = req.body;

//     if (!email || !purpose) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and purpose are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (!user) {
//       return res.status(404).json({ 
//         success: false,
//         message: "User not found" 
//       });
//     }

//     // Generate new OTP
//     const otp = generateOTP();
//     const expiresAt = Date.now() + 5 * 60 * 1000;

//     // Update OTP
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: `
//           SET otpCode = :otp,
//               otpExpiresAt = :exp,
//               otpPurpose = :purpose
//         `,
//         ExpressionAttributeValues: {
//           ":otp": otp,
//           ":exp": expiresAt,
//           ":purpose": purpose,
//         },
//       })
//     );

//     // Send OTP email
//     await sendOtpEmail(email, otp, purpose);

//     res.json({
//       success: true,
//       message: "OTP resent successfully",
//     });

//   } catch (err) {
//     console.error("Resend OTP error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Failed to resend OTP" 
//     });
//   }
// };


 
// import bcrypt from "bcryptjs";
// import { v4 as uuidv4 } from "uuid";
// import { PutCommand, ScanCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";
// import { generateToken } from "../config/jwt.js";

// /* ================= SIGNUP ================= */
// export const signup = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;

//     const { name, email, password, age, country, gender } = req.body;

//     if (!name || !email || !password || !age || !country || !gender) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Missing required fields" 
//       });
//     }

//     // Check if user exists
//     const existing = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     if (existing.Items?.length) {
//       return res.status(409).json({ 
//         success: false,
//         message: "Email already exists" 
//       });
//     }

//     const userId = uuidv4();
//     const hashedPassword = await bcrypt.hash(password, 10);

//     const user = {
//       userId,
//       name,
//       email,
//       password: hashedPassword,
//       age: Number(age),
//       gender: gender.toLowerCase(),
//       country,
//       plan: "FREE",
//       emailVerified: true, // Auto-verify for now
//       createdAt: new Date().toISOString(),
//     };

//     // Save user
//     await dynamo.send(
//       new PutCommand({
//         TableName: TABLE,
//         Item: user,
//       })
//     );

//     // Generate token
//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     // Prepare user response
//     const userResponse = {
//       userId: user.userId,
//       name: user.name,
//       email: user.email,
//       plan: user.plan,
//       emailVerified: true,
//       age: user.age,
//       country: user.country,
//       gender: user.gender,
//       createdAt: user.createdAt,
//     };

//     res.status(201).json({
//       success: true,
//       message: "Signup successful",
//       token,
//       user: userResponse,
//     });

//   } catch (err) {
//     console.error("Signup error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Signup failed" 
//     });
//   }
// };

// /* ================= LOGIN ================= */
// export const login = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, password } = req.body;

//     if (!email || !password) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and password are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (!user || !(await bcrypt.compare(password, user.password))) {
//       return res.status(401).json({
//         success: false,
//         message: "Invalid credentials",
//       });
//     }

//     // Generate token
//     const token = generateToken({
//       userId: user.userId,
//       email: user.email,
//       plan: user.plan,
//     });

//     // Prepare user response
//     const userResponse = { ...user };
//     delete userResponse.password;

//     res.json({
//       success: true,
//       message: "Login successful",
//       token,
//       user: userResponse,
//     });

//   } catch (error) {
//     console.error("Login error:", error);
//     res.status(500).json({ 
//       success: false,
//       message: "Login failed",
//       error: error.message 
//     });
//   }
// };

// /* ================= FORGOT PASSWORD ================= */
// export const forgotPassword = async (req, res) => {
//   try {
//     const TABLE = process.env.DYNAMO_USERS_TABLE;
//     const { email, newPassword } = req.body;

//     if (!email || !newPassword) {
//       return res.status(400).json({ 
//         success: false,
//         message: "Email and new password are required" 
//       });
//     }

//     // Find user
//     const result = await dynamo.send(
//       new ScanCommand({
//         TableName: TABLE,
//         FilterExpression: "email = :e",
//         ExpressionAttributeValues: { ":e": email },
//       })
//     );

//     const user = result.Items?.[0];

//     if (!user) {
//       return res.status(404).json({ 
//         success: false,
//         message: "User not found" 
//       });
//     }

//     // Hash new password
//     const hashedPassword = await bcrypt.hash(newPassword, 10);

//     // Update password
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId: user.userId },
//         UpdateExpression: "SET password = :pwd",
//         ExpressionAttributeValues: {
//           ":pwd": hashedPassword,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Password reset successful",
//     });

//   } catch (err) {
//     console.error("Reset password error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Password reset failed" 
//     });
//   }
// };



import bcrypt from "bcryptjs";
import { v4 as uuidv4 } from "uuid";
import { PutCommand, QueryCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";
import { dynamo } from "../config/dynamo.js";
import { generateToken } from "../config/jwt.js";

/* ================= SIGNUP ================= */
export const signup = async (req, res) => {
  try {
    const TABLE = process.env.DYNAMO_USERS_TABLE;

    // const { name, email, password, age, country, gender } = req.body;
    const { name, password, age, country, gender } = req.body;
const email = req.body.email?.toLowerCase().trim();

    if (!name || !email || !password || !age || !country || !gender) {
      return res.status(400).json({ 
        success: false,
        message: "Missing required fields" 
      });
    }

    // ✅ Check if user exists using QueryCommand with email-index
    const existing = await dynamo.send(
      new QueryCommand({
        TableName: TABLE,
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
      country,
      plan: "FREE",
      emailVerified: true, // Auto-verify for now
      createdAt: new Date().toISOString(),
    };

    // Save user
    await dynamo.send(
      new PutCommand({
        TableName: TABLE,
        Item: user,
      })
    );

    // Generate token
    const token = generateToken({
      userId: user.userId,
      email: user.email,
      plan: user.plan,
    });

    // Prepare user response
    const userResponse = {
      userId: user.userId,
      name: user.name,
      email: user.email,
      plan: user.plan,
      emailVerified: true,
      age: user.age,
      country: user.country,
      gender: user.gender,
      createdAt: user.createdAt,
    };

    res.status(201).json({
      success: true,
      message: "Signup successful",
      token,
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

/* ================= LOGIN ================= */
export const login = async (req, res) => {
  try {
    const TABLE = process.env.DYNAMO_USERS_TABLE;
    // const { email, password } = req.body;
    const password = req.body.password;
const email = req.body.email?.toLowerCase().trim();

    if (!email || !password) {
      return res.status(400).json({ 
        success: false,
        message: "Email and password are required" 
      });
    }

    // ✅ Find user using QueryCommand with email-index
    const result = await dynamo.send(
      new QueryCommand({
        TableName: TABLE,
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

    // Generate token
    const token = generateToken({
      userId: user.userId,
      email: user.email,
      plan: user.plan,
    });

    // Prepare user response
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
    const TABLE = process.env.DYNAMO_USERS_TABLE;
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).json({ 
        success: false,
        message: "Email and new password are required" 
      });
    }

    // ✅ Find user using QueryCommand with email-index
    const result = await dynamo.send(
      new QueryCommand({
        TableName: TABLE,
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
      return res.status(404).json({ 
        success: false,
        message: "User not found" 
      });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password
    await dynamo.send(
      new UpdateCommand({
        TableName: TABLE,
        Key: { userId: user.userId },
        UpdateExpression: "SET password = :pwd",
        ExpressionAttributeValues: {
          ":pwd": hashedPassword,
        },
      })
    );

    res.json({
      success: true,
      message: "Password reset successful",
    });

  } catch (err) {
    console.error("Reset password error:", err);
    res.status(500).json({ 
      success: false,
      message: "Password reset failed" 
    });
  }
};