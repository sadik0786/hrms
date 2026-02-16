require("dotenv").config();
const { poolPromise, sql } = require("../db");
const { ROLES, ROLE_IDS } = require("../config/constants");

// Get all employees (CEO + HR only)
exports.getAllEmployees = async (req, res) => {
  try {
    const pool = await poolPromise;

    const query = `
      SELECT 
        U.ID,
        U.Name,
        U.Email,
        U.Mobile,
        U.ReportingID,
        RU.Name AS ReportingName,
        U.CreatedBy,
        U.CreatedAt,
        R.RoleName,
        C.Name AS AddedByName
      FROM dbo.UserTaskMateApp U
      INNER JOIN dbo.RoleTaskMateApp R 
        ON U.RoleID = R.RoleID
      LEFT JOIN dbo.UserTaskMateApp C
        ON U.CreatedBy = C.ID
      LEFT JOIN dbo.UserTaskMateApp RU
        ON U.ReportingID = RU.ID
      ORDER BY U.ID ASC
    `;

    const result = await pool.request().query(query);

    return res.json({
      success: true,
      count: result.recordset.length,
      employees: result.recordset,
    });
  } catch (err) {
    console.error("getAllEmployees error:", err);
    return res.status(500).json({
      success: false,
      error: "Server error",
    });
  }
};

// Delete employee (CEO + HR only)
exports.deleteEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const pool = await poolPromise;

    await pool
      .request()
      .input("id", sql.Int, id)
      .query("DELETE FROM dbo.UserTaskMateApp WHERE ID = @id");

    return res.json({
      success: true,
      message: "Employee deleted successfully",
    });
  } catch (err) {
    console.error("deleteEmployee error:", err);
    return res.status(500).json({
      success: false,
      error: "Server error",
    });
  }
};
