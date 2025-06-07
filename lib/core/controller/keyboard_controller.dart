// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/theme_controller.dart';
import 'package:money/data/storage/data/data.dart';

/// Controller for handling keyboard shortcuts and hotkeys.
/// Features:
/// - Zoom in/out shortcuts
/// - Font scaling shortcuts
/// - Data refresh shortcuts
/// - Custom shortcut registration
class ShortcutController extends GetxController {
  @override
  void onClose() {
    // Clean up listeners when controller is closed
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize your keyboard shortcuts
  }

  static ShortcutController get to => Get.find();
}

class SafeKeyboardHandler {
  final Set<PhysicalKeyboardKey> _pressedKeys = <PhysicalKeyboardKey>{};

  void clearKeys() {
    _pressedKeys.clear();
  }

  void dispose() {
    clearKeys();
  }

  bool onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (_pressedKeys.contains(event.physicalKey)) {
        // Key is already marked as pressed, clear and re-add
        _pressedKeys.remove(event.physicalKey);
      }
      _pressedKeys.add(event.physicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.physicalKey);
    }
    return false; // Allow event to continue propagating
  }
}
