import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/common/no_data.dart';
import 'package:task_mate/common/page_loader.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class AddLeaveType extends StatelessWidget {
  const AddLeaveType({super.key});

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
            SizedBox(height: 20.h),
            Form(
              key: leaveController.addLeaveTypeFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: leaveController.leaveNameController,
                    labelText: "Leave Name",
                    hintText: "Enter leave name",
                    isRequired: true,
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    controller: leaveController.leaveCountController,
                    labelText: "Leave Count",
                    hintText: "Enter leave count",
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 30.h),
                  Obx(
                    () => CustomButton(
                      icon: Icons.save,
                      text: leaveController.isLoading.value ? "Saving..." : "Save Leave Type",
                      onPressed: leaveController.isLoading.value
                          ? null
                          : leaveController.submitLeaveType,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              "Saved Leave Types",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (leaveController.isLoading.value && leaveController.leaveTypes.isEmpty) {
                return PageLoader();
              }
              if (leaveController.leaveTypes.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: NoTasksWidget(message: "No leave types found"),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leaveController.leaveTypes.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final leave = leaveController.leaveTypes[index];
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(50),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          leave.leaveName ?? "",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            "${leave.leaveCount ?? 0} Days",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
