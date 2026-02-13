import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/model/auth/login_request_model.dart';
import 'package:task_mate/model/auth/login_response_model.dart';
import 'package:task_mate/model/auth/register_request_model.dart';
import 'package:task_mate/model/auth/register_response_model.dart';

final String baseUrl = dotenv.env['baseApiUrl'] ?? '';

class AuthApiService {
  /// ------------------- Token Management -------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  /// ------------------- Internet Check -------------------
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on Exception {
      return false;
    }
  }
  // Validate current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return {"success": false, "error": "No token"};

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true && data["user"] != null) {
          return {"success": true, "user": data["user"]};
        }
        return {"success": false, "error": "User not found"};
      }

      return {"success": false, "error": "Server returned ${res.statusCode}"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // Register new emp
  static Future<RegisterResponseModel> registerEmployee(RegisterRequestModel request) async {
    try {
      final token = await getToken();
      // print('TOKEN: $token');

      if (token == null) {
        return RegisterResponseModel(success: false);
      }

      final res = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(res.body);

      print("STATUS: ${res.statusCode}");
      print("RESPONSE: ${res.body}");

      return RegisterResponseModel.fromJson(data);
    } catch (e) {
      return RegisterResponseModel(success: false);
    }
  }

  // Login
  static Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      // Convert response to model
      final loginResponse = LoginResponseModel.fromJson(data);

      if (loginResponse.success == true &&
          loginResponse.token != null &&
          loginResponse.user != null) {
        print('TOKEN: ${loginResponse.token}');
        await saveToken(loginResponse.token!);

        final prefs = await SharedPreferences.getInstance();

        // Save user data using model
        await prefs.setInt('userId', loginResponse.user!.id ?? 0);
        await prefs.setString('name', loginResponse.user!.name ?? '');
        await prefs.setString('email', loginResponse.user!.email ?? '');
        await prefs.setString('mobile', loginResponse.user!.mobile ?? '');
        await prefs.setInt('roleId', loginResponse.user!.roleId ?? 0);
        await prefs.setString('role', loginResponse.user!.role?.toLowerCase() ?? '');

        return loginResponse;
      } else {
        return LoginResponseModel(success: false, message: loginResponse.message ?? "Login failed");
      }
    } catch (e) {
      return LoginResponseModel(success: false, message: "Network error: ${e.toString()}");
    }
  }

  //
}
