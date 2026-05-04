import express from "express";
import { stripeWebhook } from "../controllers/stripeWebhook.controller.js";

const router = express.Router();

// This should NOT have express.json() middleware
router.post("/stripe", express.raw({ type: "application/json" }), stripeWebhook);

export default router;