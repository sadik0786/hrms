import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/splash_controller.dart';
import 'package:task_mate/core/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(SplashController());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) => Transform.scale(
                  scale: controller.scaleAnimation.value,
                  child: Opacity(
                    opacity: controller.fadeAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeClass.primaryGreen.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.work_outline,
                        size: 80.sp,
                        color: controller.colorAnimation.value ?? ThemeClass.textWhite,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // App Name
              AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) => Opacity(
                  opacity: controller.fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - controller.fadeAnimation.value)),
                    child: Column(
                      children: [
                        Text(
                          "Task Mate",
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: ThemeClass.textWhite,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Employee Task Management System",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: ThemeClass.textWhite.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 50.h),

              // Loading Indicator
              AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) => Opacity(
                  opacity: controller.fadeAnimation.value,
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                      valueColor: const AlwaysStoppedAnimation<Color>(ThemeClass.primaryGreen),
                      backgroundColor: ThemeClass.textWhite.withOpacity(0.2),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Loading Text
              AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) => Opacity(
                  opacity: controller.fadeAnimation.value,
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: ThemeClass.textWhite.withOpacity(0.7), fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
