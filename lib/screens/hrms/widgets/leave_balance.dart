import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/common/no_data.dart';
import 'package:task_mate/common/page_loader.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/utils/common_fn.dart';

class LeaveBalance extends StatelessWidget {
  const LeaveBalance({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaveController controller = Get.find<LeaveController>();

    final List<List<Color>> dialerGradients = [
      [const Color(0xFF6366F1), const Color(0xFFA5B4FC)], // Trendy Indigo
      [const Color(0xFF10B981), const Color(0xFF6EE7B7)], // Vibrant Emerald
      [const Color(0xFFF59E0B), const Color(0xFFFCD34D)], // Modern Amber
      [const Color(0xFF3B82F6), const Color(0xFF93C5FD)], // Tech Blue
      [const Color(0xFFEC4899), const Color(0xFFF9A8D4)], // Stylish Pink
      [const Color(0xFF8B5CF6), const Color(0xFFC4B5FD)], // Royal Violet
      [const Color(0xFFF97316), const Color(0xFFFDBA74)], // Sunset Orange
      [const Color(0xFF06B6D4), const Color(0xFF67E8F9)], // Ocean Teal
      [const Color(0xFFF43F5E), const Color(0xFFFB7185)], // Hot Rose
    ];

    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      body: Column(
        children: [
          // Elegant Semi-Transparent Header
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(offset: Offset(0, -15 * (1 - value)), child: child),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeClass.primaryGreen,
                    ThemeClass.primaryGreen.withOpacity(0.85),
                    const Color(0xFF006D55),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Leave Cycle",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 14.sp),
                        SizedBox(width: 8.w),
                        Text(
                          CommonFn.getFinancialYear(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trendy Cards List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const PageLoader();
              }

              if (controller.leaveTypes.isEmpty) {
                return const NoTasksWidget(message: "No leave records found");
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchLeaveTypes(),
                color: ThemeClass.primaryGreen,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(15.w, 24.h, 15.w, 80.h),
                  itemCount: controller.leaveTypes.length,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemBuilder: (context, index) {
                    final leaveType = controller.leaveTypes[index];
                    final used = controller.calculateUsedLeaves(leaveType.leaveName);
                    final total = (leaveType.leaveCount ?? 0).toDouble();
                    final balance = total - used;
                    final progress = total > 0 ? (used / total) : 0.0;
                    final colors = dialerGradients[index % dialerGradients.length];

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 700 + (index * 120)),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 40 * (1 - value)),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20.h),
                              decoration: BoxDecoration(
                                color: ThemeClass.darkCardColor,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: colors[0].withOpacity(
                                    0.7 * value,
                                  ), // Animate border opacity
                                  width: (1.2 + (0.6 * value)).w, // Animate border thickness
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors[0].withOpacity(0.12 * value), // Animate shadow
                                    blurRadius: 25,
                                    spreadRadius: 2 * value,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Stack(
                          children: [
                            // Subtle radial gradient background for the trendy look
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 150.w,
                                height: 150.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [colors[0].withOpacity(0.12), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildModernKnob(progress, balance, colors[0]),
                                  SizedBox(width: 24.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          leaveType.leaveName ?? "Unknown",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        SizedBox(height: 14.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDataMetric(
                                                icon: Icons.check_circle_outline_rounded,
                                                label: "Used",
                                                value: used.toStringAsFixed(1),
                                                color: colors[0],
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: _buildDataMetric(
                                                icon: Icons.list_alt_rounded,
                                                label: "Total",
                                                value: total.toStringAsFixed(1),
                                                color: Colors.white38,
                                                isTotal: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),
                  );
                },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModernKnob(double progress, double balance, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.fastLinearToSlowEaseIn,
      builder: (context, value, child) {
        return Container(
          width: 92.w,
          height: 92.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black12,
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: 82.w,
                height: 82.w,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 9.w,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.06)),
                ),
              ),
              // Actual Progress - Natural Top Center Start Point
              SizedBox(
                width: 82.w,
                height: 82.w,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 9.w,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Balance Center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    balance.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "Balance",
                    style: TextStyle(
                      fontSize: 10.sp, // Slightly larger
                      color: Colors.white70, // Increased visibility
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isTotal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.sp, color: isTotal ? Colors.white60 : color.withOpacity(0.9)),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp, // Slightly larger
                color: Colors.white60, // Significantly increased visibility from white38
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            color: isTotal ? Colors.white.withOpacity(0.8) : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
