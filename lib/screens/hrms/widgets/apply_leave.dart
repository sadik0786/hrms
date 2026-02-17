import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
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
            Obx(() {
              final selected = leaveController.selectedLeaveType;

              return Column(
                children: [
                  if (selected != null) ...[
                    leaveCard(
                      context,
                      leaveName: selected.leaveName ?? "Selected Leave",
                      total: selected.leaveCount?.toDouble() ?? 0,
                      used: leaveController.calculateUsedLeaves(selected.leaveName),
                      pendingDays: leaveController.calculatePendingLeaves(selected.leaveName),
                      selectedDays: leaveController.calculateLeaveDays(),
                    ),
                    SizedBox(height: 20.h),
                  ],
                  Form(
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
                ],
              );
            }),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget leaveCard(
    BuildContext context, {
    required String leaveName,
    required double total,
    required double used,
    required double pendingDays,
    required double selectedDays,
  }) {
    final balance = total - used;

    return Card(
      color: ThemeClass.darkCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      shadowColor: Colors.white54,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.w,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leaveName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeClass.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pendingDays > 0 ? "(Pending: $pendingDays)" : "",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeClass.warningColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _balanceItem(context, "Total", total.toString()),
                _balanceItem(context, "Used", used.toString()),
                _balanceItem(context, "Balance", balance.toString(), isHighlight: true),
              ],
            ),
            if (selectedDays > 0) ...[
              const Divider(color: Colors.white10, height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Days Selected", style: Theme.of(context).textTheme.bodyLarge),
                  Text(
                    selectedDays.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.orangeAccent),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _balanceItem(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.greenAccent : null,
          ),
        ),
      ],
    );
  }
}
