const { poolPromise, sql } = require("../db");

exports.addAllLeaveType = async (req, res) => {
  const { leaveName, leaveCount } = req.body;

  if (!leaveName || leaveCount == null) {
    return res.status(400).json({
      success: false,
      message: "LeaveName and LeaveCount are required",
    });
  }

  try {
    const pool = await poolPromise;

    // Check for duplicate leave name
    const checkDuplicate = await pool
      .request()
      .input("LeaveName", sql.VarChar(100), leaveName)
      .query(
        "SELECT 1 FROM dbo.LeaveTypeTaskMateApp WHERE LeaveName = @LeaveName AND IsActive = 1",
      );

    if (checkDuplicate.recordset.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Leave name already exists",
      });
    }

    await pool
      .request()
      .input("LeaveName", sql.VarChar(100), leaveName)
      .input("LeaveCount", sql.Int, leaveCount)
      .input("IsActive", sql.Bit, 1).query(`
        INSERT INTO dbo.LeaveTypeTaskMateApp
        (LeaveName, LeaveCount, IsActive, EntryTimeStamp)
        VALUES
        (@LeaveName, @LeaveCount, @IsActive, GETDATE())
      `);

    res.json({
      success: true,
      message: "Leave Type added successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

// get all leave type
exports.getAllLeaveType = async (req, res) => {
  try {
    const pool = await poolPromise;

    // Get the task
    const result = await pool.request().query(`
      SELECT 
        Id,
        LeaveName,
        LeaveCount
      FROM LeaveTypeTaskMateApp
      WHERE IsActive = 1
      ORDER BY LeaveName
    `);

    return res.status(200).json({
      success: true,
      data: result.recordset,
    });
  } catch (err) {
    console.error("getAllLeaveType error:", err);
    return res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};
// applye leave
exports.applyLeave = async (req, res) => {
  const { leaveTypeId, fromDate, toDate, days, sessionDay, reason } = req.body;
  const userId = req.user.id; // From authenticate middleware

  if (!leaveTypeId || !fromDate || !toDate || days == null) {
    return res.status(400).json({
      success: false,
      message: "Required fields are missing",
    });
  }

  try {
    const pool = await poolPromise;

    await pool
      .request()
      .input("UserId", sql.Int, userId)
      .input("LeaveTypeId", sql.Int, leaveTypeId)
      .input("FromDate", sql.DateTime, fromDate)
      .input("ToDate", sql.DateTime, toDate)
      .input("Days", sql.Decimal(5, 2), days)
      .input("SessionDay", sql.Int, sessionDay)
      .input("Reason", sql.VarChar(sql.MAX), reason || "")
      .input("IsActive", sql.Bit, 1).query(`
        INSERT INTO dbo.LeaveApplyTaskMateApp
        (UserId, LeaveTypeId, FromDate, ToDate, Days, SessionDay, Reason, IsActive, EntryTimeStamp)
        VALUES
        (@UserId, @LeaveTypeId, @FromDate, @ToDate, @Days, @SessionDay, @Reason, @IsActive, GETDATE())
      `);

    res.json({
      success: true,
      message: "Leave Application submitted successfully",
    });
  } catch (err) {
    console.error("applyLeave error:", err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};
