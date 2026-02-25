// import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
// import nodemailer from "nodemailer";

// // Create SES client
// export const sesClient = new SESClient({
//   region: process.env.AWS_REGION || "us-east-1",
//   credentials: {
//     accessKeyId: process.env.AWS_ACCESS_KEY_ID,
//     secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
//   },
// });

// // Create nodemailer transport
// export const transporter = nodemailer.createTransport({
//   SES: { ses: sesClient, aws: { SendEmailCommand } },
// });

// /**
//  * Send email using SES
//  */
// export const sendEmail = async ({ to, subject, html }) => {
//   try {
//     const params = {
//       Source: process.env.SES_FROM_EMAIL || "info@sommie.io",
//       Destination: {
//         ToAddresses: [to],
//       },
//       Message: {
//         Subject: {
//           Data: subject,
//           Charset: "UTF-8",
//         },
//         Body: {
//           Html: {
//             Data: html,
//             Charset: "UTF-8",
//           },
//         },
//       },
//     };

//     const command = new SendEmailCommand(params);
//     await sesClient.send(command);
//     console.log("Email sent successfully to:", to);
//     return true;
//   } catch (error) {
//     console.error("SES Email error:", error);
//     throw error;
//   }
// };



import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";

// Create SES client
export const sesClient = new SESClient({
  region: process.env.AWS_REGION || "us-east-1",
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

/**
 * Send email using SES
 */
export const sendEmail = async ({ to, subject, html }) => {
  try {
    const params = {
      Source: process.env.SES_FROM_EMAIL || "info@sommie.io",
      Destination: {
        ToAddresses: [to],
      },
      Message: {
        Subject: {
          Data: subject,
          Charset: "UTF-8",
        },
        Body: {
          Html: {
            Data: html,
            Charset: "UTF-8",
          },
        },
      },
    };

    const command = new SendEmailCommand(params);
    await sesClient.send(command);
    console.log("Email sent successfully to:", to);
    return true;
  } catch (error) {
    console.error("SES Email error:", error);
    throw error;
  }
};