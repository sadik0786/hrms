import 'package:get/get.dart';
import 'package:task_mate/services/user_api_service.dart';

class EmployeeController extends GetxController {
  RxBool loading = false.obs;
  RxList<Map<String, dynamic>> employees = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    loading.value = true;

    final result = await UserApiService.getAllEmployees();
    employees.value = result;

    loading.value = false;
  }
}
