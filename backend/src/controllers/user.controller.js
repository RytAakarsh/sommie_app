// import { UpdateCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";

// export const upgradePlan = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;

//   const { userId, plan } = req.body;

//   if (!userId || !plan) {
//     return res.status(400).json({ message: "Missing userId or plan" });
//   }

//   try {
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: "set #p = :p",
//         ExpressionAttributeNames: {
//           "#p": "plan",
//         },
//         ExpressionAttributeValues: {
//           ":p": plan,
//         },
//       })
//     );

//     res.json({ success: true, plan });
//   } catch (err) {
//     console.error("Upgrade plan error:", err);
//     res.status(500).json({ message: "Failed to upgrade plan" });
//   }
// };


// import { UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";

// /* ================= UPGRADE PLAN ================= */
// export const upgradePlan = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;

//   const { userId, plan } = req.body;

//   // Verify that the authenticated user matches the requested userId
//   if (req.user.userId !== userId) {
//     return res.status(403).json({ 
//       success: false,
//       message: "Unauthorized to modify this user" 
//     });
//   }

//   if (!userId || !plan) {
//     return res.status(400).json({ 
//       success: false,
//       message: "Missing userId or plan" 
//     });
//   }

//   try {
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: "set #p = :p",
//         ExpressionAttributeNames: {
//           "#p": "plan",
//         },
//         ExpressionAttributeValues: {
//           ":p": plan,
//         },
//       })
//     );

//     res.json({ 
//       success: true, 
//       plan 
//     });
//   } catch (err) {
//     console.error("Upgrade plan error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Failed to upgrade plan" 
//     });
//   }
// };

// /* ================= UPDATE PROFILE ================= */
// export const updateProfile = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;

//   const { userId, name, avatar, photo, role, email, phone, address, dob, gender } = req.body;

//   // Verify that the authenticated user matches the requested userId
//   if (req.user.userId !== userId) {
//     return res.status(403).json({ 
//       success: false,
//       message: "Unauthorized to modify this user" 
//     });
//   }

//   if (!userId) {
//     return res.status(400).json({ 
//       success: false,
//       message: "Missing userId" 
//     });
//   }

//   try {
//     // Build update expression dynamically
//     let updateExpression = "SET lastProfileUpdate = :updated";
//     const expressionAttributeValues = {
//       ":updated": new Date().toISOString(),
//     };
//     const expressionAttributeNames = {};

//     if (name !== undefined) {
//       updateExpression += ", #name = :name";
//       expressionAttributeNames["#name"] = "name";
//       expressionAttributeValues[":name"] = name;
//     }

//     if (avatar !== undefined) {
//       updateExpression += ", avatar = :avatar";
//       expressionAttributeValues[":avatar"] = avatar;
//     }

//     if (photo !== undefined) {
//       updateExpression += ", photo = :photo";
//       expressionAttributeValues[":photo"] = photo;
//     }

//     if (role !== undefined) {
//       updateExpression += ", role = :role";
//       expressionAttributeValues[":role"] = role;
//     }

//     if (email !== undefined) {
//       updateExpression += ", email = :email";
//       expressionAttributeValues[":email"] = email;
//     }

//     if (phone !== undefined) {
//       updateExpression += ", phone = :phone";
//       expressionAttributeValues[":phone"] = phone;
//     }

//     if (address !== undefined) {
//       updateExpression += ", address = :address";
//       expressionAttributeValues[":address"] = address;
//     }

//     if (dob !== undefined) {
//       updateExpression += ", dob = :dob";
//       expressionAttributeValues[":dob"] = dob;
//     }

//     if (gender !== undefined) {
//       updateExpression += ", gender = :gender";
//       expressionAttributeValues[":gender"] = gender;
//     }

//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: updateExpression,
//         ConditionExpression: "attribute_exists(userId)",
//         ExpressionAttributeNames: Object.keys(expressionAttributeNames).length > 0 
//           ? expressionAttributeNames 
//           : undefined,
//         ExpressionAttributeValues: expressionAttributeValues,
//       })
//     );

//     // Fetch updated user to return
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: TABLE,
//         Key: { userId },
//       })
//     );

//     const updatedUser = result.Item;
//     delete updatedUser.password;

//     res.json({
//       success: true,
//       message: "Profile updated successfully",
//       profile: updatedUser,
//     });
//   } catch (err) {
//     console.error("Update profile error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Failed to update profile" 
//     });
//   }
// };

// /* ================= GET PROFILE ================= */
// export const getProfile = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   const { userId } = req.params;

//   // Verify that the authenticated user matches the requested userId
//   if (req.user.userId !== userId) {
//     return res.status(403).json({ 
//       success: false,
//       message: "Unauthorized to view this user" 
//     });
//   }

//   if (!userId) {
//     return res.status(400).json({ 
//       success: false,
//       message: "Missing userId" 
//     });
//   }

//   try {
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: TABLE,
//         Key: { userId },
//       })
//     );

//     if (!result.Item) {
//       return res.status(404).json({ 
//         success: false,
//         message: "User not found" 
//       });
//     }

//     const user = result.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       profile: user,
//     });
//   } catch (err) {
//     console.error("Get profile error:", err);
//     res.status(500).json({ 
//       success: false,
//       message: "Failed to fetch profile" 
//     });
//   }
// };



// import { UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";

// /* ================= UPGRADE PLAN ================= */
// export const upgradePlan = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   const { userId, plan } = req.body;

//   if (!userId || !plan) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId or plan",
//     });
//   }

//   // Auth check
//   if (!req.user || req.user.userId !== userId) {
//     return res.status(403).json({
//       success: false,
//       message: "Unauthorized to modify this user",
//     });
//   }

//   try {
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: "SET #p = :p",
//         ExpressionAttributeNames: {
//           "#p": "plan",
//         },
//         ExpressionAttributeValues: {
//           ":p": plan,
//         },
//         ConditionExpression: "attribute_exists(userId)", // ✅ safety
//       })
//     );

//     res.json({
//       success: true,
//       plan,
//     });
//   } catch (err) {
//     console.error("Upgrade plan error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to upgrade plan",
//     });
//   }
// };

// /* ================= UPDATE PROFILE ================= */
// export const updateProfile = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;

//   try {
//     const {
//       userId,
//       name,
//       avatar,
//       photo,
//       role,
//       email,
//       phone,
//       address,
//       dob,
//       gender,
//     } = req.body;

//     if (!userId) {
//       return res.status(400).json({
//         success: false,
//         message: "Missing userId",
//       });
//     }

//     // Auth check
//     if (!req.user || req.user.userId !== userId) {
//       return res.status(403).json({
//         success: false,
//         message: "Unauthorized to modify this user",
//       });
//     }

//     // ✅ CLEAN UNDEFINED VALUES (CRITICAL FIX)
//     const fields = {
//       name,
//       avatar,
//       photo,
//       role,
//       email,
//       phone,
//       address,
//       dob,
//       gender,
//     };

