const express = require("express");
const multer = require("multer");
const path = require("path");
const { authenticate, authorize } = require("../middleware/authMiddleware");
const {
  registerEmployee,
  login,
  uploadAvatar,
  getRoles,
  getUsersByRole,
  getUsersByRoles,
  getProfile,
  updateMobile,
  forgotPasswordRequest,
  resetPasswordSelf,
  getCurrentUser,
  checkEmailExists,
  admins,
} = require("../controllers/authController");

const router = express.Router();

// Multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => {
    const userId = req.user.id;
    if (!userId) return cb(new Error("UserId missing"), null);
    const ext = path.extname(file.originalname) || ".jpg";
    cb(null, `${userId}${ext}`);
  },
});
const upload = multer({ storage });

router.get("/me", authenticate, getCurrentUser);

// public
router.post("/login", login);

// protected

router.post(
  "/register",
  authenticate,
  authorize(["ceo", "hr"]),
  registerEmployee,
);

module.exports = router;
