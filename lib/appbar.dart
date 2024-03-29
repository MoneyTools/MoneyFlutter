import 'package:flutter/material.dart';
import 'package:money/app_caption.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/views/view_currencies.dart';
import 'package:money/views/view_pending_changes/bage_pending_changes.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/widgets/zoom.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function() onFileNew;
  final void Function() onFileOpen;
  final void Function() onFileClose;
  final void Function() onShowFileLocation;
  final void Function() onImport;
  final void Function() onSaveCsv;
  final void Function() onSaveSql;

  const MyAppBar({
    super.key,
    required this.onFileNew,
    required this.onFileOpen,
    required this.onFileClose,
    required this.onShowFileLocation,
    required this.onImport,
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
      title: widgetMainTitle(
        widget.onFileNew,
        widget.onFileOpen,
        widget.onFileClose,
        widget.onShowFileLocation,
        widget.onSaveCsv,
        widget.onSaveSql,
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.cloud_download),
          onPressed: () async {
            widget.onImport();
          },
          tooltip: 'Import',
        ),
        IconButton(
          icon: Settings().useDarkMode ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
          onPressed: () {
            Settings().useDarkMode = !Settings().useDarkMode;
            Settings().store();
          },
          tooltip: 'Toggle brightness',
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (final BuildContext context) {
            final List<PopupMenuItem<int>> actionList =
                List<PopupMenuItem<int>>.generate(colorOptions.length, (final int index) {
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
            actionList.add(
              const PopupMenuItem<int>(
                value: Constants.commandAddTransactions,
                child: ThreePartLabel(
                  text1: 'Add transactions',
                  icon: Icon(Icons.add_card, color: Colors.grey),
                  small: true,
                ),
              ),
            );
            actionList.add(
              const PopupMenuItem<int>(
                value: Constants.commandCurrencies,
                child: ThreePartLabel(
                  text1: 'Currencies',
                  icon: Icon(Icons.currency_exchange, color: Colors.grey),
                  small: true,
                ),
              ),
            );
            actionList.add(
              PopupMenuItem<int>(
                value: Constants.commandIncludeClosedAccount,
                child: ThreePartLabel(
                  icon: Icon(
                      !Settings().includeClosedAccounts
                          ? Icons.check_box_outline_blank_outlined
                          : Icons.check_box_outlined,
                      color: Colors.grey),
                  text1: 'Closed Accounts',
                  small: true,
                ),
              ),
            );
            actionList.add(
              PopupMenuItem<int>(
                value: Constants.commandIncludeRentals,
                child: ThreePartLabel(
                  icon: Icon(!Settings().rentals ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined,
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
            return actionList;
          },
          onSelected: (final int value) {
            onAppBarAction(value);
          },
        ),
      ],
    );
  }

  void onAppBarAction(
    final int value,
  ) {
    switch (value) {
      case Constants.commandAddTransactions:
        showImportTransactions(context);
      case Constants.commandCurrencies:
        showCurrencies(context);
      case Constants.commandIncludeClosedAccount:
        Settings().includeClosedAccounts = !Settings().includeClosedAccounts;
      case Constants.commandIncludeRentals:
        Settings().rentals = !Settings().rentals;
      default:
        Settings().colorSelected = value;
    }
    Settings().store();
  }

  Widget widgetMainTitle(
    final void Function() onFileNew,
    final void Function() onFileOpen,
    final void Function() onFileClose,
    final void Function() onShowFileLocation,
    final void Function() onSaveCsv,
    final void Function() onSaveSql,
  ) {
    return PopupMenuButton<int>(
      child: AppCaption(
        subCaption: Settings().fileManager.fullPathToLastOpenedFile,
      ),
      itemBuilder: (final BuildContext context) {
        final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
        // New
        list.add(
          const PopupMenuItem<int>(
            value: Constants.commandFileNew,
            child: Text('New'),
          ),
        );
        // Open
        list.add(
          const PopupMenuItem<int>(
            value: Constants.commandFileOpen,
            child: Text('Open'),
          ),
        );

        // File Location
        list.add(
          const PopupMenuItem<int>(
            value: Constants.commandFileLocation,
            child: Text('File location'),
          ),
        );

        // Save CSV
        list.add(PopupMenuItem<int>(
            value: Constants.commandFileSaveCsv,
            child: Row(
              children: [
                const Text('Save CSV'),
                const SizedBox(
                  width: 8,
                ),
                BadgePendingChanges(
                  itemsAdded: Settings().trackMutations.added,
                  itemsChanged: Settings().trackMutations.changed,
                  itemsDeleted: Settings().trackMutations.deleted,
                )
              ],
            )));

        // Save SQL
        list.add(PopupMenuItem<int>(
            value: Constants.commandFileSaveSql,
            child: Row(
              children: [
                const Text('Save SQL'),
                const SizedBox(
                  width: 8,
                ),
                BadgePendingChanges(
                  itemsAdded: Settings().trackMutations.added,
                  itemsChanged: Settings().trackMutations.changed,
                  itemsDeleted: Settings().trackMutations.deleted,
                )
              ],
            )));

        // Close
        list.add(
          const PopupMenuItem<int>(
            value: Constants.commandFileClose,
            child: Text('Close'),
          ),
        );
        return list;
      },
      onSelected: (final int index) {
        switch (index) {
          case Constants.commandFileNew:
            onFileNew();

          case Constants.commandFileOpen:
            onFileOpen();

          case Constants.commandFileLocation:
            onShowFileLocation();

          case Constants.commandFileSaveCsv:
            onSaveCsv();

          case Constants.commandFileSaveSql:
            onSaveSql();
          case Constants.commandFileClose:
            onFileClose();
          default:
            debugPrint(' unhandled $index');
        }
      },
    );
  }
}
