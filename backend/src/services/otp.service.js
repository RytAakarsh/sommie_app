import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, GetCommand, DeleteCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const dynamo = DynamoDBDocumentClient.from(dynamoClient);

const OTP_TABLE = process.env.OTP_TABLE || "SommieOTPs";
const OTP_EXPIRY_MINUTES = 10;

export const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export const storeOTP = async (email, otp, type) => {
  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + OTP_EXPIRY_MINUTES);

  // First, delete any existing OTPs for this email and type
  const existingOtps = await dynamo.send(
    new QueryCommand({
      TableName: OTP_TABLE,
      KeyConditionExpression: "email = :email",
      FilterExpression: "#type = :type",
      ExpressionAttributeNames: {
        "#type": "type"
      },
      ExpressionAttributeValues: {
        ":email": email,
        ":type": type
      }
    })
  );

  // Delete existing OTPs
  if (existingOtps.Items && existingOtps.Items.length > 0) {
    for (const existingOtp of existingOtps.Items) {
      await dynamo.send(
        new DeleteCommand({
          TableName: OTP_TABLE,
          Key: {
            email: existingOtp.email,
            otp: existingOtp.otp
          }
        })
      );
    }
  }

  const params = {
    TableName: OTP_TABLE,
    Item: {
      email,
      otp,
      type, // 'email_verification' or 'password_reset'
      expiresAt: expiresAt.toISOString(),
      createdAt: new Date().toISOString(),
    },
  };

  await dynamo.send(new PutCommand(params));
  return true;
};

export const verifyOTP = async (email, otp, type) => {
  const params = {
    TableName: OTP_TABLE,
    Key: {
      email,
      otp,
    },
  };

  const result = await dynamo.send(new GetCommand(params));
  
  if (!result.Item) {
    return { valid: false, reason: "OTP not found" };
  }

  if (result.Item.type !== type) {
    return { valid: false, reason: "Invalid OTP type" };
  }

  const now = new Date();
  const expiresAt = new Date(result.Item.expiresAt);

  if (now > expiresAt) {
    // Delete expired OTP
    await dynamo.send(new DeleteCommand(params));
    return { valid: false, reason: "OTP expired" };
  }

  // Delete OTP after successful verification
  await dynamo.send(new DeleteCommand(params));
  
  return { valid: true };
};

export const deleteOTP = async (email, otp) => {
  const params = {
    TableName: OTP_TABLE,
    Key: {
      email,
      otp,
    },
  };
  await dynamo.send(new DeleteCommand(params));
};
