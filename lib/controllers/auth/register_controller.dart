import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/model/auth/register_request_model.dart';
import 'package:task_mate/services/auth_api_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

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
    // await loadRoles();
    // if (currentUserRole.value == "ceo") {
    //   await loadAdmins();
    // }
  }


  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString("name") ?? "Employee";
    currentUserRole.value = prefs.getString("role")?.toLowerCase() ?? '';
  }

 
 
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    final roleId = selectedRoleId.value;
    if (roleId == null) {
      CustomSnackBar.error("Please select a role");
      return;
    }

    loading.value = true;

    final currentRole = currentUserRole.value.toLowerCase();

    final selectedRoleData = roles.firstWhere((r) => r["RoleId"] == roleId, orElse: () => {});

    final selectedRoleName = (selectedRoleData["RoleName"] ?? "").toString().toLowerCase();

    // Superadmin assigning employee must select admin
    if ((currentRole == 'hr' || currentRole == 'superadmin') &&
        (selectedRoleName == 'admin' || selectedRoleName == 'employee') &&
        selectedAdminId.value == null) {
      loading.value = false;
      CustomSnackBar.error("Please select Assign To");
      return;
    }

    // ✅ Create Request Model
    final request = RegisterRequestModel(
      name: name.value.text.trim(),
      email: email.value.text.trim(),
      mobile: mobile.value.text.trim(),
      password: password.value.text.trim(),
      roleId: roleId,
      reportingId: selectedAdminId.value,
    );

    // ✅ Call API
    final response = await AuthApiService.registerEmployee(request);

    loading.value = false;

    // ✅ Handle Typed Response
    if (response.success == true) {
      CustomSnackBar.success("Added successfully!");
      Get.back();
    } else {
      CustomSnackBar.error("Failed to add employee");
    }
  }
}
