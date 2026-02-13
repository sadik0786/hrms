import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/model/auth/register_request_model.dart';
import 'package:task_mate/services/auth_api_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/core/app_constants.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final mobile = TextEditingController();

  // Reactive states
  final loading = false.obs;
  final roleLoading = false.obs;

  final userName = ''.obs;
  final currentUserRole = ''.obs;

  RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> roles = <Map<String, dynamic>>[].obs;
  RxBool adminLoading = false.obs;
  RxnInt selectedAdminId = RxnInt();

  final selectedRoleId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    password.dispose();
    mobile.dispose();
    super.onClose();
  }

  Future<void> _initializeData() async {
    await loadUserRole();
    await loadRoles();
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString(AppConstants.nameKey) ?? "Employee";
    currentUserRole.value = prefs.getString(AppConstants.roleKey)?.toLowerCase() ?? '';
  }

  Future<void> loadRoles() async {
    roleLoading.value = true;
    try {
      roles.value = await AuthApiService.getRoles();
    } catch (e) {
      print("Error loading roles: $e");
    } finally {
      roleLoading.value = false;
    }
  }

  Future<void> loadAssignableUsers(String selectedRoleName) async {
    adminLoading.value = true;
    
    try {
      final myRole = currentUserRole.value.toLowerCase();
      final prefs = await SharedPreferences.getInstance();
      print("loadAssignableUsers called");
      print("My Role: $myRole");
      print("Selected Role: $selectedRoleName");
      // Clear previous selection
      selectedAdminId.value = null;

      if (myRole == AppConstants.roleCeo) {
        // When CEO adds HR, Accountant, or Manager, they are assigned to CEO
        // We set selectedAdminId to the CEO's own ID
        selectedAdminId.value = prefs.getInt(AppConstants.userIdKey);
        // We can also fetch the CEO list if we want to show it in the dropdown
        admins.value = [
          {"ID": selectedAdminId.value, "Name": "Self (${userName.value})"},
        ];
      } else if (myRole == AppConstants.roleHr) {
        if (selectedRoleName == AppConstants.roleAdmin) {
          // Admin assigned to Manager
          final users = await AuthApiService.getUsersByRoles(AppConstants.roleManager);
          admins.value = users;
        } else if (selectedRoleName == AppConstants.roleEmployee) {
          // Employee assigned to Admin or Manager
          final users = await AuthApiService.getUsersByRoles(
            "${AppConstants.roleAdmin},${AppConstants.roleManager}",
          );
          admins.value = users;
        }
      }
    } catch (e) {
      print("Error loading assignable users: $e");
    } finally {
      adminLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    final roleId = selectedRoleId.value;
    if (roleId == null) {
      CustomSnackBar.error("Please select a role");
      return;
    }

    loading.value = true;

    try {
      final request = RegisterRequestModel(
        name: name.text.trim(),
        email: email.text.trim(),
        mobile: mobile.text.trim(),
        password: password.text.trim(),
        roleId: roleId,
        reportingId: selectedAdminId.value,
      );

      final response = await AuthApiService.registerEmployee(request);

      if (response.success == true) {
        CustomSnackBar.success("Added successfully!");

        // ✅ CLEAR FIELDS
        name.clear();
        email.clear();
        password.clear();
        mobile.clear();
        selectedRoleId.value = null;
        selectedAdminId.value = null;

        // ✅ Go Back
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.dashboard);
        });
      } else {
        CustomSnackBar.error(response.message ?? "Failed to add employee");
      }
    } catch (e) {
      CustomSnackBar.error("Something went wrong");
    } finally {
      loading.value = false;
    }
  }
}