//     const cleanFields = Object.fromEntries(
//       Object.entries(fields).filter(([_, v]) => v !== undefined)
//     );

//     // Always include timestamp
//     cleanFields.lastProfileUpdate = new Date().toISOString();

//     // Build update expression safely
//     const updates = [];
//     const values = {};
//     const names = {};

//     for (const [key, value] of Object.entries(cleanFields)) {
//   // Handle reserved keywords
//   if (key === "name") {
//     updates.push("#name = :name");
//     names["#name"] = "name";
//     values[":name"] = value;
//   } 
//   else if (key === "role") {
//     updates.push("#role = :role");
//     names["#role"] = "role";
//     values[":role"] = value;
//   } 
//   else {
//     updates.push(`${key} = :${key}`);
//     values[`:${key}`] = value;
//   }
// }

//     if (updates.length === 0) {
//       return res.status(400).json({
//         success: false,
//         message: "No valid fields to update",
//       });
//     }

//     const updateExpression = "SET " + updates.join(", ");

//     // ✅ DEBUG LOG (remove later if needed)
//     console.log("UpdateExpression:", updateExpression);
//     console.log("Values:", values);

//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: updateExpression,
//         ExpressionAttributeNames: Object.keys(names).length ? names : undefined,
//         ExpressionAttributeValues: values,
//         ConditionExpression: "attribute_exists(userId)", // ✅ prevents accidental creation
//       })
//     );

//     // Fetch updated user
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: TABLE,
//         Key: { userId },
//       })
//     );

//     const updatedUser = result.Item;

//     if (!updatedUser) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found after update",
//       });
//     }

//     delete updatedUser.password;

//     res.json({
//       success: true,
//       message: "Profile updated successfully",
//       profile: updatedUser,
//     });
//   } catch (err) {
//     console.error("Update profile error:", err);

//     res.status(500).json({
//       success: false,
//       message: "Failed to update profile",
//       error: err.message, // ✅ helps debugging
//     });
//   }
// };

// /* ================= GET PROFILE ================= */
// export const getProfile = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   const { userId } = req.params;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   // Auth check
//   if (!req.user || req.user.userId !== userId) {
//     return res.status(403).json({
//       success: false,
//       message: "Unauthorized to view this user",
//     });
//   }

//   try {
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: TABLE,
//         Key: { userId },
//       })
//     );

//     if (!result.Item) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found",
//       });
//     }

//     const user = result.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       profile: user,
//     });
//   } catch (err) {
//     console.error("Get profile error:", err);

//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch profile",
//     });
//   }
// };




// import { UpdateCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";

// /* ================= UPGRADE PLAN ================= */
// export const upgradePlan = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
//   const { plan } = req.body;

//   // ✅ Get userId from token, NOT from body
//   const userId = req.user.userId;

//   if (!userId || !plan) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId or plan",
//     });
//   }

//   try {
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: "SET #p = :p",
//         ExpressionAttributeNames: {
//           "#p": "plan",
//         },
//         ExpressionAttributeValues: {
//           ":p": plan,
//         },
//         ConditionExpression: "attribute_exists(userId)",
//       })
//     );

//     res.json({
//       success: true,
//       plan,
//     });
//   } catch (err) {
//     console.error("Upgrade plan error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to upgrade plan",
//     });
//   }
// };

// /* ================= UPDATE PROFILE ================= */
// export const updateProfile = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;

//   try {
//     // ✅ Get userId from token
//     const userId = req.user.userId;
    
//     const {
//       name,
//       avatar,
//       photo,
//       role,
//       email,
//       phone,
//       address,
//       dob,
//       gender,
//     } = req.body;

//     if (!userId) {
//       return res.status(400).json({
//         success: false,
//         message: "Missing userId",
//       });
//     }

//     // ✅ CLEAN UNDEFINED VALUES
//     const fields = {
//       name,
//       avatar,
//       photo,
//       role,
//       email,
//       phone,
//       address,
//       dob,
//       gender,
//     };

//     const cleanFields = Object.fromEntries(
//       Object.entries(fields).filter(([_, v]) => v !== undefined)
//     );

//     // Always include timestamp
//     cleanFields.lastProfileUpdate = new Date().toISOString();

//     // Build update expression safely
//     const updates = [];
//     const values = {};
//     const names = {};

//     for (const [key, value] of Object.entries(cleanFields)) {
//       // Handle reserved keywords
//       if (key === "name") {
//         updates.push("#name = :name");
//         names["#name"] = "name";
//         values[":name"] = value;
//       } 
//       else if (key === "role") {
//         updates.push("#role = :role");
//         names["#role"] = "role";
//         values[":role"] = value;
//       } 
//       else {
//         updates.push(`${key} = :${key}`);
//         values[`:${key}`] = value;
//       }
//     }

//     if (updates.length === 0) {
//       return res.status(400).json({
//         success: false,
//         message: "No valid fields to update",
//       });
//     }

//     const updateExpression = "SET " + updates.join(", ");

//     await dynamo.send(
//       new UpdateCommand({
//         TableName: TABLE,
//         Key: { userId },
//         UpdateExpression: updateExpression,
//         ExpressionAttributeNames: Object.keys(names).length ? names : undefined,
//         ExpressionAttributeValues: values,
//         ConditionExpression: "attribute_exists(userId)",
//       })
//     );

//     // Fetch updated user
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: TABLE,
//         Key: { userId },
//       })
//     );

//     const updatedUser = result.Item;

//     if (!updatedUser) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found after update",
//       });
//     }

//     delete updatedUser.password;

//     res.json({
//       success: true,
//       message: "Profile updated successfully",
//       profile: updatedUser,
//     });
//   } catch (err) {
//     console.error("Update profile error:", err);

//     res.status(500).json({
//       success: false,
//       message: "Failed to update profile",
//       error: err.message,
//     });
//   }
// };

// /* ================= GET PROFILE ================= */
// export const getProfile = async (req, res) => {
//   const TABLE = process.env.DYNAMO_USERS_TABLE;
  
//   // ✅ Get userId from token, NOT from URL params
//   const userId = req.user.userId;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: TABLE,
//         Key: { userId },
//       })
//     );

//     if (!result.Item) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found",
//       });
//     }

//     const user = result.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       profile: user,
//     });
//   } catch (err) {
//     console.error("Get profile error:", err);

//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch profile",
//     });
//   }
// };




// import { UpdateCommand, GetCommand, PutCommand, QueryCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";

// const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;
// const PROFILES_TABLE = process.env.DYNAMO_PROFILES_TABLE || "SommieProfiles";
// const CHATS_TABLE = process.env.DYNAMO_CHATS_TABLE;
// const CELLAR_TABLE = process.env.DYNAMO_CELLAR_TABLE || "SommieCellar";
// const RESTAURANTS_TABLE = process.env.DYNAMO_RESTAURANTS_TABLE || "SommieRestaurants";

