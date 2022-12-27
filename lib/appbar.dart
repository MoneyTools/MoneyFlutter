import 'package:flutter/material.dart';
import 'package:money/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/constants.dart';




PreferredSizeWidget createAppBar(settings, handleFileOpen, onSettingsChanged ) {
  return AppBar(
    title: widgetMainTitle(settings),
    actions: [
      IconButton(
        icon: const Icon(Icons.file_open),
        onPressed: handleFileOpen,
        tooltip: "Open mmdb file",
      ),
      IconButton(
        icon: settings.isDarkMode() ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
        onPressed: (){handleBrightnessChange(settings,onSettingsChanged);},
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
              child: renderIconAndText(Icon(settings.themeData.useMaterial3 ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Material V2"),
            ),
          );
          l.add(
            PopupMenuItem(
              value: 1003,
              child: renderIconAndText(Icon(!settings.themeData.useMaterial3 ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Material V3"),
            ),
          );
          return l;
        },
        onSelected: (value){handleColorSelect(settings,onSettingsChanged,value);},
      ),
    ],
  );
}

void handleBrightnessChange(settings, onSettingsChanged) {
  SharedPreferences.getInstance().then((preferences) {
      var useDarkMode = !settings.isDarkMode();
      preferences.setBool(prefDarkMode, useDarkMode);
      onSettingsChanged(settings);
  });
}

void handleColorSelect(settings,onSettingsChanged, int value) {
  if (value == 1002) {
    handleMaterialVersionChange(settings, false);
    onSettingsChanged(settings);
    return;
  }
  if (value == 1003) {
    handleMaterialVersionChange(settings, true);
    onSettingsChanged(settings);
    return;
  }

  SharedPreferences.getInstance().then((preferences) {
      preferences.setInt(prefColor, value);
      settings.colorSelected = value;
      onSettingsChanged(settings);
  });
}

void handleMaterialVersionChange(settings, useVersion3) {
  SharedPreferences.getInstance().then((preferences) {
      var version = settings.themeData.useMaterial3 ? 2 : 3;
      preferences.setInt(prefMaterialVersion, version);
    });
}


widgetMainTitle(settings) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text("MyMoney", textAlign: TextAlign.left),
    Text(getTitle(settings), textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
  ]);
}


String getTitle(settings) {
  if (settings.pathToDatabase == null) {
    return "No file loaded";
  } else {
    return settings.pathToDatabase.toString();
  }
}
