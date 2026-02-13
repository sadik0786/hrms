import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/user/employee_controller.dart';

class EmployeeScreen extends StatelessWidget {
  EmployeeScreen({super.key});

  final EmployeeController controller = Get.put(EmployeeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Employees"), centerTitle: true),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.employees.isEmpty) {
          return const Center(child: Text("No employees found"));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchEmployees,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.employees.length,
            itemBuilder: (context, index) {
              final emp = controller.employees[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text((emp["Name"] ?? "").toString().substring(0, 1).toUpperCase()),
                  ),
                  title: Text(emp["Name"] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${emp["Email"] ?? ""}"),
                      Text("Role: ${emp["RoleName"] ?? ""}"),
                      if (emp["Mobile"] != null) Text("Mobile: ${emp["Mobile"]}"),
                    ],
                  ),
                  trailing: Text(
                    "ID: ${emp["ID"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