// /* ================= UPGRADE PLAN ================= */
// export const upgradePlan = async (req, res) => {
//   const userId = req.user.userId;
//   const { plan } = req.body;

//   if (!userId || !plan) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId or plan",
//     });
//   }

//   try {
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//         UpdateExpression: "SET #p = :p, subscriptionDate = :date",
//         ExpressionAttributeNames: {
//           "#p": "plan",
//         },
//         ExpressionAttributeValues: {
//           ":p": plan,
//           ":date": new Date().toISOString(),
//         },
//         ConditionExpression: "attribute_exists(userId)",
//       })
//     );

//     res.json({
//       success: true,
//       plan,
//     });
//   } catch (err) {
//     console.error("Upgrade plan error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to upgrade plan",
//     });
//   }
// };

// /* ================= UPDATE PROFILE ================= */
// export const updateProfile = async (req, res) => {
//   const userId = req.user.userId;
  
//   const {
//     name,
//     email,
//     phone,
//     cpf,
//     gender,
//     dob,
//     photo,
//     avatar,
//     role,
//     address,
//   } = req.body;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     // Update main users table
//     const userUpdates = {};
//     if (name) userUpdates.name = name;
//     if (email) userUpdates.email = email;
//     if (avatar) userUpdates.avatar = avatar;
//     if (role) userUpdates.role = role;
//     if (photo) userUpdates.photo = photo;

//     if (Object.keys(userUpdates).length > 0) {
//       const updateExpression = "SET " + Object.keys(userUpdates).map((_, i) => `#k${i} = :v${i}`).join(", ");
//       const expressionAttributeNames = Object.keys(userUpdates).reduce((acc, key, i) => {
//         acc[`#k${i}`] = key;
//         return acc;
//       }, {});
//       const expressionAttributeValues = Object.values(userUpdates).reduce((acc, value, i) => {
//         acc[`:v${i}`] = value;
//         return acc;
//       }, {});

//       await dynamo.send(
//         new UpdateCommand({
//           TableName: USERS_TABLE,
//           Key: { userId },
//           UpdateExpression: updateExpression,
//           ExpressionAttributeNames: expressionAttributeNames,
//           ExpressionAttributeValues: expressionAttributeValues,
//         })
//       );
//     }

//     // Update or create profile in profiles table
//     const profileItem = {
//       userId,
//       phone: phone || "",
//       cpf: cpf || "",
//       gender: gender || "",
//       dob: dob || "",
//       address: address || {
//         street: "",
//         number: "",
//         apartment: "",
//         neighborhood: "",
//         city: "",
//         state: "",
//         zipCode: "",
//         country: "",
//         countryCode: "",
//       },
//       photo: photo || null,
//       updatedAt: new Date().toISOString(),
//     };

//     await dynamo.send(
//       new PutCommand({
//         TableName: PROFILES_TABLE,
//         Item: profileItem,
//       })
//     );

//     // Fetch updated user
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//       })
//     );

//     const updatedUser = result.Item;
//     if (updatedUser) delete updatedUser.password;

//     res.json({
//       success: true,
//       message: "Profile updated successfully",
//       profile: updatedUser,
//     });
//   } catch (err) {
//     console.error("Update profile error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to update profile",
//       error: err.message,
//     });
//   }
// };

// /* ================= GET PROFILE ================= */
// export const getProfile = async (req, res) => {
//   const userId = req.user.userId;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     // Get user from users table
//     const userResult = await dynamo.send(
//       new GetCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//       })
//     );

//     if (!userResult.Item) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found",
//       });
//     }

//     // Get profile from profiles table
//     const profileResult = await dynamo.send(
//       new GetCommand({
//         TableName: PROFILES_TABLE,
//         Key: { userId },
//       })
//     );

//     const user = userResult.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       profile: {
//         ...user,
//         ...(profileResult.Item || {}),
//       },
//     });
//   } catch (err) {
//     console.error("Get profile error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch profile",
//     });
//   }
// };

// /* ================= GET FULL USER DATA ================= */
// export const getFullUserData = async (req, res) => {
//   const userId = req.user.userId;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     // Get user
//     const userResult = await dynamo.send(
//       new GetCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//       })
//     );

//     if (!userResult.Item) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found",
//       });
//     }

//     // Get profile
//     const profileResult = await dynamo.send(
//       new GetCommand({
//         TableName: PROFILES_TABLE,
//         Key: { userId },
//       })
//     );

//     // Get chats - FIXED: Use correct key structure
//     let chats = [];
//     try {
//       const chatsResult = await dynamo.send(
//         new QueryCommand({
//           TableName: CHATS_TABLE,
//           KeyConditionExpression: "userId = :userId",
//           ExpressionAttributeValues: {
//             ":userId": userId,
//           },
//           ScanIndexForward: false,
//         })
//       );
//       chats = chatsResult.Items || [];
//     } catch (chatError) {
//       console.error("Error fetching chats:", chatError);
//       // Table might not exist yet, continue with empty chats
//     }

//     // Get cellar
//     let cellar = [];
//     try {
//       const cellarResult = await dynamo.send(
//         new GetCommand({
//           TableName: CELLAR_TABLE,
//           Key: { userId },
//         })
//       );
//       cellar = cellarResult.Item?.bottles || [];
//     } catch (cellarError) {
//       console.error("Error fetching cellar:", cellarError);
//     }

//     // Get restaurants data (saved pairings)
//     let savedPairings = [];
//     try {
//       const restaurantsResult = await dynamo.send(
//         new GetCommand({
//           TableName: RESTAURANTS_TABLE,
//           Key: { userId },
//         })
//       );
//       savedPairings = restaurantsResult.Item?.pairings || [];
//     } catch (restaurantError) {
//       console.error("Error fetching restaurants:", restaurantError);
//     }

//     const user = userResult.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       data: {
//         user: {
//           ...user,
//           ...(profileResult.Item || {}),
//         },
//         chats: chats,
//         cellar: cellar,
//         savedPairings: savedPairings,
//       },
//     });
//   } catch (err) {
//     console.error("Get full user data error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch user data",
//       error: err.message,
//     });
//   }
// };

// /* ================= SAVE CHAT ================= */
// export const saveChat = async (req, res) => {
//   const userId = req.user.userId;
//   const { chatId, title, messages } = req.body;

//   if (!userId || !chatId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing required fields",
//     });
//   }

//   try {
//     // Check if table exists by trying to query
//     await dynamo.send(
//       new PutCommand({
//         TableName: CHATS_TABLE,
//         Item: {
//           userId: userId,
//           chatId: chatId,
//           title: title || "New Chat",
//           messages: messages || [],
//           updatedAt: new Date().toISOString(),
//           createdAt: new Date().toISOString(),
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Chat saved successfully",
//     });
//   } catch (err) {
//     console.error("Save chat error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to save chat",
//       error: err.message,
//     });
//   }
// };

