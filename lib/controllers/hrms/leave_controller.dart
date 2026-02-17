import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/model/hrms/leave_apply_request_model.dart';
import 'package:task_mate/model/hrms/leave_type_response_model.dart';
import 'package:task_mate/services/hrms_api_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';

class LeaveController extends GetxController {
  /// FORM KEYS
  final addLeaveTypeFormKey = GlobalKey<FormState>();
  final applyLeaveFormKey = GlobalKey<FormState>();

  /// TEXT CONTROLLERS
  final leaveNameController = TextEditingController();
  final leaveCountController = TextEditingController();
  final reasonController = TextEditingController();

  /// DATA LIST
  RxList<LeaveTypeData> leaveTypes = <LeaveTypeData>[].obs;

  /// APPLY LEAVE STATE
  var selectedLeaveTypeId = Rxn<int>();
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  var selectedSessionId = 1.obs; // 1: Full Day, 2: First Half, 3: Second Half

  final List<Map<String, dynamic>> leaveSessions = [
    {"id": 1, "name": "Full Day"},
    {"id": 2, "name": "First Half"},
    {"id": 3, "name": "Second Half"},
  ];

  /// LOADING
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveTypes();
  }

  void onLeaveTypeChanged(int? id) {
    selectedLeaveTypeId.value = id;
  }

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isFrom) {
        fromDate.value = picked;
      } else {
        toDate.value = picked;
      }
    }
  }

  /// SUBMIT LEAVE TYPE
  Future<void> submitLeaveType() async {
    if (isLoading.value) return;
    if (!addLeaveTypeFormKey.currentState!.validate()) return;

    final leaveName = leaveNameController.text.trim();
    final leaveCount = int.tryParse(leaveCountController.text.trim()) ?? 0;

    final success = await addLeaveType(leaveName: leaveName, leaveCount: leaveCount);

    if (success) {
      Get.back();
      CustomSnackBar.success("Leave type added successfully");
    }
  }

  /// SUBMIT LEAVE REQUEST
  Future<void> submitLeaveRequest() async {
    if (isLoading.value) return;
    if (!applyLeaveFormKey.currentState!.validate()) return;
    if (selectedLeaveTypeId.value == null) {
      CustomSnackBar.warning("Please select a leave type");
      return;
    }
    if (fromDate.value == null || toDate.value == null) {
      CustomSnackBar.warning("Please select dates");
      return;
    }

    try {
      isLoading.value = true;

      // Calculate days
      final duration = toDate.value!.difference(fromDate.value!).inDays + 1;
      double daysCount = duration.toDouble();
      if (selectedSessionId.value != 1) {
        daysCount = 0.5; // If not full day, assume 0.5 for demonstration
      }

      final request = LeaveApplyRequestModel(
        leaveTypeId: selectedLeaveTypeId.value!,
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate.value!),
        toDate: DateFormat('yyyy-MM-dd').format(toDate.value!),
        days: daysCount,
        sessionDay: selectedSessionId.value,
        reason: reasonController.text.trim(),
      );

      final res = await HrmsApiService.applyLeave(request);

      if (res["success"] == true) {
        CustomSnackBar.success("Leave applied successfully");
        // Clear fields
        selectedLeaveTypeId.value = null;
        fromDate.value = null;
        toDate.value = null;
        selectedSessionId.value = 1;
        reasonController.clear();
      } else {
        CustomSnackBar.error(res["message"] ?? "Failed to apply leave");
      }
    } catch (e) {
      CustomSnackBar.error("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ADD LEAVE TYPE API
  Future<bool> addLeaveType({required String leaveName, required int leaveCount}) async {
    try {
      isLoading.value = true;
      final res = await HrmsApiService.addLeaveType(leaveName: leaveName, leaveCount: leaveCount);
      if (res["success"] == true) {
        fetchLeaveTypes();
        leaveNameController.clear();
        leaveCountController.clear();
        return true;
      } else {
        throw res["message"] ?? res["error"] ?? "Failed to add leave type";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// FETCH ALL LEAVE TYPES
  Future<void> fetchLeaveTypes() async {
    try {
      isLoading.value = true;
      final data = await HrmsApiService.fetchAllLeaveTypes();
      leaveTypes.assignAll(data.map((e) => LeaveTypeData.fromJson(e)).toList());
    } catch (e) {
      CustomSnackBar.error("Error - $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    leaveNameController.dispose();
    leaveCountController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
