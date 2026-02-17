const express = require("express");
const router = express.Router();

const {
  addAllLeaveType,
  getAllLeaveType,
  applyLeave,
} = require("../controllers/hrmsController");
const { authenticate, authorize } = require("../middleware/authMiddleware");

router.post("/leave-types", authenticate, authorize(["hr"]), addAllLeaveType);
router.get("/leave-types", authenticate, getAllLeaveType);
// apply leave
router.post("/apply-leave", authenticate, applyLeave);

module.exports = router;
