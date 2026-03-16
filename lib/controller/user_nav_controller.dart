import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserNavController extends GetxController {
  final currentIndex = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    currentIndex.value = index;
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
