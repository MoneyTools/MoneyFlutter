import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final RxDouble scrollPosition = 0.0.obs;

  double bookmark = -1;

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

  void scrollToBookmark() {
    if (bookmark != -1) {
      scrollController.animateTo(
        bookmark,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollListener() {
    scrollPosition.value = scrollController.offset;
  }
}

class ListControllerMain extends ListController {}

class ListControllerSidePanel extends ListController {}
