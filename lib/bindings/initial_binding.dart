import 'package:get/get.dart';
import 'package:task_mate/controllers/user/user_controller.dart';
import 'package:task_mate/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(UserController(), permanent: true);
  }
}
