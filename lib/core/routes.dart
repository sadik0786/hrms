import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/app_constants.dart';
import 'package:task_mate/screens/auth/login_screen.dart';
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
];
