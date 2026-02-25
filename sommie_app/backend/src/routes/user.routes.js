import express from "express";
import { upgradePlan } from "../controllers/user.controller.js";

const router = express.Router();

router.post("/upgrade-plan", upgradePlan);

export default router;
