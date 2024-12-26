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
    initShortcuts();
  }

  void initShortcuts() {
    // Example: Registering a keyboard shortcut
    // RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  static ShortcutController get to => Get.find();

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if ((event.isControlPressed || event.isMetaPressed)) {
        // Zoom in  Ctrl +   Command +
        if (event.logicalKey == LogicalKeyboardKey.add || event.logicalKey == LogicalKeyboardKey.equal) {
          ThemeController.to.fontScaleIncrease();
        }

        // Zoom Normal   Ctrl 0   Command 0
        if (event.logicalKey == LogicalKeyboardKey.digit0) {
          ThemeController.to.setFontScaleTo(1);
        }

        // Zoom out Ctrl -   Command -
        if (event.logicalKey == LogicalKeyboardKey.minus) {
          ThemeController.to.fontScaleDecrease();
        }

        //  Ctrl - R  Command - R
        // rebalance
        if (event.logicalKey == LogicalKeyboardKey.keyR) {
          Data().recalculateBalances();
        }
      }
    }
  }
}

/*
  // ignore: unused_element
  List<KeyAction> _getKeyboardBindings(final BuildContext context) {
    return <KeyAction>[
      KeyAction(
        LogicalKeyboardKey.equal,
        'Increase text size',
        () {
          DataController.to.fontScaleIncrease();
        },
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey.minus,
        'Decrease text size',
        () {
          DataController.to.fontScaleDecrease();
        },
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('0'.codeUnitAt(0)),
        'Normal text size',
        () {
          DataController.to.setFontScaleTo(1);
        },
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('t'.codeUnitAt(0)),
        'Add transactions',
        () => showImportTransactionsFromTextInput(context, ''),
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('v'.codeUnitAt(0)),
        'Paste',
        () async {
          Clipboard.getData('text/plain').then((final ClipboardData? value) {
            if (value != null) {
              showImportTransactionsFromTextInput(
                context,
                value.text ?? '',
              );
            }
          });
        },
        isMetaPressed: true,
      ),
    ];
  }

*/

class SafeKeyboardHandler {
  final Set<PhysicalKeyboardKey> _pressedKeys = {};

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
