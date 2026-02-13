import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/services/auth_api_service.dart';
import 'package:task_mate/services/user_api_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/core/app_constants.dart';

class UserController extends GetxController {
  final isLoading = true.obs;

  // User Data
  final userID = 0.obs;
  final userName = ''.obs;
  final email = ''.obs;
  final mobile = ''.obs;
  final role = ''.obs;
  final avatarUrl = RxnString();
  final localAvatar = Rxn<File>();

  // App Lock
  final savedPin = RxnString();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUser();
    loadSavedPin();
  }

  Future<void> loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    savedPin.value = prefs.getString(AppConstants.appLockPinKey);
  }

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.appLockPinKey, pin);
    savedPin.value = pin;
  }

  Future<void> checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userRole = prefs.getString(AppConstants.roleKey)?.toLowerCase() ?? '';
    final uId = prefs.getInt(AppConstants.userIdKey);

    if (token == null || token.isEmpty || uId == null) {
      Get.offAllNamed(Routes.login);
      return;
    }

    switch (userRole) {
      case AppConstants.roleCeo:
      case AppConstants.roleHr:
      case AppConstants.roleManager:
      case AppConstants.roleAdmin:
      case AppConstants.roleEmployee:
        Get.offAllNamed(Routes.dashboard);
        break;
      default:
        Get.offAllNamed(Routes.login);
    }
  }

  Future<void> loadUser() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic>? userFromServer;
    try {
      // Fetch latest user from server using UserApiService
      // Note: UserApiService.getCurrentUserRole corresponds to the endpoint /auth/profile which returns {user: ...}
      userFromServer = await UserApiService.getCurrentUserRole() as Map<String, dynamic>?;

      if (userFromServer != null) {
        // Update local cache
        await prefs.setInt(AppConstants.userIdKey, userFromServer["ID"]);
        await prefs.setString(AppConstants.nameKey, userFromServer["Name"] ?? "");
        await prefs.setString(AppConstants.emailKey, userFromServer["Email"] ?? "");
        await prefs.setString(AppConstants.mobileKey, userFromServer["Mobile"] ?? "");
        await prefs.setString(AppConstants.roleKey, userFromServer["RoleName"] ?? "");
        if (userFromServer["ProfileImage"] != null) {
          await prefs.setString("avatarUrl", userFromServer["ProfileImage"]);
        }
      }
    } catch (e) {
      CustomSnackBar.warning("Offline - Showing cached data");
    }

    // Set observables from cache (or updated cache)
    userID.value = userFromServer?["ID"] ?? prefs.getInt(AppConstants.userIdKey) ?? 0;
    userName.value = userFromServer?["Name"] ?? prefs.getString(AppConstants.nameKey) ?? "";
    email.value = userFromServer?["Email"] ?? prefs.getString(AppConstants.emailKey) ?? "";
    mobile.value = userFromServer?["Mobile"] ?? prefs.getString(AppConstants.mobileKey) ?? "";
    role.value = userFromServer?["RoleName"] ?? prefs.getString(AppConstants.roleKey) ?? "";

    final localPath = prefs.getString("localAvatarPath");
    if (localPath != null && localPath.isNotEmpty) {
      localAvatar.value = File(localPath);
      avatarUrl.value = null;
    } else {
      final avatarPath = userFromServer?["ProfileImage"] ?? prefs.getString("avatarUrl");
      if (avatarPath != null && avatarPath.isNotEmpty) {
        avatarUrl.value = avatarPath;
        localAvatar.value = null;
      }
    }

    isLoading.value = false;
  }

  Future<void> logOut() async {
    await AuthApiService.clearToken();
    Get.offAllNamed(Routes.login);
  }

  Future<void> uploadPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      localAvatar.value = file; // Show immediately

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("localAvatarPath", file.path);
      CustomSnackBar.success("Profile photo updated");

      // Upload to server
      final url = await UserApiService.uploadAvatar(file);
      if (url != null) {
        avatarUrl.value = url;
        await prefs.setString("avatarUrl", url);
      }
    } catch (e) {
      CustomSnackBar.error("Error updating photo: $e");
    }
  }

  Future<void> updateMobile(String newMobile) async {
    try {
      final success = await UserApiService.updateMobile(newMobile);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.mobileKey, newMobile);
        mobile.value = newMobile;
        CustomSnackBar.success("Mobile updated successfully");
      } else {
        CustomSnackBar.error("Failed to update mobile");
      }
    } catch (e) {
      CustomSnackBar.error("Error: $e");
    }
  }
}
