
import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";

// Create SES client with dedicated SES account credentials
const sesClient = new SESClient({
  region: process.env.SES_AWS_REGION || "us-east-1",
  credentials: {
    accessKeyId: process.env.SES_AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.SES_AWS_SECRET_ACCESS_KEY,
  },
});

// Multi-language email templates
const templates = {
  verification: (otp, userName, lang = "en") => {
    const content = {
      en: {
        subject: "Verify Your Email - Sommie",
        heading: `Welcome to Sommie, ${userName}!`,
        message: "Thank you for signing up! Please verify your email address to complete your registration.",
        codeLabel: "Your verification code is:",
        expiry: "This code will expire in 10 minutes.",
        ignore: "If you didn't create an account with Sommie, please ignore this email.",
        footer: "Best regards,\nThe Sommie Team",
      },
      pt: {
        subject: "Verifique seu E-mail - Sommie",
        heading: `Bem-vindo ao Sommie, ${userName}!`,
        message: "Obrigado por se cadastrar! Por favor, verifique seu endereço de e-mail para completar seu registro.",
        codeLabel: "Seu código de verificação é:",
        expiry: "Este código expirará em 10 minutos.",
        ignore: "Se você não criou uma conta no Sommie, por favor ignore este e-mail.",
        footer: "Atenciosamente,\nEquipe Sommie",
      },
    };

    const t = content[lang] || content.en;

    return {
      subject: t.subject,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>${t.subject}</title>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4B2B5F; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }
            .header h1 { color: white; margin: 0; }
            .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .otp-code { font-size: 32px; font-weight: bold; color: #4B2B5F; text-align: center; padding: 20px; background-color: #f0f0f0; border-radius: 8px; letter-spacing: 5px; margin: 20px 0; }
            .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Sommie</h1>
            </div>
            <div class="content">
              <h2>${t.heading}</h2>
              <p>${t.message}</p>
              <p>${t.codeLabel}</p>
              <div class="otp-code">${otp}</div>
              <p>${t.expiry}</p>
              <p>${t.ignore}</p>
              <hr>
              <p style="font-size: 14px; color: #666;">${t.footer}</p>
            </div>
            <div class="footer">
              <p>&copy; ${new Date().getFullYear()} Sommie. All rights reserved.</p>
              <p>sommie.io</p>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `${t.heading}\n\n${t.message}\n\n${t.codeLabel}\n${otp}\n\n${t.expiry}\n\n${t.ignore}\n\n${t.footer}`,
    };
  },
  
  passwordReset: (otp, userName, lang = "en") => {
    const content = {
      en: {
        subject: "Reset Your Password - Sommie",
        heading: `Hello ${userName},`,
        message: "We received a request to reset your password.",
        codeLabel: "Use the following code to reset it:",
        expiry: "This code will expire in 10 minutes.",
        ignore: "If you didn't request a password reset, please ignore this email.",
        footer: "Best regards,\nThe Sommie Team",
      },
      pt: {
        subject: "Redefina sua Senha - Sommie",
        heading: `Olá ${userName},`,
        message: "Recebemos uma solicitação para redefinir sua senha.",
        codeLabel: "Use o seguinte código para redefini-la:",
        expiry: "Este código expirará em 10 minutos.",
        ignore: "Se você não solicitou a redefinição de senha, ignore este e-mail.",
        footer: "Atenciosamente,\nEquipe Sommie",
      },
    };

    const t = content[lang] || content.en;

    return {
      subject: t.subject,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>${t.subject}</title>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4B2B5F; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }
            .header h1 { color: white; margin: 0; }
            .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .otp-code { font-size: 32px; font-weight: bold; color: #4B2B5F; text-align: center; padding: 20px; background-color: #f0f0f0; border-radius: 8px; letter-spacing: 5px; margin: 20px 0; }
            .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Sommie</h1>
            </div>
            <div class="content">
              <h2>${t.heading}</h2>
              <p>${t.message}</p>
              <p>${t.codeLabel}</p>
              <div class="otp-code">${otp}</div>
              <p>${t.expiry}</p>
              <p>${t.ignore}</p>
              <hr>
              <p style="font-size: 14px; color: #666;">${t.footer}</p>
            </div>
            <div class="footer">
              <p>&copy; ${new Date().getFullYear()} Sommie. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `${t.heading}\n\n${t.message}\n\n${t.codeLabel}\n${otp}\n\n${t.expiry}\n\n${t.ignore}\n\n${t.footer}`,
    };
  },
};

export const sendEmail = async (to, type, data) => {
  try {
    const template = templates[type](
      data.otp, 
      data.userName,
      data.language || "en" // ✅ Use language from request
    );
    
    const params = {
      Source: process.env.SES_FROM_EMAIL,
      Destination: {
        ToAddresses: [to],
      },
      Message: {
        Subject: {
          Data: template.subject,
          Charset: "UTF-8",
        },
        Body: {
          Html: {
            Data: template.html,
            Charset: "UTF-8",
          },
          Text: {
            Data: template.text,
            Charset: "UTF-8",
          },
        },
      },
    };

    const command = new SendEmailCommand(params);
    const result = await sesClient.send(command);
    
    console.log(`Email sent to ${to} - MessageId: ${result.MessageId}`);
    return { success: true, messageId: result.MessageId };
  } catch (error) {
    console.error("Error sending email:", error);
    return { success: false, error: error.message };
  }
};
