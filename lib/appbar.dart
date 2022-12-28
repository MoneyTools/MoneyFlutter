import 'package:flutter/material.dart';
import 'package:money/widgets/widgets.dart';
import 'models/constants.dart';

PreferredSizeWidget createAppBar(settings, handleFileOpen, handleFileClose, onSettingsChanged) {
  return AppBar(
    title: widgetMainTitle(settings, handleFileOpen, handleFileClose),
    actions: [
      IconButton(
        icon: settings.useDarkMode ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
        onPressed: () {
          handleLightDarkModeChanged(settings, onSettingsChanged);
        },
        tooltip: "Toggle brightness",
      ),
      PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (context) {
          var l = List.generate(colorOptions.length, (index) {
            return PopupMenuItem(value: index, child: renderIconAndText(Icon(index == settings.colorSelected ? Icons.color_lens : Icons.color_lens_outlined, color: colorOptions[index]), colorText[index]));
          });
          l.add(
            PopupMenuItem(
              value: 1002,
              child: renderIconAndText(Icon(settings.materialVersion == 3 ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Material V2"),
            ),
          );
          l.add(
            PopupMenuItem(
              value: 1003,
              child: renderIconAndText(Icon(settings.materialVersion != 3 ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Material V3"),
            ),
          );
          l.add(
            PopupMenuItem(
              value: 2000,
              child: renderIconAndText(Icon(!settings.rentals ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Rentals"),
            ),
          );
          return l;
        },
        onSelected: (value) {
          handleColorSelect(settings, onSettingsChanged, value);
        },
      ),
    ],
  );
}

void handleLightDarkModeChanged(settings, onSettingsChanged) {
  settings.useDarkMode = !settings.useDarkMode;
  settings.save();
  onSettingsChanged(settings);
}

void handleColorSelect(settings, onSettingsChanged, int value) {
  if (value == 1002) {
    settings.materialVersion = 2;
  } else if (value == 1003) {
    settings.materialVersion = 3;
  } else if (value == 2000) {
    settings.rentals = !settings.rentals;
  } else {
    settings.colorSelected = value;
  }
  settings.save();
  onSettingsChanged(settings);
}

widgetMainTitle(settings, handleFileOpen, handleFileClose) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text("MyMoney", textAlign: TextAlign.left),
    PopupMenuButton(
      child: Text(getTitle(settings), textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
      itemBuilder: (context) {
        List<PopupMenuItem> list = [];
        list.add(const PopupMenuItem(value: 1, child: Text('Close')));
        list.add(const PopupMenuItem(value: 2, child: Text('Open')));
        return list;
      },
      onSelected: (index) {
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

String getTitle(settings) {
  if (settings.pathToDatabase == null) {
    return "No file loaded";
  } else {
    return settings.pathToDatabase.toString();
  }
}
