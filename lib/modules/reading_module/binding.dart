import 'package:get/get.dart';

import 'controller.dart';

class ReadingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReadingController());
  }
}
