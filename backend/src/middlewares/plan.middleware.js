export const requirePro = (req, res, next) => {
  if (req.user.plan !== "PRO" && req.user.plan !== "ADMIN") {
    return res.status(403).json({ message: "Upgrade to PRO required" });
  }
  next();
};
