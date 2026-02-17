import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_date_field.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ApplyLeave extends StatelessWidget {
  const ApplyLeave({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaveController leaveController = Get.find<LeaveController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Form(
                key: leaveController.applyLeaveFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownField<int>(
                      labelText: "Leave Type",
                      isRequired: true,
                      hintText: "Select leave type",
                      prefixIcon: Icons.event_note,
                      items: leaveController.leaveTypes.map((p) {
                        return {"id": p.id ?? 0, "name": p.leaveName ?? ""};
                      }).toList(),
                      valueKey: "id",
                      labelKey: "name",
                      value: leaveController.selectedLeaveTypeId.value,
                      isEnabled: true,
                      onChanged: leaveController.onLeaveTypeChanged,
                    ),
                    SizedBox(height: 10.h),
                    CustomDateField(
                      labelText: "From Date",
                      isRequired: true,
                      selectedDate: leaveController.fromDate.value,
                      hintText: "Select from date",
                      prefixIcon: Icons.calendar_today,
                      onTap: () => leaveController.pickDate(context, true),
                    ),
                    SizedBox(height: 10.h),
                    CustomDateField(
                      labelText: "To Date",
                      isRequired: true,
                      selectedDate: leaveController.toDate.value,
                      hintText: "Select to date",
                      prefixIcon: Icons.calendar_today,
                      onTap: () => leaveController.pickDate(context, false),
                    ),
                    SizedBox(height: 10.h),
                    CustomDropdownField<int>(
                      labelText: "Leave Session",
                      isRequired: true,
                      hintText: "Select session",
                      prefixIcon: Icons.access_time,
                      items: leaveController.leaveSessions,
                      valueKey: "id",
                      labelKey: "name",
                      value: leaveController.selectedSessionId.value,
                      isEnabled: true,
                      onChanged: (val) {
                        if (val != null) {
                          leaveController.selectedSessionId.value = val;
                        }
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: "Reason",
                      hintText: "Enter Reason",
                      controller: leaveController.reasonController,
                      prefixIcon: Icons.description,
                    ),
                    SizedBox(height: 30.h),
                    CustomButton(
                      icon: Icons.send,
                      text: leaveController.isLoading.value ? "Applying..." : "Apply Leave",
                      onPressed: leaveController.isLoading.value
                          ? null
                          : leaveController.submitLeaveRequest,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
