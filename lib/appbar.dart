import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money/app_title.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/storage/import/import_wizard.dart';
import 'package:money/views/view_settings.dart';
import 'package:money/widgets/color_palette.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/widgets/zoom.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function() onFileNew;
  final void Function() onFileOpen;
  final void Function() onFileClose;
  final void Function() onShowFileLocation;
  final void Function() onSaveCsv;
  final void Function() onSaveSql;

  const MyAppBar({
    super.key,
    required this.onFileNew,
    required this.onFileOpen,
    required this.onFileClose,
    required this.onShowFileLocation,
    required this.onSaveCsv,
    required this.onSaveSql,
  });

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(final BuildContext context) {
    return AppBar(
      backgroundColor: getColorTheme(context).secondaryContainer,

      // Menu
      leading: _buildPopupMenu(),

      // Center Title
      title: AppTitle(),

      // Button on the right side
      actions: <Widget>[
        // Hide/Show closed accounts
        if (!Settings().isSmallScreen) _buildButtonToggleViewClosedAccounts(),

        // Dark / Light mode
        IconButton(
          icon: Settings().useDarkMode ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
          onPressed: () {
            Settings().useDarkMode = !Settings().useDarkMode;
            Settings().preferrenceSave();
          },
          tooltip: 'Toggle brightness',
        ),
        _buildSettingsMenu(),
      ],
    );
  }

  Widget _buildButtonToggleViewClosedAccounts() {
    return IconButton(
      icon: _buildButtonToggleViewClosedAccountsIcon(),
      onPressed: () {
        Settings().includeClosedAccounts = !Settings().includeClosedAccounts;
      },
      tooltip: Settings().includeClosedAccounts ? 'Hide closed accounts' : 'View closed accounts',
    );
  }

  Widget _buildButtonToggleViewClosedAccountsIcon() {
    return Opacity(
      opacity: Settings().includeClosedAccounts ? 1.0 : 0.5,
      child: const Icon(
        Icons.inventory,
        size: 18,
      ),
    );
  }

  Widget _buildPopupMenu() {
    final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
    // New
    addMenuItem(list, Constants.commandFileNew, 'New', Icons.new_label);

    // Open
    addMenuItem(list, Constants.commandFileOpen, 'Open...', Icons.file_open_outlined);

    // Add Transactions
    addMenuItem(list, Constants.commandAddTransactions, 'Add transactions...', Icons.post_add_outlined);

    // File Location
    addMenuItem(list, Constants.commandFileLocation, 'File location...', Icons.folder_open_outlined);

    // Save CSV
    addMenuItem(list, Constants.commandFileSaveCsv, 'Save to CSV', Icons.save);

    // Save SQL
    addMenuItem(list, Constants.commandFileSaveSql, 'Save to SQL', Icons.save);

    // Close
    addMenuItem(list, Constants.commandFileClose, 'Close file', Icons.close);

    return myPopupMenuIconButton(
      icon: Icons.menu,
      tooltip: 'File menu',
      list: list,
      onSelected: (final int index) {
        switch (index) {
          case Constants.commandFileNew:
            widget.onFileNew();

          case Constants.commandFileOpen:
            widget.onFileOpen();

          case Constants.commandFileLocation:
            widget.onShowFileLocation();

          case Constants.commandAddTransactions:
            showImportTransactionsWizard(context);

          case Constants.commandFileSaveCsv:
            widget.onSaveCsv();

          case Constants.commandFileSaveSql:
            widget.onSaveSql();

          case Constants.commandFileClose:
            Settings().closeFile();

          default:
            debugPrint(' unhandled $index');
        }
      },
    );
  }

  void addMenuItem(final list, final int id, final String caption, final IconData iconData) {
    list.add(
      PopupMenuItem<int>(
        value: id,
        child: ThreePartLabel(
          icon: Icon(iconData),
          text1: caption,
          small: true,
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    final List<PopupMenuItem<int>> actionList = [];

    if (Settings().isSmallScreen) {
      actionList.add(
        PopupMenuItem<int>(
          value: Constants.commandIncludeClosedAccount,
          child: ThreePartLabel(
            text1: Settings().includeClosedAccounts ? 'Hide closed accounts' : 'Include closed account',
            icon: _buildButtonToggleViewClosedAccountsIcon(),
            small: true,
          ),
        ),
      );
    }

    final colorPallette = List<PopupMenuItem<int>>.generate(colorOptions.length, (final int index) {
      final bool isSelected = index == Settings().colorSelected;
      return PopupMenuItem<int>(
        value: index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? getColorTheme(context).secondaryContainer : null,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: ThreePartLabel(
            icon: Icon(index == Settings().colorSelected ? Icons.color_lens : Icons.color_lens_outlined,
                color: colorOptions[index]),
            text1: colorText[index],
            small: true,
          ),
        ),
      );
    });

    actionList.addAll(colorPallette);

    actionList.add(
      const PopupMenuItem<int>(
        value: Constants.commandIncludeClosedAccount,
        child: ThreePartLabel(
          text1: 'General...',
          icon: Icon(Icons.settings, color: Colors.grey),
          small: true,
        ),
      ),
    );

    actionList.add(
      PopupMenuItem<int>(
        value: Constants.commandIncludeRentals,
        child: ThreePartLabel(
          icon: Icon(
              !Settings().includeRentalManagement ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined,
              color: Colors.grey),
          text1: 'Rentals',
          small: true,
        ),
      ),
    );

    actionList.add(
      PopupMenuItem<int>(
        value: Constants.commandTextZoom,
        child: ZoomIncreaseDecrease(
          title: 'Zoom',
          onDecrease: () {
            Settings().fontScaleDecrease();
          },
          onIncrease: () {
            Settings().fontScaleIncrease();
          },
        ),
      ),
    );

    if (kDebugMode) {
      addColorPalette(actionList);
    }

    return myPopupMenuIconButton(
      icon: Icons.settings_outlined,
      tooltip: 'Settings',
      list: actionList,
      onSelected: (final int value) {
        onAppBarAction(value);
      },
    );
  }

  void addColorPalette(List<PopupMenuItem<int>> actionList) {
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

  void onAppBarAction(
    final int value,
  ) {
    switch (value) {
      case Constants.commandAddTransactions:
        showImportTransactionsFromTextInput(context);
      case Constants.commandSettings:
        showSettings(context);
      case Constants.commandIncludeClosedAccount:
        Settings().includeClosedAccounts = !Settings().includeClosedAccounts;
      case Constants.commandIncludeRentals:
        Settings().includeRentalManagement = !Settings().includeRentalManagement;
      default:
        Settings().colorSelected = value;
    }
    Settings().preferrenceSave();
  }
}