// /* ================= DELETE CHAT ================= */
// export const deleteChat = async (req, res) => {
//   const userId = req.user.userId;
//   const { chatId } = req.params;

//   if (!userId || !chatId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing required fields",
//     });
//   }

//   try {
//     await dynamo.send(
//       new DeleteCommand({
//         TableName: CHATS_TABLE,
//         Key: {
//           userId: userId,
//           chatId: chatId,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Chat deleted successfully",
//     });
//   } catch (err) {
//     console.error("Delete chat error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to delete chat",
//     });
//   }
// };

// /* ================= SAVE CELLAR ================= */
// export const saveCellar = async (req, res) => {
//   const userId = req.user.userId;
//   const { bottles } = req.body;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     await dynamo.send(
//       new PutCommand({
//         TableName: CELLAR_TABLE,
//         Item: {
//           userId: userId,
//           bottles: bottles || [],
//           updatedAt: new Date().toISOString(),
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Cellar saved successfully",
//     });
//   } catch (err) {
//     console.error("Save cellar error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to save cellar",
//     });
//   }
// };

// /* ================= SAVE RESTAURANT PAIRING ================= */
// export const saveRestaurantPairing = async (req, res) => {
//   const userId = req.user.userId;
//   const { pairing } = req.body;

//   if (!userId || !pairing) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing required fields",
//     });
//   }

//   try {
//     // Get existing pairings
//     let existingPairings = [];
//     try {
//       const existing = await dynamo.send(
//         new GetCommand({
//           TableName: RESTAURANTS_TABLE,
//           Key: { userId: userId },
//         })
//       );
//       existingPairings = existing.Item?.pairings || [];
//     } catch (getError) {
//       // Item might not exist yet, continue with empty array
//       console.log("No existing pairings found, creating new");
//     }

//     const updatedPairings = [pairing, ...existingPairings];

//     await dynamo.send(
//       new PutCommand({
//         TableName: RESTAURANTS_TABLE,
//         Item: {
//           userId: userId,
//           pairings: updatedPairings,
//           updatedAt: new Date().toISOString(),
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Pairing saved successfully",
//     });
//   } catch (err) {
//     console.error("Save restaurant pairing error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to save pairing",
//     });
//   }
// };





// import { UpdateCommand, GetCommand, PutCommand, QueryCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";
// import { dynamo } from "../config/dynamo.js";

// const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;
// const PROFILES_TABLE = process.env.DYNAMO_PROFILES_TABLE || "SommieProfiles";
// const CHATS_TABLE = process.env.DYNAMO_CHATS_TABLE;
// const CELLAR_TABLE = process.env.DYNAMO_CELLAR_TABLE || "SommieCellar";
// const RESTAURANTS_TABLE = process.env.DYNAMO_RESTAURANTS_TABLE || "SommieRestaurants";

// // Maximum number of pairings to store per user
// const MAX_PAIRINGS = 50;

// /* ================= UPGRADE PLAN ================= */
// export const upgradePlan = async (req, res) => {
//   const userId = req.user.userId;
//   const { plan } = req.body;

//   if (!userId || !plan) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId or plan",
//     });
//   }

//   try {
//     await dynamo.send(
//       new UpdateCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//         UpdateExpression: "SET #p = :p, subscriptionDate = :date",
//         ExpressionAttributeNames: {
//           "#p": "plan",
//         },
//         ExpressionAttributeValues: {
//           ":p": plan,
//           ":date": new Date().toISOString(),
//         },
//         ConditionExpression: "attribute_exists(userId)",
//       })
//     );

//     res.json({
//       success: true,
//       plan,
//     });
//   } catch (err) {
//     console.error("Upgrade plan error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to upgrade plan",
//     });
//   }
// };

// /* ================= UPDATE PROFILE ================= */
// export const updateProfile = async (req, res) => {
//   const userId = req.user.userId;
  
//   const {
//     name,
//     email,
//     phone,
//     cpf,
//     gender,
//     dob,
//     photo,
//     avatar,
//     role,
//     address,
//   } = req.body;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     // Update main users table
//     const userUpdates = {};
//     if (name) userUpdates.name = name;
//     if (email) userUpdates.email = email;
//     if (avatar) userUpdates.avatar = avatar;
//     if (role) userUpdates.role = role;
//     if (photo) userUpdates.photo = photo;

//     if (Object.keys(userUpdates).length > 0) {
//       const updateExpression = "SET " + Object.keys(userUpdates).map((_, i) => `#k${i} = :v${i}`).join(", ");
//       const expressionAttributeNames = Object.keys(userUpdates).reduce((acc, key, i) => {
//         acc[`#k${i}`] = key;
//         return acc;
//       }, {});
//       const expressionAttributeValues = Object.values(userUpdates).reduce((acc, value, i) => {
//         acc[`:v${i}`] = value;
//         return acc;
//       }, {});

//       await dynamo.send(
//         new UpdateCommand({
//           TableName: USERS_TABLE,
//           Key: { userId },
//           UpdateExpression: updateExpression,
//           ExpressionAttributeNames: expressionAttributeNames,
//           ExpressionAttributeValues: expressionAttributeValues,
//         })
//       );
//     }

//     // Update or create profile in profiles table
//     const profileItem = {
//       userId,
//       phone: phone || "",
//       cpf: cpf || "",
//       gender: gender || "",
//       dob: dob || "",
//       address: address || {
//         street: "",
//         number: "",
//         apartment: "",
//         neighborhood: "",
//         city: "",
//         state: "",
//         zipCode: "",
//         country: "",
//         countryCode: "",
//       },
//       photo: photo || null,
//       updatedAt: new Date().toISOString(),
//     };

//     await dynamo.send(
//       new PutCommand({
//         TableName: PROFILES_TABLE,
//         Item: profileItem,
//       })
//     );

//     // Fetch updated user
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//       })
//     );

//     const updatedUser = result.Item;
//     if (updatedUser) delete updatedUser.password;

//     res.json({
//       success: true,
//       message: "Profile updated successfully",
//       profile: updatedUser,
//     });
//   } catch (err) {
//     console.error("Update profile error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to update profile",
//       error: err.message,
//     });
//   }
// };

// /* ================= GET PROFILE ================= */
// export const getProfile = async (req, res) => {
//   const userId = req.user.userId;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     // Get user from users table
//     const userResult = await dynamo.send(
//       new GetCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//       })
//     );

//     if (!userResult.Item) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found",
//       });
//     }

//     // Get profile from profiles table
//     const profileResult = await dynamo.send(
//       new GetCommand({
//         TableName: PROFILES_TABLE,
//         Key: { userId },
//       })
//     );

