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
  {
    headers: {
      "Content-Type": "application/json",
      "x-api-key": process.env.AI_API_KEY
    }
  }
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
