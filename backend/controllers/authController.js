require("dotenv").config();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const sharp = require("sharp");
const fs = require("fs");
const path = require("path");
const { poolPromise, sql } = require("../db");
const { ROLES, ROLE_IDS } = require("../config/constants");

const JWT_SECRET = process.env.JWT_SECRET || "super_secret_key";
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "1d";

exports.getCurrentUser = async (req, res) => {
  try {
    const userId = req.user.id; // set by authenticate middleware
    const pool = await poolPromise;

    const result = await pool.request().input("userId", sql.Int, userId).query(`
        SELECT 
          U.ID,
          U.Name,
          U.Email,
          U.RoleID AS UserRoleID,
          R.RoleName
        FROM dbo.UserTaskMateApp U
        INNER JOIN dbo.RoleTaskMateApp R ON U.RoleID = R.RoleID
        WHERE U.ID = @userId
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ success: false, error: "User not found" });
    }

    const user = result.recordset[0];
    res.json({ success: true, user });
  } catch (err) {
    console.error("getCurrentUser error:", err);
    res.status(500).json({ success: false, error: "Server error" });
  }
};
//------ REGISTER EMPLOYEE
exports.registerEmployee = async (req, res) => {
  const { name, email, mobile, password, roleId, reportingId } = req.body;

  try {
    const creatorRole = (req.user.role || "").toLowerCase();
    const creatorId = req.user.id;
    // Convert roleId to number (VERY IMPORTANT)
    const newRoleId = Number(roleId);
    if (!newRoleId) {
      return res.status(400).json({
        success: false,
        error: "Invalid roleId",
      });
    }
    // Mobile validation
    if (mobile && !/^\d{10,15}$/.test(mobile)) {
      return res.status(400).json({ error: "Invalid mobile number" });
    }
    if (!email.endsWith("@5nance.com")) {
      return res
        .status(400)
        .json({ error: "Only @5nance.com emails are allowed" });
    }

    // Role Hierarchy Logic
    if (creatorRole === ROLES.CEO) {
      if (
        ![ROLE_IDS.HR, ROLE_IDS.Accountant, ROLE_IDS.SuperAdmin].includes(
          newRoleId,
        )
      ) {
        return res.status(403).json({
          success: false,
          error: "CEO can only create HR, Accountant, or SuperAdmin",
        });
      }
    } else if (creatorRole === ROLES.HR) {
      if (![ROLE_IDS.Admin, ROLE_IDS.Employee].includes(newRoleId)) {
        return res.status(403).json({
          success: false,
          error: "HR can only create Admin or Employee",
        });
      }
    }

    const pool = await poolPromise;
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool
      .request()
      .input("Name", sql.NVarChar(100), name)
      .input("Email", sql.NVarChar(150), email)
      .input(
        "Mobile",
        sql.VarChar(15),
        mobile && mobile.trim() !== "" ? mobile : null,
      )
      .input("PasswordHash", sql.NVarChar(255), hashedPassword)
      .input("RoleID", sql.Int, newRoleId)
      .input("ReportingID", sql.Int, reportingId || creatorId)
      .input("CreatedBy", sql.Int, creatorId)
      .execute("dbo.Usp_PostRegisterEmployeeTaskMateAppApi");

    const employee = result.recordset?.[0];
    if (!employee) {
      return res
        .status(500)
        .json({ success: false, error: "Failed to create employee" });
    }

    res.json({
      success: true,
      employee,
    });
  } catch (err) {
    console.error("Register Employee error:", err);

    if (err.message?.includes("already exists")) {
      return res.status(200).json({ success: false, error: err.message });
    }
    res.status(500).json({ success: false, error: "Server error" });
  }
};

//------ LOGIN
exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(200).json({
      success: false,
      message: "Please enter both email and password.",
    });
  }

  try {
    const pool = await poolPromise;
    const result = await pool
      .request()
      .input("Email", sql.NVarChar(150), email)
      .execute("dbo.Usp_PostLoginUserTaskMateAppApi");

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(200).json({
        success: false,
        message: "No account found with this email address.",
      });
    }

    const user = result.recordset[0];
    const isValid = await bcrypt.compare(password, user.PasswordHash);

    if (!isValid) {
      return res.status(200).json({
        success: false,
        message: "Incorrect password. Please try again.",
      });
    }

    // Map DB role names to canonical names
    const roleMap = {
      superadmin: "superadmin",
      admin: "admin",
      employee: "employee",
    };
    const normalizedRole =
      roleMap[user.RoleName.toLowerCase()] || user.RoleName.toLowerCase();

    const tokenPayload = {
      id: user.ID,
      role: normalizedRole,
      reportingId: user.ReportingID || 0,
    };

    const token = jwt.sign(tokenPayload, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN,
    });

    res.json({
      success: true,
      message: "Login successful!",
      token,
      user: {
        id: user.ID,
        name: user.Name,
        email: user.Email,
        mobile: user.Mobile,
        roleId: user.RoleID,
        role: normalizedRole,
        reportingId: user.ReportingID,
      },
    });
  } catch (err) {
    console.error("login error:", err);
    return res.status(200).json({
      success: false,
      message: "Something went wrong on the server. Please try again later.",
    });
  }
};
