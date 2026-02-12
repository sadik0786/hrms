import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/app_constants.dart';
import 'package:task_mate/screens/login/login_screen.dart';
import 'package:task_mate/screens/user/profile_screen.dart';
import 'package:task_mate/screens/splash_screent.dart';
// for admin pages
import 'package:task_mate/screens/login/admin_dashboard.dart';
import 'package:task_mate/screens/login/employee_screen.dart';
import 'package:task_mate/screens/login/register_screen.dart';

class Routes {
  static const String initialRoute = "/splash";
  static const String login = "/login";
  static const String homeScreen = "/homeScreen";
  static const String addTaskScreen = "/addTaskScreen";
  static const String addSubProjectScreen = "/addSubProjectScreen";
  static const String taskScreen = "/taskScreen";
  static const String forgotPasswordPage = "/forgotPasswordPage";
  static const String profileScreen = "/profileScreen";
  // for admin pages
  static const String adminDashboard = "/adminDashboard";
  static const String registerScreen = "/registerScreen";
  static const String employeeScreen = "/employeeScreen";
  static const String employeeTaskScreen = "/employeeTaskScreen";
  static const String projectScreen = "/projectScreen";
  static const String resetPasswordPage = "/resetPasswordPage";
  //hrms screen
  static const String hrmsDashboard = "/hrms_dashboard";
  static const String applyLeave = "/applyLeave";
  static const String dashboard = "/dashboard";
  static const String approveLeave = "/approveLeave";
  static const String addEmployee = "/addEmployee";
  static const String allEmployee = "/allEmployee";
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
  _getPage(Routes.login, LoginScreen()),
  _getPage(Routes.profileScreen, ProfileScreen()),
  // for admin pages
  _getPage(Routes.registerScreen, RegisterScreen()),
  _getPage(Routes.adminDashboard, AdminDashboard()),
  _getPage(Routes.employeeScreen, EmployeeScreen()),
];