//     const user = userResult.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       profile: {
//         ...user,
//         ...(profileResult.Item || {}),
//       },
//     });
//   } catch (err) {
//     console.error("Get profile error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch profile",
//     });
//   }
// };

// /* ================= GET FULL USER DATA ================= */
// export const getFullUserData = async (req, res) => {
//   const userId = req.user.userId;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     // Get user
//     const userResult = await dynamo.send(
//       new GetCommand({
//         TableName: USERS_TABLE,
//         Key: { userId },
//       })
//     );

//     if (!userResult.Item) {
//       return res.status(404).json({
//         success: false,
//         message: "User not found",
//       });
//     }

//     // Get profile
//     const profileResult = await dynamo.send(
//       new GetCommand({
//         TableName: PROFILES_TABLE,
//         Key: { userId },
//       })
//     );

//     // Get chats
//     let chats = [];
//     try {
//       const chatsResult = await dynamo.send(
//         new QueryCommand({
//           TableName: CHATS_TABLE,
//           KeyConditionExpression: "userId = :userId",
//           ExpressionAttributeValues: {
//             ":userId": userId,
//           },
//           ScanIndexForward: false,
//         })
//       );
//       chats = chatsResult.Items || [];
//     } catch (chatError) {
//       console.error("Error fetching chats:", chatError);
//     }

//     // Get cellar
//     let cellar = [];
//     try {
//       const cellarResult = await dynamo.send(
//         new GetCommand({
//           TableName: CELLAR_TABLE,
//           Key: { userId },
//         })
//       );
//       cellar = cellarResult.Item?.bottles || [];
//     } catch (cellarError) {
//       console.error("Error fetching cellar:", cellarError);
//     }

//     // Get restaurants data (saved pairings)
//     let savedPairings = [];
//     try {
//       const restaurantsResult = await dynamo.send(
//         new GetCommand({
//           TableName: RESTAURANTS_TABLE,
//           Key: { userId },
//         })
//       );
//       savedPairings = restaurantsResult.Item?.pairings || [];
//     } catch (restaurantError) {
//       console.error("Error fetching restaurants:", restaurantError);
//     }

//     const user = userResult.Item;
//     delete user.password;

//     res.json({
//       success: true,
//       data: {
//         user: {
//           ...user,
//           ...(profileResult.Item || {}),
//         },
//         chats: chats,
//         cellar: cellar,
//         savedPairings: savedPairings,
//       },
//     });
//   } catch (err) {
//     console.error("Get full user data error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch user data",
//       error: err.message,
//     });
//   }
// };

// /* ================= SAVE CHAT ================= */
// export const saveChat = async (req, res) => {
//   const userId = req.user.userId;
//   const { chatId, title, messages } = req.body;

//   if (!userId || !chatId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing required fields",
//     });
//   }

//   try {
//     await dynamo.send(
//       new PutCommand({
//         TableName: CHATS_TABLE,
//         Item: {
//           userId: userId,
//           chatId: chatId,
//           title: title || "New Chat",
//           messages: messages || [],
//           updatedAt: new Date().toISOString(),
//           createdAt: new Date().toISOString(),
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Chat saved successfully",
//     });
//   } catch (err) {
//     console.error("Save chat error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to save chat",
//       error: err.message,
//     });
//   }
// };

// /* ================= DELETE CHAT ================= */
// export const deleteChat = async (req, res) => {
//   const userId = req.user.userId;
//   const { chatId } = req.params;

//   if (!userId || !chatId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing required fields",
//     });
//   }

//   try {
//     await dynamo.send(
//       new DeleteCommand({
//         TableName: CHATS_TABLE,
//         Key: {
//           userId: userId,
//           chatId: chatId,
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Chat deleted successfully",
//     });
//   } catch (err) {
//     console.error("Delete chat error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to delete chat",
//     });
//   }
// };

// /* ================= SAVE CELLAR ================= */
// export const saveCellar = async (req, res) => {
//   const userId = req.user.userId;
//   const { bottles } = req.body;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     await dynamo.send(
//       new PutCommand({
//         TableName: CELLAR_TABLE,
//         Item: {
//           userId: userId,
//           bottles: bottles || [],
//           updatedAt: new Date().toISOString(),
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Cellar saved successfully",
//     });
//   } catch (err) {
//     console.error("Save cellar error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to save cellar",
//     });
//   }
// };

// /* ================= GET RESTAURANT PAIRINGS ================= */
// export const getRestaurantPairings = async (req, res) => {
//   const userId = req.user.userId;

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   try {
//     const result = await dynamo.send(
//       new GetCommand({
//         TableName: RESTAURANTS_TABLE,
//         Key: { userId },
//       })
//     );

//     const pairings = result.Item?.pairings || [];

//     res.json({
//       success: true,
//       data: pairings,
//     });
//   } catch (err) {
//     console.error("Get restaurant pairings error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch pairings",
//       error: err.message,
//     });
//   }
// };

// /* ================= SAVE RESTAURANT PAIRING - OPTIMIZED ================= */
// export const saveRestaurantPairing = async (req, res) => {
//   const userId = req.user.userId;
//   const { pairing } = req.body;  // Only accept single pairing now

//   if (!userId) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing userId",
//     });
//   }

//   if (!pairing) {
//     return res.status(400).json({
//       success: false,
//       message: "Missing pairing data",
//     });
//   }

//   try {
//     // Get existing pairings
//     let existingPairings = [];
//     try {
//       const existing = await dynamo.send(
//         new GetCommand({
//           TableName: RESTAURANTS_TABLE,
//           Key: { userId: userId },
//         })
//       );
//       existingPairings = existing.Item?.pairings || [];
//     } catch (getError) {
//       console.log("No existing pairings found, creating new");
//     }

//     // Check for duplicate (prevents saving the same pairing twice)
//     const isDuplicate = existingPairings.some(p => 
//       p.id === pairing.id || 
//       (p.dish?.name === pairing.dish?.name && 
//        p.savedAt === pairing.savedAt)
//     );

//     if (isDuplicate) {
//       return res.json({
//         success: true,
//         message: "Pairing already exists",
//         data: existingPairings,
//       });
//     }

//     // Add new pairing to the beginning of the array
//     let updatedPairings = [pairing, ...existingPairings];

//     // Limit the number of pairings stored (prevents unlimited growth)
//     if (updatedPairings.length > MAX_PAIRINGS) {
//       updatedPairings = updatedPairings.slice(0, MAX_PAIRINGS);
//       console.log(`Trimmed pairings to ${MAX_PAIRINGS} items`);
//     }

//     // Calculate approximate payload size for logging
//     const payloadSize = JSON.stringify(updatedPairings).length;
//     console.log(`Saving ${updatedPairings.length} pairings (${payloadSize} bytes) for user ${userId}`);

//     await dynamo.send(
//       new PutCommand({
//         TableName: RESTAURANTS_TABLE,
//         Item: {
//           userId: userId,
//           pairings: updatedPairings,
//           updatedAt: new Date().toISOString(),
//         },
//       })
//     );

//     res.json({
//       success: true,
//       message: "Pairing saved successfully",
//       data: updatedPairings,
//     });
//   } catch (err) {
//     console.error("Save restaurant pairing error:", err);
    
//     // Check for payload too large error
//     if (err.code === 'ValidationException' && err.message.includes('size')) {
//       return res.status(413).json({
//         success: false,
//         message: "Pairing data too large. Please try with a smaller image.",
//         error: "Payload too large",
//       });
//     }
    
//     res.status(500).json({
//       success: false,
//       message: "Failed to save pairing",
//       error: err.message,
//     });
//   }
// };




import Stripe from 'stripe';
import { UpdateCommand, GetCommand, PutCommand, QueryCommand, DeleteCommand } from "@aws-sdk/lib-dynamodb";
import { dynamo } from "../config/dynamo.js";

// Initialize Stripe
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2025-02-24.acacia',
});

