import express from "express";
import { getDashboard } from "../controllers/dashboard.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { requirePro } from "../middlewares/plan.middleware.js";

export default express.Router().get(
  "/",
  authMiddleware,
  requirePro,
  getDashboard
);
