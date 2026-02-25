// import express from "express";
// import User from "../controllers/user.controller.js";

// const router = express.Router();

// router.get("/analytics", async (req, res) => {
//   try {
//     const { plan } = req.query;

//     const users = await User.find(
//       plan ? { plan } : {}
//     );

//     const age = { "18-25": 0, "26-35": 0, "36+": 0 };
//     const gender = {};
//     const country = {};

//     users.forEach((u) => {
//       if (u.age <= 25) age["18-25"]++;
//       else if (u.age <= 35) age["26-35"]++;
//       else age["36+"]++;

//       gender[u.gender] = (gender[u.gender] || 0) + 1;
//       country[u.country] = (country[u.country] || 0) + 1;
//     });

//     res.json({
//       age: Object.entries(age).map(([label, value]) => ({ label, value })),
//       gender: Object.entries(gender).map(([label, value]) => ({ label, value })),
//       country: Object.entries(country).map(([label, value]) => ({ label, value })),
//     });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: "Analytics error" });
//   }
// });

// export default router;


// import express from "express";
// import { dynamo } from "../config/dynamo.js";
// import { ScanCommand } from "@aws-sdk/lib-dynamodb";

// const router = express.Router();

// router.get("/analytics", async (req, res) => {
//   try {
//     const { plan } = req.query;
//     const TABLE = process.env.DYNAMO_USERS_TABLE;

//     // DynamoDB Scan operation (careful with large datasets)
//     const scanParams = {
//       TableName: TABLE,
//     };

//     // If filtering by plan, add FilterExpression
//     if (plan) {
//       scanParams.FilterExpression = "#p = :plan";
//       scanParams.ExpressionAttributeNames = {
//         "#p": "plan"
//       };
//       scanParams.ExpressionAttributeValues = {
//         ":plan": plan
//       };
//     }

//     const result = await dynamo.send(new ScanCommand(scanParams));
//     const users = result.Items || [];

//     // Initialize counters
//     const ageGroups = { "18-25": 0, "26-35": 0, "36+": 0 };
//     const gender = {};
//     const country = {};

//     // Process each user
//     users.forEach((u) => {
//       const age = parseInt(u.age) || 0;
      
//       if (age <= 25) ageGroups["18-25"]++;
//       else if (age <= 35) ageGroups["26-35"]++;
//       else ageGroups["36+"]++;

//       // Count gender
//       const userGender = u.gender || "unknown";
//       gender[userGender] = (gender[userGender] || 0) + 1;

//       // Count country
//       const userCountry = u.country || "unknown";
//       country[userCountry] = (country[userCountry] || 0) + 1;
//     });

//     res.json({
//       age: Object.entries(ageGroups).map(([label, value]) => ({ label, value })),
//       gender: Object.entries(gender).map(([label, value]) => ({ label, value })),
//       country: Object.entries(country).map(([label, value]) => ({ label, value })),
//       totalUsers: users.length
//     });
//   } catch (err) {
//     console.error("Analytics error:", err);
//     res.status(500).json({ message: "Analytics error", error: err.message });
//   }
// });

// export default router;

// import express from "express";
// import { dynamo } from "../config/dynamo.js";
// import { ScanCommand } from "@aws-sdk/lib-dynamodb";

// const router = express.Router();

// router.get("/analytics", async (req, res) => {
//   try {
//     const { plan } = req.query;
//     const TABLE = process.env.DYNAMO_USERS_TABLE;

//     const scanParams = {
//       TableName: TABLE,
//     };

//     if (plan) {
//       scanParams.FilterExpression = "#p = :plan";
//       scanParams.ExpressionAttributeNames = { "#p": "plan" };
//       scanParams.ExpressionAttributeValues = { ":plan": plan };
//     }

//     const result = await dynamo.send(new ScanCommand(scanParams));
//     const users = result.Items || [];

//     // ---- Counters ----
//     const ageGroups = { "18-25": 0, "26-35": 0, "36+": 0 };
//     const gender = {};
//     const country = {};

//     let validAgeCount = 0;
//     let validGenderCount = 0;
//     let validCountryCount = 0;