const USERS_TABLE = process.env.DYNAMO_USERS_TABLE;
const PROFILES_TABLE = process.env.DYNAMO_PROFILES_TABLE || "SommieProfiles";
const CHATS_TABLE = process.env.DYNAMO_CHATS_TABLE;
const CELLAR_TABLE = process.env.DYNAMO_CELLAR_TABLE || "SommieCellar";
const RESTAURANTS_TABLE = process.env.DYNAMO_RESTAURANTS_TABLE || "SommieRestaurants";
const PAYMENTS_TABLE = process.env.DYNAMO_PAYMENTS_TABLE || "SommiePaymentsNew";
const PAYMENT_METHODS_TABLE = process.env.DYNAMO_PAYMENT_METHODS_TABLE || "SommiePaymentMethods";

// Maximum number of pairings to store per user
const MAX_PAIRINGS = 500;

/* ================= VERIFY PAYMENT ================= */
export const verifyPayment = async (req, res) => {
  const userId = req.user.userId;
  const { paymentIntentId, couponCode, discountPercent, originalAmount } = req.body;

  console.log("🔍 Verifying payment:", { paymentIntentId, userId, couponCode });

  if (!paymentIntentId) {
    return res.status(400).json({
      success: false,
      message: "Payment intent ID is required",
    });
  }

  try {
    // Check if payment already exists
    const existingPayment = await dynamo.send(
      new GetCommand({
        TableName: PAYMENTS_TABLE,
        Key: { paymentIntentId },
      })
    );

    if (existingPayment.Item) {
      console.log("⚠️ Payment already verified:", paymentIntentId);
      return res.json({
        success: true,
        message: "Payment already verified",
        payment: existingPayment.Item,
      });
    }

    // Get payment intent from Stripe
    console.log("🔄 Retrieving payment intent from Stripe...");
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (!paymentIntent) {
      return res.status(404).json({
        success: false,
        message: "Payment intent not found",
      });
    }

    console.log("✅ Payment intent retrieved:", paymentIntent.id);

    // Get payment method details
    let paymentMethodDetails = null;
    if (paymentIntent.payment_method) {
      try {
        const paymentMethod = await stripe.paymentMethods.retrieve(
          paymentIntent.payment_method
        );

        if (paymentMethod.type === "card") {
          paymentMethodDetails = {
            type: "card",
            brand: paymentMethod.card.brand,
            last4: paymentMethod.card.last4,
            expMonth: paymentMethod.card.exp_month,
            expYear: paymentMethod.card.exp_year,
            stripePaymentMethodId: paymentMethod.id,
          };
          console.log("💳 Payment method details:", paymentMethodDetails);
        }
      } catch (err) {
        console.error("Error fetching payment method:", err);
      }
    }

    // Save payment
    const payment = {
      paymentIntentId: paymentIntent.id,
      userId: userId,
      planId: paymentIntent.metadata?.planId || "monthly",
      amount: paymentIntent.amount,
      originalAmount: originalAmount ? parseInt(originalAmount) : null,
      currency: paymentIntent.currency,
      status: "succeeded",
      createdAt: new Date().toISOString(),
      paymentMethod: paymentMethodDetails,
      couponCode: couponCode || null,
      discountPercent: discountPercent ? parseInt(discountPercent) : null,
    };

    console.log("💾 Saving payment to DynamoDB...");
    await dynamo.send(
      new PutCommand({
        TableName: PAYMENTS_TABLE,
        Item: payment,
      })
    );
    console.log("✅ Payment saved");

    // Save payment method if not exists
    if (paymentMethodDetails) {
      const existingMethod = await dynamo.send(
        new QueryCommand({
          TableName: PAYMENT_METHODS_TABLE,
          KeyConditionExpression: "userId = :userId AND paymentMethodId = :pmId",
          ExpressionAttributeValues: {
            ":userId": userId,
            ":pmId": paymentMethodDetails.stripePaymentMethodId,
          },
        })
      );

      if (!existingMethod.Items || existingMethod.Items.length === 0) {
        await dynamo.send(
          new PutCommand({
            TableName: PAYMENT_METHODS_TABLE,
            Item: {
              userId: userId,
              paymentMethodId: paymentMethodDetails.stripePaymentMethodId,
              brand: paymentMethodDetails.brand,
              last4: paymentMethodDetails.last4,
              expMonth: paymentMethodDetails.expMonth,
              expYear: paymentMethodDetails.expYear,
              isDefault: true,
              createdAt: new Date().toISOString(),
            },
          })
        );
        console.log("✅ Payment method saved to DB");
      }
    }

    res.json({
      success: true,
      message: "Payment verified and saved",
      payment,
    });
  } catch (error) {
    console.error("Error verifying payment:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify payment",
      error: error.message,
    });
  }
};

