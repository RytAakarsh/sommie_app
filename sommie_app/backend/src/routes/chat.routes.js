// import express from "express";
// import { chat } from "../controllers/chat.controller.js";
// import { authMiddleware } from "../middlewares/auth.middleware.js";
// export default express.Router().post("/", authMiddleware, chat);


import express from "express";
import { chat } from "../controllers/chat.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/", authMiddleware, chat);

export default router;
