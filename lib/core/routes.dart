import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/app_constants.dart';
import 'package:task_mate/screens/auth/login_screen.dart';
import 'package:task_mate/screens/hrms/hrms_dashboard.dart';
import 'package:task_mate/screens/hrms/widgets/add_leave_type.dart';
import 'package:task_mate/screens/hrms/widgets/apply_leave.dart';
import 'package:task_mate/screens/hrms/widgets/approve_leave.dart';
import 'package:task_mate/screens/hrms/widgets/leave_balance.dart';
import 'package:task_mate/screens/hrms/widgets/leave_home.dart';
import 'package:task_mate/screens/profile/profile_screen.dart';
import 'package:task_mate/screens/splash_screent.dart';
// after login
import 'package:task_mate/screens/dashboard.dart';
import 'package:task_mate/screens/auth/register_screen.dart';
import 'package:task_mate/screens/user/employee_screen.dart';

class Routes {
  static const String initialRoute = "/splash";
  static const String registerScreen = "/registerScreen";
  static const String login = "/login";
  // after login
  static const String dashboard = "/dashboard";
  static const String profileScreen = "/profileScreen";
  static const String employeeScreen = "/employeeScreen";
  //hrms
  static const String hrmsDashboard = "/hrmsDashboard";
  static const String leaveHome = "/leaveHome";
  static const String addLeaveType = "/addLeaveType";
  static const String applyLeave = "/applyLeave";
  static const String approveLeave = "/approveLeave";
  static const String leaveBalance = "/leaveBalance";
}

const Duration transitionDuration = Duration(milliseconds: AppConstants.transitionDuration);

GetPage _getPage(String name, Widget page) => GetPage(
  name: name,
  page: () => page,
  transition: AppConstants.transition,
  fullscreenDialog: true,
  transitionDuration: transitionDuration,
);

List<GetPage> appPages() => [
  _getPage(Routes.initialRoute, SplashScreen()),
  _getPage(Routes.registerScreen, RegisterScreen()),
  _getPage(Routes.login, LoginScreen()),
  // after login
  _getPage(Routes.dashboard, Dashboard()),
  _getPage(Routes.profileScreen, ProfileScreen()),
  _getPage(Routes.employeeScreen, EmployeeScreen()),
  //hrms
  _getPage(Routes.hrmsDashboard, HrmsDashboard()),
  _getPage(Routes.leaveHome, LeaveHome()),
  _getPage(Routes.addLeaveType, AddLeaveType()),
  _getPage(Routes.applyLeave, ApplyLeave()),
  _getPage(Routes.approveLeave, ApproveLeave()),
  _getPage(Routes.leaveBalance, LeaveBalance()),

];
