import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:task_mate/services/auth_api_service.dart';

import 'package:task_mate/model/hrms/leave_apply_request_model.dart';

final String baseUrl = dotenv.env['baseApiUrl'] ?? '';

class HrmsApiService {
  // add leave type
  static Future<Map<String, dynamic>> addLeaveType({
    required String leaveName,
    required int leaveCount,
  }) async {
    try {
      final token = await AuthApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }
      final res = await http.post(
        Uri.parse("$baseUrl/hrms/leave-types"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"leaveName": leaveName, "leaveCount": leaveCount}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // get all leaves type
  static Future<List<dynamic>> fetchAllLeaveTypes() async {
    final token = await AuthApiService.getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/hrms/leave-types"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data["success"] == true) {
      return data["data"] ?? [];
    }
    throw Exception(data["error"] ?? "Failed to fetch leave");
  }

  // apply leave
  static Future<Map<String, dynamic>> applyLeave(LeaveApplyRequestModel model) async {
    try {
      final token = await AuthApiService.getToken();
      if (token == null) {
        return {"success": false, "error": "No token found"};
      }
      final res = await http.post(
        Uri.parse("$baseUrl/hrms/apply-leave"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(model.toJson()),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
