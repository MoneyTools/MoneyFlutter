import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/controller/theme_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/color_palette.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/widgets.dart';
import 'package:money/core/widgets/zoom.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/data/storage/import/import_transactions_from_text.dart';
import 'package:money/data/storage/import/import_wizard.dart';
import 'package:money/views/home/sub_views/app_title.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final PreferenceController preferencesController = Get.find<PreferenceController>();

    return AppBar(
      backgroundColor: getColorTheme(context).secondaryContainer,
      leading: _buildPopupMenu(),
      title: AppTitle(),
      actions: <Widget>[
        if (!context.isWidthSmall) _buildToggleClosedAccountsButton(preferencesController),
        _buildToggleThemeButton(themeController),
        _buildSettingsMenu(themeController, preferencesController),
      ],
    );
  }

  void onAppBarAction(int value) {
    switch (value) {
      case Constants.commandAddTransactions:
        showImportTransactionsFromTextInput(Get.context!);
        break;
      case Constants.commandSettings:
        Get.toNamed<dynamic>(Constants.routeSettingsPage);
        break;
      case Constants.commandInstallPlatforms:
        Get.toNamed<dynamic>(Constants.routeInstallPlatformsPage);
        break;
      case Constants.commandIncludeClosedAccount:
        PreferenceController.to.includeClosedAccounts = !PreferenceController.to.includeClosedAccounts;
        break;
      default:
        ThemeController.to.setThemeColor(value);
    }
    DataController.to.update();
  }

  PopupMenuItem<int> _buildMenuItem(int value, String caption, IconData iconData) {
    return PopupMenuItem<int>(
      value: value,
      child: ThreePartLabel(
        icon: Icon(iconData),
        text1: caption,
        small: true,
      ),
    );
  }

  Widget _buildPopupMenu() {
    final List<PopupMenuItem<int>> menuItems = <PopupMenuItem<int>>[
      _buildMenuItem(Constants.commandFileNew, 'New', Icons.note_add_outlined),
      _buildMenuItem(Constants.commandFileOpen, 'Open...', Icons.file_open_outlined),
      _buildMenuItem(Constants.commandAddTransactions, 'Add transactions...', Icons.post_add_outlined),
      _buildMenuItem(Constants.commandRebalance, 'Rebalance...', Icons.refresh_outlined),
      if (!kIsWeb) ...<PopupMenuItem<int>>[
        _buildMenuItem(Constants.commandFileLocation, 'File location...', Icons.folder_open_outlined),
        _buildMenuItem(Constants.commandFileSaveCsv, 'Save to CSV', Icons.save),
        _buildMenuItem(Constants.commandFileSaveSql, 'Save to SQL', Icons.save),
      ],
      _buildMenuItem(Constants.commandFileClose, 'Close file', Icons.close),
    ];

    return myPopupMenuIconButton(
      key: const Key('key_menu_button'),
      icon: Icons.menu,
      tooltip: 'File menu',
      list: menuItems,
      onSelected: _handleMenuSelection,
    );
  }

  Widget _buildSettingsMenu(ThemeController themeController, PreferenceController preferencesController) {
    final List<PopupMenuItem<int>> actionList = <PopupMenuItem<int>>[
      _buildSettingsMenuItem(
        Constants.commandIncludeClosedAccount,
        preferencesController.includeClosedAccounts ? 'Hide "Closed Accounts"' : 'Show "Closed Account"',
        Icons.inventory,
        opacity: preferencesController.includeClosedAccounts ? 1.0 : 0.5,
      ),
      _buildSettingsMenuItem(Constants.commandSettings, 'Settings...', Icons.settings, key: const Key('key_settings')),
      _buildSettingsMenuItem(Constants.commandInstallPlatforms, 'Install App...', Icons.install_desktop, key: const Key('key_platforms')),
      ..._buildThemeColorMenuItems(themeController),
      PopupMenuItem<int>(
        value: Constants.commandTextZoom,
        child: ZoomIncreaseDecrease(
          title: 'Zoom',
          onDecrease: ThemeController.to.fontScaleDecrease,
          onIncrease: ThemeController.to.fontScaleIncrease,
        ),
      ),
    ];

    if (kDebugMode) {
      actionList.add(
        const PopupMenuItem<int>(
          value: -1,
          child: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: ColorPalette(),
            ),
          ),
        ),
      );
    }

    return myPopupMenuIconButton(
      key: Constants.keySettingsButton,
      icon: Icons.settings_outlined,
      tooltip: 'Settings',
      list: actionList,
      onSelected: onAppBarAction,
    );
  }

  PopupMenuItem<int> _buildSettingsMenuItem(
    int value,
    String text,
    IconData iconData, {
    Key? key,
    double opacity = 1.0,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: ThreePartLabel(
        key: key,
        text1: text,
        icon: Opacity(opacity: opacity, child: Icon(iconData, color: Colors.grey)),
        small: true,
      ),
    );
  }

  List<PopupMenuItem<int>> _buildThemeColorMenuItems(ThemeController themeController) {
    return List<PopupMenuItem<int>>.generate(
      themeAsColors.length,
      (int index) {
        final bool isSelected = index == themeController.colorSelected.value;
        final String themeColorName = themeColorNames[index];

        return PopupMenuItem<int>(
          value: index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? getColorTheme(Get.context!).secondaryContainer : null,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: ThreePartLabel(
              key: Key('key_theme_$themeColorName'),
              icon: Icon(
                isSelected ? Icons.color_lens : Icons.color_lens_outlined,
                color: themeAsColors[index],
              ),
              text1: themeColorName,
              small: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleClosedAccountsButton(PreferenceController preferencesController) {
    return IconButton(
      icon: Opacity(
        opacity: preferencesController.includeClosedAccounts ? 1.0 : 0.5,
        child: const Icon(Icons.inventory, size: 18),
      ),
      onPressed: () => preferencesController.includeClosedAccounts = !preferencesController.includeClosedAccounts,
      tooltip: preferencesController.includeClosedAccounts ? 'Hide closed accounts' : 'View closed accounts',
    );
  }

  Widget _buildToggleThemeButton(ThemeController themeController) {
    return IconButton(
      key: const Key('key_toggle_mode'),
      icon: Icon(themeController.isDarkTheme.value ? Icons.wb_sunny : Icons.mode_night),
      onPressed: ThemeController.to.toggleThemeMode,
      tooltip: 'Toggle brightness',
    );
  }

  void _handleMenuSelection(int index) {
    switch (index) {
      case Constants.commandFileNew:
        Get.offAllNamed<dynamic>(Constants.routeHomePage);
        DataController.to.onFileNew();
        break;
      case Constants.commandFileOpen:
        DataController.to.onFileOpen().then((_) {
          Get.offAllNamed<dynamic>(Constants.routeHomePage);
        });
        break;
      case Constants.commandFileLocation:
        DataController.to.onShowFileLocation();
        break;
      case Constants.commandAddTransactions:
        showImportTransactionsWizard();
        break;
      case Constants.commandRebalance:
        Data().recalculateBalances();
        break;
      case Constants.commandFileSaveCsv:
        DataController.to.onSaveToCsv();
        break;
      case Constants.commandFileSaveSql:
        DataController.to.onSaveToSql();
        break;
      case Constants.commandFileClose:
        DataController.to.closeFile();
        Get.offAllNamed<dynamic>(Constants.routeWelcomePage);
        break;
      default:
        debugPrint('Unhandled menu item: $index');
    }
  }
}
