import 'package:flutter/material.dart';
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
      title: widgetMainTitle(widget.onFileOpen, widget.onFileClose, widget.onShowFileLocation),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            widget.onSave();
          },
          tooltip: 'Save',
        ),
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
    final void Function() handleFileOpen,
    final void Function() handleFileClose,
    final void Function() handleShowFileLocation,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      const Text('MyMoney', textAlign: TextAlign.left),
      PopupMenuButton<int>(
        child: Text(getTitle(),
            textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
        itemBuilder: (final BuildContext context) {
          final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
          list.add(const PopupMenuItem<int>(value: 1, child: Text('Close')));
          list.add(const PopupMenuItem<int>(value: 2, child: Text('Open')));
          list.add(const PopupMenuItem<int>(value: 3, child: Text('File location')));
          return list;
        },
        onSelected: (final int index) {
          if (index == 1) {
            handleFileClose();
          }
          if (index == 2) {
            handleFileOpen();
          }
          if (index == 3) {
            handleShowFileLocation();
          }
        },
      ),
    ]);
  }

  String getTitle() {
    if (Settings().pathToDatabase == null) {
      return 'No file loaded';
    } else {
      return Settings().pathToDatabase.toString();
    }
  }
}
