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
      .input("UserTaskMateAppId", sql.Int, userId)
      .input("LeaveTypeTaskMateAppId", sql.Int, leaveTypeId)
      .input("FromDate", sql.Date, fromDate)
      .input("ToDate", sql.Date, toDate)
      .input("TotalDays", sql.Decimal(5, 2), days)
      .input("SessionDay", sql.Int, sessionDay)
      .input("Reason", sql.VarChar(150), reason || "").query(`
        INSERT INTO dbo.ApplyLeaveTaskMateApp
        (UserTaskMateAppId, LeaveTypeTaskMateAppId, FromDate, ToDate, TotalDays, SessionDay, Reason, Status, EntryTimeStamp)
        VALUES
        (@UserTaskMateAppId, @LeaveTypeTaskMateAppId, @FromDate, @ToDate, @TotalDays, @SessionDay, @Reason, 'PENDING', GETDATE())
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
}; // get logged in user's applied leaves
exports.getMyAppliedLeaves = async (req, res) => {
  const userId = req.user.id;

  try {
    const pool = await poolPromise;

    const result = await pool.request().input("UserId", sql.Int, userId).query(`
        SELECT 
          al.Id as id,
          al.UserTaskMateAppId as userId,
          lt.LeaveName as leaveName,
          al.FromDate as fromDate,
          al.ToDate as toDate,
          al.TotalDays as totalDays,
          al.SessionDay as sessionDay,
          al.Reason as reason,
          al.RejectReason as rejectReason,
          al.Status as status,
          al.EntryTimeStamp as entryTimeStamp,
          u.Name as approverName
        FROM dbo.ApplyLeaveTaskMateApp al
        INNER JOIN dbo.LeaveTypeTaskMateApp lt ON al.LeaveTypeTaskMateAppId = lt.Id
        LEFT JOIN dbo.UserTaskMateApp u ON al.ApprovedBy = u.ID
        WHERE al.UserTaskMateAppId = @UserId
        ORDER BY al.EntryTimeStamp DESC
      `);

    res.json({
      success: true,
      data: result.recordset,
    });
  } catch (err) {
    console.error("getMyAppliedLeaves error:", err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

// get other users' leave requests based on role
exports.getOtherLeavesRequest = async (req, res) => {
  const userId = req.user.id;
  const role = req.user.role;

  try {
    const pool = await poolPromise;
    let query = `
      SELECT 
        al.Id as id,
        al.UserTaskMateAppId as userId,
        u.Name as employeeName,
        lt.LeaveName as leaveName,
        al.FromDate as fromDate,
        al.ToDate as toDate,
        al.TotalDays as totalDays,
        al.SessionDay as sessionDay,
        al.Reason as reason,
        al.RejectReason as rejectReason,
        al.Status as status,
        al.EntryTimeStamp as entryTimeStamp
      FROM dbo.ApplyLeaveTaskMateApp al
      INNER JOIN dbo.LeaveTypeTaskMateApp lt ON al.LeaveTypeTaskMateAppId = lt.Id
      INNER JOIN dbo.UserTaskMateApp u ON al.UserTaskMateAppId = u.ID
      INNER JOIN dbo.RoleTaskMateApp r ON u.RoleID = r.RoleID
    `;

    if (role === "ceo") {
      // CEO sees requests from Managers, Accountants, and HR
      query += ` WHERE r.RoleName IN ('manager', 'accountant', 'hr')`;
    } else {
      // Others see only their subordinates
      query += ` WHERE u.ReportingID = @UserId`;
    }

    query += ` AND al.Status = 'PENDING' ORDER BY al.EntryTimeStamp DESC`;

    const result = await pool
      .request()
      .input("UserId", sql.Int, userId)
      .query(query);

    res.json({
      success: true,
      data: result.recordset,
    });
  } catch (err) {
    console.error("getOtherLeavesRequest error:", err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

// update leave status (Approve/Reject)
exports.updateLeaveStatus = async (req, res) => {
  const { id } = req.params;
  const { status, remarks } = req.body;
  const approvedById = req.user.id;

  if (!status) {
    return res.status(400).json({
      success: false,
      message: "Status is required",
    });
  }

  try {
    const pool = await poolPromise;

    await pool
      .request()
      .input("Id", sql.Int, id)
      .input("Status", sql.VarChar(20), status)
      .input("ApprovedById", sql.Int, approvedById)
      .input("RejectReason", sql.VarChar(250), remarks || "").query(`
        UPDATE dbo.ApplyLeaveTaskMateApp
        SET Status = @Status,
            ApprovedBy = @ApprovedById,
            ApprovedOn = GETDATE(),
            RejectReason = @RejectReason
        WHERE Id = @Id
      `);

    res.json({
      success: true,
      message: `Leave status updated to ${status}`,
    });
  } catch (err) {
    console.error("updateLeaveStatus error:", err);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};
