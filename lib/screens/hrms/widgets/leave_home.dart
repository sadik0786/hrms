import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaveHome extends StatelessWidget {
  const LeaveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(),
            Text("Leave Home", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
