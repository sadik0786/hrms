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
        U.CreatedBy,
        U.CreatedAt,
        R.RoleName
      FROM dbo.UserTaskMateApp U
      INNER JOIN dbo.RoleTaskMateApp R 
        ON U.RoleID = R.RoleID
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
