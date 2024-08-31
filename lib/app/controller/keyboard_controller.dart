// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/theme_controller.dart';
import 'package:money/app/data/storage/data/data.dart';

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
