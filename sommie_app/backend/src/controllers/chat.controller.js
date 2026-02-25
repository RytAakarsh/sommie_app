// import axios from "axios";

// export const chat = async (req, res) => {
//   const { message } = req.body;
//   const response = await axios.post(process.env.AI_API_URL, { message });
//   res.json({ reply: response.data.reply || response.data });
// };


// import axios from "axios";

// export const chat = async (req, res) => {
//   try {
//     const { message } = req.body;

//     if (!message) {
//       return res.status(400).json({ message: "Message is required" });
//     }

//     const response = await axios.post(
//       process.env.AI_API_URL,
//       {
//         input: message, // 👈 IMPORTANT (AWS usually expects `input`)
//       },
//       {
//         headers: {
//           "Content-Type": "application/json",
//         },
//       }
//     );

//     return res.json({
//       reply: response.data.reply || response.data.output || response.data,
//     });
//   } catch (err) {
//     console.error("AI API ERROR:", err.response?.data || err.message);
//     return res.status(500).json({ message: "AI service failed" });
//   }
// };


// import axios from "axios";

// export const chat = async (req, res) => {
//   try {
//     const { message, session_id, user_id } = req.body;

//     if (!message || !session_id || !user_id) {
//       return res.status(400).json({
//         error: "message, session_id and user_id are required",
//       });
//     }

//     const response = await axios.post(
//       process.env.AI_API_URL,
//       {
//         session_id,
//         user_id,
//         message
//       },
//       {
//         headers: {
//           "Content-Type": "application/json"
//         }
//       }
//     );

//     return res.json({
//       answer: response.data.answer,
//       session_id: response.data.session_id,
//       ok: response.data.ok
//     });

//   } catch (error) {
//     console.error("iTrois error:", error?.response?.data || error.message);
//     return res.status(500).json({
//       error: "AI service failed",
//       details: error?.response?.data
//     });
//   }
// };


// import axios from "axios";

// export const chat = async (req, res) => {
//   try {
//     const { text, userId } = req.body;

//     if (!text) {
//       return res.status(400).json({ message: "Text is required" });
//     }

//     const response = await axios.post(
//       process.env.AI_API_URL,
//       {
//         session_id: userId || "demo-session",
//         user_id: userId || "demo-user",
//         message: text,
//       },
//       {
//         headers: {
//           "Content-Type": "application/json",
//         },
//       }
//     );

//     return res.json({
//       reply: response.data.answer,
//     });
//   } catch (error) {
//     console.error("Chat API error:", error?.response?.data || error.message);
//     return res.status(500).json({ message: "Chat service failed" });
//   }
// };



// import axios from "axios";

// export const chat = async (req, res) => {
//   try {
//     console.log("Incoming body:", req.body);

//     const { text, userId } = req.body;

//     // Frontend sends { text, userId }
//     if (!text) {
//       return res.status(400).json({ message: "Text is required" });
//     }

//     const response = await axios.post(
//       process.env.AI_API_URL,
//       {
//         session_id: userId || "demo-session",
//         user_id: userId || "demo-user",
//         message: text,
//       },
//       {
//         headers: {
//           "Content-Type": "application/json",
//         },
//       }
//     );

//     console.log("AWS response:", response.data);

//     return res.json({
//       reply: response.data.answer,
//     });
//   } catch (err) {
//     console.error("Chat error:", err.response?.data || err.message);
//     return res.status(500).json({ message: "Chat failed" });
//   }
// };


// import axios from "axios";
// import { dynamo } from "../config/dynamo.js";
// import { PutCommand } from "@aws-sdk/lib-dynamodb";

// export const chat = async (req, res) => {
//   try {
//     const { text, userId, sessionId, plan = "FREE" } = req.body;

//     if (!text || !userId || !sessionId) {
//       return res.status(400).json({ message: "Missing fields" });
//     }

//     const timestamp = Date.now();

//     /* =========================
//        1️⃣ SAVE USER MESSAGE
//     ========================= */
//     await dynamo.send(
//       new PutCommand({
//         TableName: process.env.DYNAMO_CHATS_TABLE,
//         Item: {
//           userId,
//           sessionKey: `${sessionId}#${timestamp}`,
//           sessionId,
//           role: "user",
//           text,
//           createdAt: timestamp,
//           plan,
//         },
//       })
//     );

//     /* =========================
//        2️⃣ CALL AI
//     ========================= */
//     const response = await axios.post(
//       process.env.AI_API_URL,
//       {
//         session_id: sessionId,
//         user_id: userId,
//         message: text,
//       },
//       { headers: { "Content-Type": "application/json" } }
//     );

//     const reply = response.data.answer || "No response";

//     /* =========================
//        3️⃣ SAVE BOT MESSAGE
//     ========================= */
//     await dynamo.send(
//       new PutCommand({
//         TableName: process.env.DYNAMO_CHATS_TABLE,
//         Item: {
//           userId,
//           sessionKey: `${sessionId}#${timestamp + 1}`,
//           sessionId,
//           role: "bot",
//           text: reply,
//           createdAt: timestamp + 1,
//           plan,
//         },
//       })
//     );

//     return res.json({ reply });
//   } catch (err) {
//     console.error("Chat error:", err);
//     return res.status(500).json({ message: "Chat failed" });
//   }
// };

import axios from "axios";
import { dynamo } from "../config/dynamo.js";
import { PutCommand } from "@aws-sdk/lib-dynamodb";

export const chat = async (req, res) => {
  try {
    const { text, userId, sessionId, plan = "FREE" } = req.body;

    if (!text || !userId || !sessionId) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const timestamp = Date.now();

    // 1️⃣ Save user message (safe)
    try {
      await dynamo.send(new PutCommand({
        TableName: process.env.DYNAMO_CHATS_TABLE,
        Item: {
          userId,
          sessionKey: `${sessionId}#${timestamp}`,
          sessionId,
          role: "user",
          text,
          createdAt: timestamp,
          plan,
        },
      }));
    } catch (e) {
      console.error("Dynamo user save failed:", e);
    }

    // 2️⃣ Call AI
    const response = await axios.post(
      process.env.AI_API_URL,
      {
        session_id: sessionId,
        user_id: userId,
        message: text,
      },
      { headers: { "Content-Type": "application/json" } }
    );

    console.log("🧠 AI RESPONSE:", response.data);

    const reply =
      response.data?.answer ||
      response.data?.reply ||
      response.data?.message ||
      response.data?.output ||
      "No response from AI";

    // 3️⃣ Save bot message (safe)
    try {
      await dynamo.send(new PutCommand({
        TableName: process.env.DYNAMO_CHATS_TABLE,
        Item: {
          userId,
          sessionKey: `${sessionId}#${timestamp + 1}`,
          sessionId,
          role: "bot",
          text: reply,
          createdAt: timestamp + 1,
          plan,
        },
      }));
    } catch (e) {
      console.error("Dynamo bot save failed:", e);
    }

    return res.json({ reply });
  } catch (err) {
    console.error("🔥 Chat error FULL:", err);
    return res.status(500).json({
      message: "Chat failed",
      error: err.message,
    });
  }
};
