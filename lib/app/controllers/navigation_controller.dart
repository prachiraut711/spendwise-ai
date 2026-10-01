import 'package:get/get.dart';

/// GetX controller managing the bottom navigation state and active tab.
class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
