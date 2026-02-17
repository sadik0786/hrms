import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/user/user_controller.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/app_constants.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/hrms/widgets/add_leave_type.dart';
import 'package:task_mate/screens/hrms/widgets/apply_leave.dart';
import 'package:task_mate/screens/hrms/widgets/approve_leave.dart';
import 'package:task_mate/screens/hrms/widgets/leave_home.dart';

class HrmsDashboard extends StatefulWidget {
  const HrmsDashboard({super.key});

  @override
  State<HrmsDashboard> createState() => _HrmsDashboardState();
}

class _HrmsDashboardState extends State<HrmsDashboard> {
  final LeaveController leaveController = Get.put(LeaveController());
  final UserController userController = Get.find<UserController>();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = userController.role.value.toLowerCase();
      // final userName = userController.userName.value;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(switch (_selectedIndex) {
            0 => "Leave Home",
            1 => "Add Leave Type",
            2 => "Apply Leave",
            3 => "Approve Leave",
            _ => "Dashboard",
          }, style: Theme.of(context).textTheme.titleLarge),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => userController.checkAuthAndNavigate(),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              const LeaveHome(),
              const AddLeaveType(), // index 1
              const ApplyLeave(), // index 2
              const ApproveLeave(), // index 3
            ],
          ),
        ),
        drawer: Drawer(
          width: 250,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 150.h,
                padding: EdgeInsets.all(15.w).copyWith(top: 80.h),
                decoration: BoxDecoration(color: ThemeClass.primaryGreen),
                child: Text(
                  'Manage Leaves',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.textWhite,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Leave Home'),
                selected: _selectedIndex == 0,
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              if (role == AppConstants.roleHr)
                ListTile(
                  title: const Text('Add Leave Type'),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    _onItemTapped(1);
                    Navigator.pop(context);
                  },
                ),
              if (role != AppConstants.roleCeo)
                ListTile(
                  title: const Text('Apply Leave'),
                  selected: _selectedIndex == 2,
                  onTap: () {
                    _onItemTapped(2);
                    Navigator.pop(context);
                  },
                ),
              if (role == AppConstants.roleCeo ||
                  role == AppConstants.roleHr ||
                  role == AppConstants.roleManager)
                ListTile(
                  title: const Text('Approve Leave'),
                  selected: _selectedIndex == 3,
                  onTap: () {
                    _onItemTapped(3);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      );
    });
  }
}
