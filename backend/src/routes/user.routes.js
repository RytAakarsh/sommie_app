// import express from "express";
// import { upgradePlan } from "../controllers/user.controller.js";

// const router = express.Router();

// router.post("/upgrade-plan", upgradePlan);

// export default router;


// import express from "express";
// import { 
//   upgradePlan, 
//   updateProfile, 
//   getProfile 
// } from "../controllers/user.controller.js";
// import { authMiddleware } from "../middlewares/auth.middleware.js";

// const router = express.Router();

// // Apply auth middleware to all user routes
// router.use(authMiddleware);

// // Plan management
// router.post("/upgrade-plan", upgradePlan);

// // Profile management
// router.post("/profile", updateProfile);
// router.get("/profile/:userId", getProfile);

// export default router;




// import express from "express";
// import { 
//   upgradePlan, 
//   updateProfile, 
//   getProfile 
// } from "../controllers/user.controller.js";
// import { authMiddleware } from "../middlewares/auth.middleware.js";

// const router = express.Router();

// // Apply auth middleware to all user routes
// router.use(authMiddleware);

// // Plan management
// router.post("/upgrade-plan", upgradePlan);

// // Profile management
// // ✅ REMOVED :userId from URL - now uses token
// router.post("/profile", updateProfile);
// router.get("/profile", getProfile); // ✅ Changed from /profile/:userId to /profile

// export default router;




import express from "express";
import { 
  updateProfile, 
  getProfile,
  getFullUserData,
  saveChat,
  getChats,
  deleteChat,
  saveCellar,
  getCellar,
  saveRestaurantPairing,
  getRestaurantPairings, 
  verifyPayment,
  getUserPayments,
  getPaymentMethods,
  setDefaultPaymentMethod,
  deletePaymentMethod,
} from "../controllers/user.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = express.Router();

// Apply auth middleware to all user routes
router.use(authMiddleware);

// Plan management
router.post("/verify-payment", verifyPayment);

// Profile management
router.post("/profile", updateProfile);
router.get("/profile", getProfile);
router.get("/full-data", getFullUserData);

// Payment routes
 router.get("/payments/:userId", getUserPayments);

// ✅ Payment Methods routes
router.get("/payment-methods/:userId", getPaymentMethods);
router.put("/payment-methods/default", setDefaultPaymentMethod);
router.delete("/payment-methods/:paymentMethodId", deletePaymentMethod);

// Chat management
router.get("/chat", getChats);
router.post("/chat", saveChat);
router.delete("/chat/:chatId", deleteChat);

// Cellar management
router.get("/cellar", getCellar);
router.post("/cellar", saveCellar);

// Restaurant pairings
router.post("/restaurant-pairing", saveRestaurantPairing);
router.get('/restaurant-pairing', getRestaurantPairings); 

export default router;