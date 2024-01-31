import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/views/view_currencies.dart';
import 'package:money/widgets/three_part_label.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';
import 'package:money/widgets/zoom.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function() onFileOpen;
  final void Function() onFileClose;
  final void Function() onShowFileLocation;
  final void Function() onImport;
  final void Function() onSave;

  const MyAppBar({
    super.key,
    required this.onFileOpen,
    required this.onFileClose,
    required this.onShowFileLocation,
    required this.onImport,
    required this.onSave,
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
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      title: widgetMainTitle(
        widget.onFileOpen,
        widget.onFileClose,
        widget.onShowFileLocation,
        widget.onSave,
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
            Settings().save();
            Settings().fireOnChanged();
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
                    color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
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
      case Constants.commandCurrencies:
        showCurrencies(context);
      case Constants.commandIncludeClosedAccount:
        Settings().includeClosedAccounts = !Settings().includeClosedAccounts;
      case Constants.commandIncludeRentals:
        Settings().rentals = !Settings().rentals;
      default:
        Settings().colorSelected = value;
    }
    Settings().save();
    Settings().fireOnChanged();
  }

  Widget widgetMainTitle(
    final void Function() onFileOpen,
    final void Function() onFileClose,
    final void Function() onShowFileLocation,
    final void Function() onSave,
  ) {
    return PopupMenuButton<int>(
      child: buildPopupHeader(),
      itemBuilder: (final BuildContext context) {
        final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
        // Open
        list.add(
          const PopupMenuItem<int>(
            value: 2,
            child: Text('Open'),
          ),
        );

        // File Location
        list.add(
          const PopupMenuItem<int>(
            value: 3,
            child: Text('File location'),
          ),
        );

        // Save
        list.add(
          PopupMenuItem<int>(
            value: 4,
            child: Badge.count(
              isLabelVisible: Settings().numberOfChanges > 0,
              count: Settings().numberOfChanges,
              alignment: Alignment.centerRight,
              offset: const Offset(20, 0),
              child: const Text('Save'),
            ),
          ),
        );

        // Close
        list.add(
          const PopupMenuItem<int>(
            value: 1,
            child: Text('Close'),
          ),
        );
        return list;
      },
      onSelected: (final int index) {
        if (index == 1) {
          onFileClose();
        }
        if (index == 2) {
          onFileOpen();
        }
        if (index == 3) {
          onShowFileLocation();
        }
        if (index == 4) {
          onSave();
        }
      },
    );
  }

  Widget buildPopupHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Badge.count(
          isLabelVisible: Settings().numberOfChanges > 0,
          count: Settings().numberOfChanges,
          offset: const Offset(16, 0),
          child: const Text('MyMoney', textAlign: TextAlign.left),
        ),
        Text(getTitle(),
            textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  String getTitle() {
    return Data().fullPathToDataSource ?? 'No file loaded';
  }
}
