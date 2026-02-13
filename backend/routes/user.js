const express = require("express");
const { authenticate, authorize } = require("../middleware/authMiddleware");
const { getAllEmployees } = require("../controllers/userController");
const { ROLES, ROLE_IDS } = require("../config/constants");
const router = express.Router();
router.get(
  "/employees",
  authenticate,
  authorize([ROLES.CEO, ROLES.HR]),
  getAllEmployees,
);
module.exports = router;
