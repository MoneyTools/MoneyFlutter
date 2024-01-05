import 'package:flutter/material.dart';
import 'package:money/widgets/widgets.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';

PreferredSizeWidget createAppBar(
  final Settings settings,
  final void Function() handleFileOpen,
  final void Function() handleFileClose,
  final void Function() handleImport,
  final void Function(Settings) onSettingsChanged,
) {
  return AppBar(
    title: widgetMainTitle(settings, handleFileOpen, handleFileClose),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.cloud_download),
        onPressed: () async {
          handleImport();
        },
        tooltip: 'Import',
      ),
      IconButton(
        icon: settings.useDarkMode ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
        onPressed: () {
          handleLightDarkModeChanged(settings, onSettingsChanged);
        },
        tooltip: 'Toggle brightness',
      ),
      PopupMenuButton<int>(
        icon: const Icon(Icons.more_vert),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (final BuildContext context) {
          final List<PopupMenuItem<int>> l = List<PopupMenuItem<int>>.generate(colorOptions.length, (final int index) {
            return PopupMenuItem<int>(
                value: index,
                child: renderIconAndText(
                    Icon(index == settings.colorSelected ? Icons.color_lens : Icons.color_lens_outlined,
                        color: colorOptions[index]),
                    colorText[index]));
          });
          l.add(
            PopupMenuItem<int>(
              value: Constants.commandIncludeClosedAccount,
              child: renderIconAndText(
                  Icon(
                      !settings.includeClosedAccounts
                          ? Icons.check_box_outline_blank_outlined
                          : Icons.check_box_outlined,
                      color: Colors.grey),
                  'Closed Accounts'),
            ),
          );
          l.add(
            PopupMenuItem<int>(
              value: Constants.commandIncludeRentals,
              child: renderIconAndText(
                  Icon(!settings.rentals ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined,
                      color: Colors.grey),
                  'Rentals'),
            ),
          );
          l.add(
            PopupMenuItem<int>(
              value: Constants.commandTextScaleIncrease,
              child: renderIconAndText(const Icon(Icons.text_increase, color: Colors.grey), 'Increase text size'),
            ),
          );
          l.add(
            PopupMenuItem<int>(
              value: Constants.commandTextScaleDecrease,
              child: renderIconAndText(const Icon(Icons.text_decrease, color: Colors.grey), 'Decrease text size'),
            ),
          );
          return l;
        },
        onSelected: (final int value) {
          onAppBarAction(settings, onSettingsChanged, value);
        },
      ),
    ],
  );
}

void onButtonImport(final Settings settings, final void Function(Settings) onSettingsChanged) {}

void handleLightDarkModeChanged(final Settings settings, final void Function(Settings) onSettingsChanged) {
  settings.useDarkMode = !settings.useDarkMode;
  settings.save();
  onSettingsChanged(settings);
}

void onAppBarAction(
  final Settings settings,
  final void Function(Settings) onSettingsChanged,
  final int value,
) {
  switch (value) {
    case Constants.commandIncludeClosedAccount:
      settings.includeClosedAccounts = !settings.includeClosedAccounts;
    case Constants.commandIncludeRentals:
      settings.rentals = !settings.rentals;
    case Constants.commandTextScaleIncrease:
      settings.textScale = settings.textScale * 1.10;
    case Constants.commandTextScaleDecrease:
      settings.textScale = settings.textScale * 0.9;
    default:
      settings.colorSelected = value;
  }
  settings.save();
  onSettingsChanged(settings);
}

Widget widgetMainTitle(
    final Settings settings, final void Function() handleFileOpen, final void Function() handleFileClose) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    const Text('MyMoney', textAlign: TextAlign.left),
    PopupMenuButton<int>(
      child: Text(getTitle(settings),
          textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
      itemBuilder: (final BuildContext context) {
        final List<PopupMenuItem<int>> list = <PopupMenuItem<int>>[];
        list.add(const PopupMenuItem<int>(value: 1, child: Text('Close')));
        list.add(const PopupMenuItem<int>(value: 2, child: Text('Open')));
        return list;
      },
      onSelected: (final int index) {
        if (index == 1) {
          handleFileClose();
        }
        if (index == 2) {
          handleFileOpen();
        }
      },
    ),
  ]);
}

String getTitle(final Settings settings) {
  if (settings.pathToDatabase == null) {
    return 'No file loaded';
  } else {
    return settings.pathToDatabase.toString();
  }
}