/* ================= UPDATE PROFILE ================= */
export const updateProfile = async (req, res) => {
  const userId = req.user.userId;
  
  const {
    name,
    email,
    phone,
    cpf,
    gender,
    dob,
    photo,
    avatar,
    role,
    address,
  } = req.body;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    // Update main users table
    const userUpdates = {};
    if (name) userUpdates.name = name;
    if (email) userUpdates.email = email;
    if (avatar) userUpdates.avatar = avatar;
    if (role) userUpdates.role = role;
    if (photo) userUpdates.photo = photo;

    if (Object.keys(userUpdates).length > 0) {
      const updateExpression = "SET " + Object.keys(userUpdates).map((_, i) => `#k${i} = :v${i}`).join(", ");
      const expressionAttributeNames = Object.keys(userUpdates).reduce((acc, key, i) => {
        acc[`#k${i}`] = key;
        return acc;
      }, {});
      const expressionAttributeValues = Object.values(userUpdates).reduce((acc, value, i) => {
        acc[`:v${i}`] = value;
        return acc;
      }, {});

      await dynamo.send(
        new UpdateCommand({
          TableName: USERS_TABLE,
          Key: { userId },
          UpdateExpression: updateExpression,
          ExpressionAttributeNames: expressionAttributeNames,
          ExpressionAttributeValues: expressionAttributeValues,
        })
      );
    }

    // Update or create profile in profiles table
    const profileItem = {
      userId,
      phone: phone || "",
      cpf: cpf || "",
      gender: gender || "",
      dob: dob || "",
      address: address || {
        street: "",
        number: "",
        apartment: "",
        neighborhood: "",
        city: "",
        state: "",
        zipCode: "",
        country: "",
        countryCode: "",
      },
      photo: photo || null,
      updatedAt: new Date().toISOString(),
    };

    await dynamo.send(
      new PutCommand({
        TableName: PROFILES_TABLE,
        Item: profileItem,
      })
    );

    // Fetch updated user
    const result = await dynamo.send(
      new GetCommand({
        TableName: USERS_TABLE,
        Key: { userId },
      })
    );

    const updatedUser = result.Item;
    if (updatedUser) delete updatedUser.password;

    // Also fetch profile data
    const profileResult = await dynamo.send(
      new GetCommand({
        TableName: PROFILES_TABLE,
        Key: { userId },
      })
    );

    res.json({
      success: true,
      message: "Profile updated successfully",
      profile: {
        ...updatedUser,
        ...(profileResult.Item || {}),
      },
    });
  } catch (err) {
    console.error("Update profile error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to update profile",
      error: err.message,
    });
  }
};

/* ================= GET PROFILE ================= */
export const getProfile = async (req, res) => {
  const userId = req.user.userId;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    // Get user from users table
    const userResult = await dynamo.send(
      new GetCommand({
        TableName: USERS_TABLE,
        Key: { userId },
      })
    );

    if (!userResult.Item) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Get profile from profiles table
    const profileResult = await dynamo.send(
      new GetCommand({
        TableName: PROFILES_TABLE,
        Key: { userId },
      })
    );

    const user = userResult.Item;
    delete user.password;

    res.json({
      success: true,
      profile: {
        ...user,
        ...(profileResult.Item || {}),
      },
    });
  } catch (err) {
    console.error("Get profile error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch profile",
    });
  }
};

/* ================= GET FULL USER DATA ================= */
export const getFullUserData = async (req, res) => {
  const userId = req.user.userId;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    // Get user
    const userResult = await dynamo.send(
      new GetCommand({
        TableName: USERS_TABLE,
        Key: { userId },
      })
    );

    if (!userResult.Item) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Get profile
    const profileResult = await dynamo.send(
      new GetCommand({
        TableName: PROFILES_TABLE,
        Key: { userId },
      })
    );

    // Get chats
    let chats = [];
    try {
      const chatsResult = await dynamo.send(
        new QueryCommand({
          TableName: CHATS_TABLE,
          KeyConditionExpression: "userId = :userId",
          ExpressionAttributeValues: {
            ":userId": userId,
          },
          ScanIndexForward: false,
        })
      );
      chats = chatsResult.Items || [];
    } catch (chatError) {
      console.error("Error fetching chats:", chatError);
    }

    // Get cellar
    let cellar = [];
    try {
      const cellarResult = await dynamo.send(
        new GetCommand({
          TableName: CELLAR_TABLE,
          Key: { userId },
        })
      );
      cellar = cellarResult.Item?.bottles || [];
    } catch (cellarError) {
      console.error("Error fetching cellar:", cellarError);
    }

    // Get restaurants data (saved pairings)
    let savedPairings = [];
    try {
      const restaurantsResult = await dynamo.send(
        new GetCommand({
          TableName: RESTAURANTS_TABLE,
          Key: { userId },
        })
      );
      savedPairings = restaurantsResult.Item?.pairings || [];
    } catch (restaurantError) {
      console.error("Error fetching restaurants:", restaurantError);
    }

    const user = userResult.Item;
    delete user.password;

    res.json({
      success: true,
      data: {
        user: {
          ...user,
          ...(profileResult.Item || {}),
        },
        chats: chats,
        cellar: cellar,
        savedPairings: savedPairings,
      },
    });
  } catch (err) {
    console.error("Get full user data error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch user data",
      error: err.message,
    });
  }
};

/* ================= SAVE CHAT ================= */
export const saveChat = async (req, res) => {
  const userId = req.user.userId;
  const { chatId, title, messages } = req.body;

  if (!userId || !chatId) {
    return res.status(400).json({
      success: false,
      message: "Missing required fields",
    });
  }

  try {
    await dynamo.send(
      new PutCommand({
        TableName: CHATS_TABLE,
        Item: {
          userId: userId,
          chatId: chatId,
          title: title || "New Chat",
          messages: messages || [],
          updatedAt: new Date().toISOString(),
          createdAt: new Date().toISOString(),
        },
      })
    );

    res.json({
      success: true,
      message: "Chat saved successfully",
    });
  } catch (err) {
    console.error("Save chat error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to save chat",
      error: err.message,
    });
  }
};

/* ================= DELETE CHAT ================= */
export const deleteChat = async (req, res) => {
  const userId = req.user.userId;
  const { chatId } = req.params;

  if (!userId || !chatId) {
    return res.status(400).json({
      success: false,
      message: "Missing required fields",
    });
  }

  try {
    await dynamo.send(
      new DeleteCommand({
        TableName: CHATS_TABLE,
        Key: {
          userId: userId,
          chatId: chatId,
        },
      })
    );

    res.json({
      success: true,
      message: "Chat deleted successfully",
    });
  } catch (err) {
    console.error("Delete chat error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to delete chat",
    });
  }
};

/* ================= SAVE CELLAR ================= */
export const saveCellar = async (req, res) => {
  const userId = req.user.userId;
  const { bottles } = req.body;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    await dynamo.send(
      new PutCommand({
        TableName: CELLAR_TABLE,
        Item: {
          userId: userId,
          bottles: bottles || [],
          updatedAt: new Date().toISOString(),
        },
      })
    );

    res.json({
      success: true,
      message: "Cellar saved successfully",
    });
  } catch (err) {
    console.error("Save cellar error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to save cellar",
    });
  }
};

/* ================= GET RESTAURANT PAIRINGS ================= */
export const getRestaurantPairings = async (req, res) => {
  const userId = req.user.userId;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    const result = await dynamo.send(
      new GetCommand({
        TableName: RESTAURANTS_TABLE,
        Key: { userId },
      })
    );

    const pairings = result.Item?.pairings || [];

    res.json({
      success: true,
      data: pairings,
    });
  } catch (err) {
    console.error("Get restaurant pairings error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch pairings",
      error: err.message,
    });
  }
};

