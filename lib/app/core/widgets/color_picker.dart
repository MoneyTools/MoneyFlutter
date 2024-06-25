import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  final Color color;
  final Function(Color) onColorChanged;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  /// From 0 to 360
  late double hue;

  /// From 0.0% to 1.0% 0%=Black 100%=White
  late double brightness;

  @override
  void initState() {
    super.initState();
    fromInputColorToHueAndBrightness();
  }

  @override
  void didUpdateWidget(covariant ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    fromInputColorToHueAndBrightness();
  }

  void fromInputColorToHueAndBrightness() {
    final bothValues = getHueAndBrightnessFromColor(widget.color);
    hue = bothValues.first;
    brightness = bothValues.second;
  }

  @override
  Widget build(BuildContext context) {
    const maxHue = 359.7;

    if (hue > maxHue) {
      hue = maxHue;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: getColorTheme(context).onSurface.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7), // Same radius as container
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
              child: CustomPaint(
                painter: HueGradientPainter(),
                child: Slider(
                  value: hue,
                  min: 0,
                  max: maxHue,
                  divisions: 360 * 2,
                  label: hue.floor().toString(),
                  onChanged: (double value) {
                    setState(() {
                      hue = value;
                      if (brightness == 0 || brightness == 1) {
                        brightness = 0.5;
                      }
                      widget.onColorChanged(hsvToColor(hue, brightness));
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 30,
              child: CustomPaint(
                painter: BrightnessGradientPainter(hue: hue),
                child: Slider(
                  value: brightness,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  label: (brightness * 100).round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      brightness = value;
                      widget.onColorChanged(hsvToColor(hue, brightness));
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HueGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const List<Color> colors = [
      Color.fromRGBO(255, 0, 0, 1), // 1 Red
      Color.fromRGBO(255, 255, 0, 1), // 2 Yellow
      Color.fromRGBO(0, 255, 0, 1), // 3 Green

      Color.fromRGBO(0, 255, 255, 1), // 4 Cyan

      Color.fromRGBO(0, 0, 255, 1), // 5 Blue
      Color.fromRGBO(255, 0, 255, 1), // 6 Purple
      Color.fromRGBO(255, 0, 0, 1), // 7 Red
    ];

    Gradient gradient = LinearGradient(
      colors: colors,
      stops: calculateSpread(0, 1, colors.length),
    );

    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BrightnessGradientPainter extends CustomPainter {

  BrightnessGradientPainter({required this.hue});
  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Gradient gradient = LinearGradient(
      colors: [
        HSLColor.fromAHSL(1.0, hue, 1.0, 0.0).toColor(), // Black
        HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor(), // Middle lightness
        HSLColor.fromAHSL(1.0, hue, 1.0, 1.0).toColor(), // White
      ],
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // We want to repaint when the hue changes
  }
}
