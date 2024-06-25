import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/controller/theme_controler.dart';

/// ( - )  100% ( + )
class ZoomIncreaseDecrease extends StatefulWidget {
  final String title;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const ZoomIncreaseDecrease({
    super.key,
    required this.title,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  State<ZoomIncreaseDecrease> createState() => _ZoomIncreaseDecreaseState();
}

class _ZoomIncreaseDecreaseState extends State<ZoomIncreaseDecrease> {
  String zoomValueAsText = '';
  PreferenceController preferenceController = Get.find();
  @override
  void initState() {
    super.initState();
    updateZoomTextFromValue();
  }

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(widget.title),
        IconButton(
          tooltip: 'Cmd/Ctrl -',
          icon: const Icon(Icons.text_decrease),
          onPressed: () {
            setState(() {
              widget.onDecrease();
              updateZoomTextFromValue();
            });
          },
        ),
        Tooltip(
          message: "Cmd/Ctrl 0",
          child: TextButton(
              onPressed: () {
                setState(() {
                  ThemeController.to.setFontScaleTo(1.0);
                  updateZoomTextFromValue();
                });
              },
              child: Text(zoomValueAsText)),
        ),
        IconButton(
          tooltip: 'Cmd/Ctrl +',
          icon: const Icon(Icons.text_increase),
          onPressed: () {
            setState(() {
              widget.onIncrease();
              updateZoomTextFromValue();
            });
          },
        ),
      ],
    );
  }

  void updateZoomTextFromValue() {
    zoomValueAsText = '${(preferenceController.textScale * 100).toInt()}%';
  }
}