/* ================= SAVE RESTAURANT PAIRING ================= */
export const saveRestaurantPairing = async (req, res) => {
  const userId = req.user.userId;
  const { pairing } = req.body;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  if (!pairing) {
    return res.status(400).json({
      success: false,
      message: "Missing pairing data",
    });
  }

  try {
    // Get existing pairings
    let existingPairings = [];
    try {
      const existing = await dynamo.send(
        new GetCommand({
          TableName: RESTAURANTS_TABLE,
          Key: { userId: userId },
        })
      );
      existingPairings = existing.Item?.pairings || [];
    } catch (getError) {
      console.log("No existing pairings found, creating new");
    }

    // Check for duplicate
    const isDuplicate = existingPairings.some(p => 
      p.id === pairing.id || 
      (p.dish?.name === pairing.dish?.name && 
       p.savedAt === pairing.savedAt)
    );

    if (isDuplicate) {
      return res.json({
        success: true,
        message: "Pairing already exists",
        data: existingPairings,
      });
    }

    // Add new pairing to the beginning
    let updatedPairings = [pairing, ...existingPairings];

    // Limit number of pairings
    if (updatedPairings.length > MAX_PAIRINGS) {
      updatedPairings = updatedPairings.slice(0, MAX_PAIRINGS);
      console.log(`Trimmed pairings to ${MAX_PAIRINGS} items`);
    }

    await dynamo.send(
      new PutCommand({
        TableName: RESTAURANTS_TABLE,
        Item: {
          userId: userId,
          pairings: updatedPairings,
          updatedAt: new Date().toISOString(),
        },
      })
    );

    res.json({
      success: true,
      message: "Pairing saved successfully",
      data: updatedPairings,
    });
  } catch (err) {
    console.error("Save restaurant pairing error:", err);
    
    if (err.code === 'ValidationException' && err.message.includes('size')) {
      return res.status(413).json({
        success: false,
        message: "Pairing data too large. Please try with a smaller image.",
        error: "Payload too large",
      });
    }
    
    res.status(500).json({
      success: false,
      message: "Failed to save pairing",
      error: err.message,
    });
  }
};

/* ================= GET USER PAYMENTS ================= */
export const getUserPayments = async (req, res) => {
  const userId = req.user.userId;
  const { userId: paramUserId } = req.params;

  if (userId !== paramUserId) {
    return res.status(403).json({
      success: false,
      message: "Unauthorized access to payment records",
    });
  }

  try {
    const result = await dynamo.send(
      new QueryCommand({
        TableName: PAYMENTS_TABLE,
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: {
          ":userId": userId,
        },
        ScanIndexForward: false,
      })
    );

    res.json({
      success: true,
      payments: result.Items || [],
    });
  } catch (error) {
    console.error("Error fetching user payments:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch payment history",
      error: error.message,
    });
  }
};

/* ================= GET PAYMENT METHODS ================= */
export const getPaymentMethods = async (req, res) => {
  const userId = req.user.userId;
  const { userId: paramUserId } = req.params;

  if (userId !== paramUserId) {
    return res.status(403).json({
      success: false,
      message: "Unauthorized access to payment methods",
    });
  }

  try {
    const result = await dynamo.send(
      new QueryCommand({
        TableName: PAYMENT_METHODS_TABLE,
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: {
          ":userId": userId,
        },
      })
    );

    res.json({
      success: true,
      paymentMethods: result.Items || [],
    });
  } catch (error) {
    console.error("Error fetching payment methods:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch payment methods",
    });
  }
};

/* ================= SET DEFAULT PAYMENT METHOD ================= */
export const setDefaultPaymentMethod = async (req, res) => {
  const userId = req.user.userId;
  const { paymentMethodId } = req.body;

  if (!paymentMethodId) {
    return res.status(400).json({
      success: false,
      message: "Payment method ID is required",
    });
  }

  try {
    // Get all existing methods
    const existingMethods = await dynamo.send(
      new QueryCommand({
        TableName: PAYMENT_METHODS_TABLE,
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: {
          ":userId": userId,
        },
      })
    );

    // Update all to not default
    for (const method of existingMethods.Items || []) {
      await dynamo.send(
        new UpdateCommand({
          TableName: PAYMENT_METHODS_TABLE,
          Key: {
            userId: userId,
            paymentMethodId: method.paymentMethodId,
          },
          UpdateExpression: "SET isDefault = :default",
          ExpressionAttributeValues: {
            ":default": false,
          },
        })
      );
    }

    // Set the selected one as default
    await dynamo.send(
      new UpdateCommand({
        TableName: PAYMENT_METHODS_TABLE,
        Key: {
          userId: userId,
          paymentMethodId: paymentMethodId,
        },
        UpdateExpression: "SET isDefault = :default, updatedAt = :date",
        ExpressionAttributeValues: {
          ":default": true,
          ":date": new Date().toISOString(),
        },
      })
    );

    res.json({
      success: true,
      message: "Default payment method updated",
    });
  } catch (error) {
    console.error("Error setting default payment method:", error);
    res.status(500).json({
      success: false,
      message: "Failed to set default payment method",
    });
  }
};

/* ================= DELETE PAYMENT METHOD ================= */
export const deletePaymentMethod = async (req, res) => {
  const userId = req.user.userId;
  const { paymentMethodId } = req.params;

  if (!paymentMethodId) {
    return res.status(400).json({
      success: false,
      message: "Payment method ID is required",
    });
  }

  try {
    await dynamo.send(
      new DeleteCommand({
        TableName: PAYMENT_METHODS_TABLE,
        Key: {
          userId: userId,
          paymentMethodId: paymentMethodId,
        },
      })
    );

    res.json({
      success: true,
      message: "Payment method deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting payment method:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete payment method",
    });
  }
};

/* ================= GET CELLAR ================= */
export const getCellar = async (req, res) => {
  const userId = req.user.userId;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    const result = await dynamo.send(
      new GetCommand({
        TableName: CELLAR_TABLE,
        Key: { userId },
      })
    );

    const bottles = result.Item?.bottles || [];

    res.json({
      success: true,
      bottles: bottles,
    });
  } catch (err) {
    console.error("Get cellar error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch cellar",
      error: err.message,
    });
  }
};


/* ================= GET CHATS ================= */
export const getChats = async (req, res) => {
  const userId = req.user.userId;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "Missing userId",
    });
  }

  try {
    const result = await dynamo.send(
      new QueryCommand({
        TableName: CHATS_TABLE,
        KeyConditionExpression: "userId = :uid",
        ExpressionAttributeValues: {
          ":uid": userId,
        },
      })
    );

    res.json({
      success: true,
      chats: result.Items || [],
    });
  } catch (err) {
    console.error("Get chats error:", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch chats",
      error: err.message,
    });
  }
};