//     users.forEach((u) => {
//       // ---- AGE ----
//       if (u.age && !isNaN(Number(u.age))) {
//         const age = Number(u.age);
//         validAgeCount++;

//         if (age <= 25) ageGroups["18-25"]++;
//         else if (age <= 35) ageGroups["26-35"]++;
//         else ageGroups["36+"]++;
//       }

//       // ---- GENDER ----
//       if (u.gender && u.gender !== "unknown") {
//         validGenderCount++;
//         gender[u.gender] = (gender[u.gender] || 0) + 1;
//       }

//       // ---- COUNTRY ----
//       if (u.country && u.country !== "unknown") {
//         validCountryCount++;
//         country[u.country] = (country[u.country] || 0) + 1;
//       }
//     });

//     // ---- Convert to percentages ----
//     const toPercent = (obj, total) =>
//       Object.entries(obj).map(([label, value]) => ({
//         label,
//         value,
//         percent: total ? Math.round((value / total) * 100) : 0,
//       }));

//     res.json({
//       age: toPercent(ageGroups, validAgeCount),
//       gender: toPercent(gender, validGenderCount),
//       country: toPercent(country, validCountryCount),
//       meta: {
//         totalUsers: users.length,
//         withAge: validAgeCount,
//         withGender: validGenderCount,
//         withCountry: validCountryCount,
//       },
//     });
//   } catch (err) {
//     console.error("Analytics error:", err);
//     res.status(500).json({ message: "Analytics error" });
//   }
// });

// export default router;


import express from "express";
import { dynamo } from "../config/dynamo.js";
import { ScanCommand } from "@aws-sdk/lib-dynamodb";

const router = express.Router();

/* ===============================
   TOP USERS (ADMIN TABLE)
================================ */
router.get("/top-users", async (req, res) => {
  try {
    const TABLE = process.env.DYNAMO_USERS_TABLE;

    const result = await dynamo.send(
      new ScanCommand({
        TableName: TABLE,
      })
    );

    const users = result.Items || [];

    // 🔥 Normalize + compute stats
    const normalized = users.map((u) => ({
      userId: u.userId,
      name: u.name || "Unknown",
      email: u.email || "-",
      questions: Number(u.questions || 0),
      answers: Number(u.answers || 0),
      conversations: Number(u.conversations || 0),
      lastActive: u.lastActive || u.createdAt || "",
    }));

    // 🔥 Sort by conversations
    normalized.sort((a, b) => b.conversations - a.conversations);

    // 🔥 Top 10 only
    res.json(normalized.slice(0, 10));
  } catch (err) {
    console.error("Top users error:", err);
    res.status(500).json({ message: "Failed to load top users" });
  }
});

router.get("/analytics", async (req, res) => {
  try {
    const { plan } = req.query;
    const TABLE = process.env.DYNAMO_USERS_TABLE;

    const params = { TableName: TABLE };

    if (plan) {
      params.FilterExpression = "#p = :plan";
      params.ExpressionAttributeNames = { "#p": "plan" };
      params.ExpressionAttributeValues = { ":plan": plan };
    }

    const result = await dynamo.send(new ScanCommand(params));
    const users = result.Items || [];

    const age = { "18-25": 0, "26-35": 0, "36+": 0 };
    const gender = {};
    const country = {};

    users.forEach((u) => {
      if (typeof u.age === "number") {
        if (u.age <= 25) age["18-25"]++;
        else if (u.age <= 35) age["26-35"]++;
        else age["36+"]++;
      }

      if (u.gender) gender[u.gender] = (gender[u.gender] || 0) + 1;
      if (u.country) country[u.country] = (country[u.country] || 0) + 1;
    });

    const toArray = (obj) =>
      Object.entries(obj).map(([label, value]) => ({
        label,
        value,
      }));

    res.json({
      age: toArray(age),
      gender: toArray(gender),
      country: toArray(country),
      totalUsers: users.length,
    });
  } catch (err) {
    console.error("Analytics error:", err);
    res.status(500).json({ message: "Analytics error" });
  }
});

export default router;
