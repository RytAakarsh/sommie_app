// import express from "express";
// import cors from "cors";
// import authRoutes from "./routes/auth.routes.js";

// const app = express();

// app.use(cors());
// app.use(express.json());

// app.use("/api/auth", authRoutes);

// export default app;



import dotenv from "dotenv";
dotenv.config();
import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.routes.js";
import mobileRoutes from "./routes/mobile.routes.js";
import chatRoutes from "./routes/chat.routes.js";
import dashboardRoutes from "./routes/dashboard.routes.js";
import userRoutes from "./routes/user.routes.js";
import adminRoutes from "./routes/admin.js";
import verificationRoutes from "./routes/verificationRoutes.js";
import paymentRoutes from "./routes/payment.routes.js";  
import { stripeWebhook } from "./controllers/stripeWebhook.controller.js";


const app = express();

// Stripe webhook needs raw body before JSON parsing
app.post(
  "/api/webhooks/stripe",
  express.raw({ type: "application/json" }),
  stripeWebhook
);

// CORS middleware
app.use(cors());

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Root endpoint
app.get("/", (req, res) => {
  res.json({ 
    message: "Sommie Backend API", 
    status: "running",
    environment: process.env.NODE_ENV || 'development'
  });
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/users", userRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/verify", verificationRoutes);
app.use("/api/payments", paymentRoutes); 
app.use("/api/mobile", mobileRoutes);  

console.log("📱 Mobile routes registered: /api/mobile");

// 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: `Route ${req.method} ${req.url} not found` 
  });
});

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error("Error:", err);
  res.status(500).json({ 
    success: false, 
    message: "Internal server error",
    error: process.env.NODE_ENV === "development" ? err.message : undefined
  });
});

export default app;