// import jwt from "jsonwebtoken";

// export const authMiddleware = (req, res, next) => {
//   const auth = req.headers.authorization;
//   if (!auth?.startsWith("Bearer "))
//     return res.status(401).json({ message: "Unauthorized" });

//   try {
//     req.user = jwt.verify(auth.split(" ")[1], process.env.JWT_SECRET);
//     next();
//   } catch {
//     res.status(401).json({ message: "Invalid token" });
//   }
// };



import jwt from "jsonwebtoken";

export const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "No token provided",
      });
    }

    const token = authHeader.split(" ")[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = decoded;

    next();
  } catch (err) {
    console.error("Auth middleware error:", err);

    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};
