export const getDashboard = async (req, res) => {
  res.json({
    message: "Dashboard access granted",
    user: req.user,
  });
};
