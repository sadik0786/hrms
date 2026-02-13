const express = require("express");
const multer = require("multer");
const path = require("path");
const { authenticate, authorize } = require("../middleware/authMiddleware");
const {
  registerEmployee,
  login,
  uploadAvatar,
  getRoles,
  getUsersByRoles,
  getProfile,
  updateMobile,
  forgotPasswordRequest,
  resetPasswordSelf,
  getCurrentUser,
  checkEmailExists,
} = require("../controllers/authController");
const { ROLES, ROLE_IDS } = require("../config/constants");

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
  authorize([ROLES.CEO, ROLES.HR]),
  registerEmployee,
);
router.get("/roles", authenticate, getRoles);

// single clean endpoint
router.get(
  "/users",
  authenticate,
  authorize([ROLES.CEO, ROLES.HR]),
  getUsersByRoles,
);
// check mail
router.post(
  "/checkemail",
  authenticate,
  authorize([ROLES.Manager, ROLES.Admin]),
  checkEmailExists,
);
router.post("/mobileUpdate", authenticate, updateMobile);
router.get("/profile", authenticate, getProfile);
router.post("/upload", authenticate, upload.single("avatar"), uploadAvatar);
// forgot password
router.post("/forgot_password", forgotPasswordRequest);
router.post("/reset_password_self", resetPasswordSelf);
module.exports = router;
