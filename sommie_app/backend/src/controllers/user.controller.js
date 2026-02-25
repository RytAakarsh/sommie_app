import { UpdateCommand } from "@aws-sdk/lib-dynamodb";
import { dynamo } from "../config/dynamo.js";

export const upgradePlan = async (req, res) => {
  const TABLE = process.env.DYNAMO_USERS_TABLE;

  const { userId, plan } = req.body;

  if (!userId || !plan) {
    return res.status(400).json({ message: "Missing userId or plan" });
  }

  try {
    await dynamo.send(
      new UpdateCommand({
        TableName: TABLE,
        Key: { userId },
        UpdateExpression: "set #p = :p",
        ExpressionAttributeNames: {
          "#p": "plan",
        },
        ExpressionAttributeValues: {
          ":p": plan,
        },
      })
    );

    res.json({ success: true, plan });
  } catch (err) {
    console.error("Upgrade plan error:", err);
    res.status(500).json({ message: "Failed to upgrade plan" });
  }
};
