import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/common/no_data.dart';
import 'package:task_mate/common/page_loader.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/model/hrms/leave_request_model.dart';
import 'package:task_mate/utils/common_fn.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ApproveLeave extends StatefulWidget {
  const ApproveLeave({super.key});

  @override
  State<ApproveLeave> createState() => _ApproveLeaveState();
}

class _ApproveLeaveState extends State<ApproveLeave> {
  final LeaveController leaveController = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: ThemeClass.primaryGreen,
            labelColor: ThemeClass.primaryGreen,
            unselectedLabelColor: Colors.grey[400],
            indicatorWeight: 3.r,
            labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: Obx(() {
            if (leaveController.isLoading.value && leaveController.otherLeavesRequest.isEmpty) {
              return const PageLoader();
            }

            final pendingLeaves = leaveController.otherLeavesRequest
                .where((e) => e.status.toString().toUpperCase() == "PENDING")
                .toList();

            final completedLeaves = leaveController.otherLeavesRequest
                .where(
                  (e) =>
                      e.status.toString().toUpperCase() == "APPROVED" ||
                      e.status.toString().toUpperCase() == "REJECTED",
                )
                .toList()
                .reversed
                .toList(); // Newest first

            return TabBarView(
              children: [
                // PENDING TAB
                RefreshIndicator(
                  onRefresh: () => leaveController.fetchOtherLeaves(),
                  child: pendingLeaves.isEmpty
                      ? Center(child: NoTasksWidget(message: "No pending leave requests"))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: pendingLeaves.length,
                          itemBuilder: (context, index) {
                            return _approvalCard(pendingLeaves[index]);
                          },
                        ),
                ),

                // COMPLETED TAB
                RefreshIndicator(
                  onRefresh: () => leaveController.fetchOtherLeaves(),
                  child: completedLeaves.isEmpty
                      ? Center(child: NoTasksWidget(message: "No completed leave records"))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: completedLeaves.length,
                          itemBuilder: (context, index) {
                            return _completedCard(completedLeaves[index]);
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// ---------------- COMPLETED CARD ----------------
  Widget _completedCard(LeaveRequestModel leave) {
    final bool isApproved = leave.status.toString().toUpperCase() == "APPROVED";

    return GestureDetector(
      onTap: () => _showLeaveDetailBottomSheet(leave),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: (isApproved ? Colors.green : Colors.red).withOpacity(0.1),
              child: Icon(
                isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isApproved ? Colors.green : Colors.red,
                size: 26.sp,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.employeeName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${CommonFn.formatDate(leave.fromDate)} - ${CommonFn.formatDate(leave.toDate)}",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusIndicatorChip(leave.status.toString().toUpperCase()),
                SizedBox(height: 4.h),
                Text(
                  "${leave.totalDays}d",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicatorChip(String status) {
    final bool isApproved = status == "APPROVED";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: (isApproved ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isApproved ? Colors.green : Colors.red,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _showLeaveDetailBottomSheet(LeaveRequestModel leave) {
    final bool isApproved = leave.status.toString().toUpperCase() == "APPROVED";

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Leave Details",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  _statusIndicatorChip(leave.status.toString().toUpperCase()),
                ],
              ),
              SizedBox(height: 25.h),
              _detailRow(Icons.person_outline_rounded, "Employee", leave.employeeName),
              _detailRow(Icons.category_outlined, "Leave Type", leave.leaveTypeName),
              _detailRow(
                Icons.calendar_today_rounded,
                "Duration",
                "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)} (${leave.totalDays} Days)",
              ),
              _detailRow(Icons.text_fields_rounded, "Employee Reason", leave.reason ?? "N/A"),
              Divider(height: 30.h, color: Colors.grey[100]),
              _detailRow(
                isApproved ? Icons.verified_user_outlined : Icons.report_gmailerrorred_rounded,
                isApproved ? "Approved By" : "Rejected By",
                leave.approverName ?? "System",
                valueColor: isApproved ? Colors.green : Colors.red,
              ),
              _detailRow(
                Icons.comment_bank_outlined,
                "Admin Remarks",
                leave.rejectReason ?? "No remarks provided",
                isLast: true,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: CustomButton(text: "Close", onPressed: () => Get.back()),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: Colors.grey[600]),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- APPROVAL CARD ----------------
  Widget _approvalCard(LeaveRequestModel leave) {
    final isHr = leaveController.userRole.value.toLowerCase() == "hr";

    // ensure default value exists in the reactive map
    leaveController.hrApprovalMap.putIfAbsent(leave.id, () => false);

    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      color: ThemeClass.tealGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Colors.white, width: 1.2),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leave.employeeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _statusChip("${leave.totalDays} days"),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leave.leaveTypeName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                Text(
                  "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
            if (leave.reason != null && leave.reason!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                "Reason: ${leave.reason}",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white60, fontStyle: FontStyle.italic),
              ),
            ],
            SizedBox(height: isHr ? 5.h : 10.h),

            // ✅ SHOW CHECKBOX ONLY FOR HR
            if (isHr)
              Obx(
                () => GestureDetector(
                  onTap: () {
                    final currentVal = leaveController.hrApprovalMap[leave.id] ?? false;
                    leaveController.hrApprovalMap[leave.id] = !currentVal;
                    if (leaveController.hrApprovalMap[leave.id] == true) {
                      _showHrReasonBottomSheet(leave.id, isReject: false);
                    }
                  },
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                          value: leaveController.hrApprovalMap[leave.id] ?? false,
                          checkColor: ThemeClass.tealGreen,
                          activeColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (val) {
                            leaveController.hrApprovalMap[leave.id] = val!;
                            if (val) {
                              _showHrReasonBottomSheet(leave.id, isReject: false);
                            }
                          },
                        ),
                      ),
                      Text(
                        "Approve as HR with reason",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ),

            // ACTION BUTTONS
            SwipeApproveReject(leave: leave),
          ],
        ),
      ),
    );
  }

  /// ---------------- STATUS CHIP ----------------
  Widget _statusChip(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: ThemeClass.tealGreen,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(color: ThemeClass.textWhite, fontWeight: FontWeight.bold, fontSize: 12.sp),
      ),
    );
  }

  ///
  void _showHrReasonBottomSheet(int leaveId, {bool isReject = false}) {
    final TextEditingController reasonCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isReject ? "Reject Reason" : "HR Approval Reason",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 15.h),
            CustomTextField(
              hintText: "Enter reason here...",
              keyboardType: TextInputType.text,
              controller: reasonCtrl,
              maxLines: 2,
            ),
            SizedBox(height: 20.h),
            CustomButton(
              text: isReject ? "Reject" : "Approve",
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) {
                  CustomSnackBar.error("Reason required");
                  return;
                }

                final status = isReject ? "REJECTED" : "APPROVED";
                leaveController.updateLeaveStatus(leaveId, status, reasonCtrl.text.trim());
                Get.back();
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class SwipeApproveReject extends StatefulWidget {
  final LeaveRequestModel leave;
  const SwipeApproveReject({super.key, required this.leave});

  @override
  State<SwipeApproveReject> createState() => _SwipeApproveRejectState();
}

class _SwipeApproveRejectState extends State<SwipeApproveReject> {
  double dragPosition = 0.0; // -1 = left, 0 = center, 1 = right
  bool isCompleted = false; // to lock thumb after decision
  final LeaveController leaveController = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.h,
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: isCompleted
            ? (dragPosition > 0 ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.2))
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LEFT TEXT (Reject)
          Positioned(
            left: 20.w,
            child: Opacity(
              opacity: dragPosition < 0 ? 1.0 : 0.5,
              child: Text(
                "REJECT",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),

          // RIGHT TEXT (Approve)
          Positioned(
            right: 20.w,
            child: Opacity(
              opacity: dragPosition > 0 ? 1.0 : 0.5,
              child: Text(
                "APPROVE",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
            ),
          ),

          // DRAGGABLE THUMB
          Align(
            alignment: Alignment(dragPosition, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: isCompleted
                  ? null
                  : (details) {
                      setState(() {
                        dragPosition += details.delta.dx / 100.w;
                        dragPosition = dragPosition.clamp(-1.0, 1.0);
                      });
                    },
              onHorizontalDragEnd: (details) {
                if (dragPosition > 0.7) {
                  setState(() {
                    dragPosition = 1.0;
                    isCompleted = true;
                  });
                  leaveController.updateLeaveStatus(widget.leave.id, "APPROVED", "");
                } else if (dragPosition < -0.7) {
                  setState(() {
                    dragPosition = -1.0;
                    isCompleted = true;
                  });
                  _showRejectReasonDialog();
                } else {
                  setState(() {
                    dragPosition = 0.0;
                  });
                }
              },
              child: Container(
                width: 80.w,
                height: 38.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Icon(
                  isCompleted ? (dragPosition > 0 ? Icons.check : Icons.close) : Icons.swap_horiz,
                  color: dragPosition > 0
                      ? Colors.green
                      : (dragPosition < 0 ? Colors.red : Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectReasonDialog() {
    final TextEditingController reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Reject Reason", style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: reasonCtrl,
              hintText: "Why are you rejecting?",
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                dragPosition = 0.0;
                isCompleted = false;
              });
              Get.back();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                CustomSnackBar.error("Reason is required");
                return;
              }
              leaveController.updateLeaveStatus(
                widget.leave.id,
                "REJECTED",
                reasonCtrl.text.trim(),
              );
              Get.back();
            },
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
