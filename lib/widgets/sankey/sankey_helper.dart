import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:money/models/constants.dart';

class SanKeyEntry {
  String name = '';
  double value = 0.00;
}

class ChannelPoint {
  double x = 0.0;
  double top = 0.0;
  double bottom = 0 / 0;

  ChannelPoint(this.x, this.top, this.bottom) {
    //
  }
}

class Block {
  String name = '';
  Rect rect = const Rect.fromLTWH(0, 0, 10, 20);
  Color color;
  Color textColor = Colors.black;
  TextAlign alignHorizontal = TextAlign.start;
  TextAlign alignVertical = TextAlign.start;

  /// Constructor
  Block(this.name, this.rect, this.color, this.textColor, this.alignHorizontal, this.alignVertical);

  static const double minBlockHeight = 20.0;
  static const double blockWidth = 50.0;

  void draw(final Canvas canvas) {
    if (!rect.hasNaN) {
      // Rectangle
      final ui.Paint paint = Paint();
      paint.color = color;
      paint.style = PaintingStyle.fill;
      canvas.drawRect(rect, paint);

      // Title
      drawTextInRect(canvas, name, rect, color: textColor, textAlign: alignHorizontal);
    }
  }
}

void renderSourcesToTargetAsPercentage(final ui.Canvas canvas, final List<Block> list, final Block target) {
  final double sumOfHeight = sumHeight(list);

  double rollingVerticalPositionDrawnOnTheTarget = target.rect.top;

  for (Block block in list) {
    final double ratioSourceBlockHeightToSumHeight = (block.rect.height / sumOfHeight);
    final double targetSectionHeight = (target.rect.height * ratioSourceBlockHeightToSumHeight);

    final double blockSideToStartFrom =
        target.rect.center.dx > block.rect.center.dx ? block.rect.right - 1 : block.rect.left + 1;
    final double targetSideToStartFrom =
        target.rect.center.dx > block.rect.center.dx ? target.rect.left + 1 : target.rect.right - 1;

    drawChanel(
      canvas: canvas,
      start: ChannelPoint(blockSideToStartFrom, block.rect.top, block.rect.bottom),
      end: ChannelPoint(targetSideToStartFrom, rollingVerticalPositionDrawnOnTheTarget,
          rollingVerticalPositionDrawnOnTheTarget + targetSectionHeight),
      color: block.color,
    );

    rollingVerticalPositionDrawnOnTheTarget += targetSectionHeight;
    block.draw(canvas);
  }
}

double getHeightNeededToRender(final List<SanKeyEntry> list) {
  final double sum = sumValue(list);

  double verticalPosition = 0.0;

  for (SanKeyEntry element in list) {
    final double height = (element.value.abs() / sum.abs()) * Constants.targetHeight;
    verticalPosition += height;
    verticalPosition += Constants.gapBetweenChannels;
  }

  // how much vertical space was needed to render this
  return verticalPosition;
}

void drawText(
  final Canvas context,
  final String name,
  final double x,
  final double y, {
  final Color color = Colors.black,
  final double fontSize = 12.0,
  final double angleRotationInRadians = 0.0,
}) {
  context.save();
  context.translate(x, y);
  context.rotate(angleRotationInRadians);
  final TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        // shadows: [
        //   Shadow(
        //     color: color,
        //     offset: const Offset(0, 0),
        //     blurRadius: 2,
        //   ),
        // ],
      ),
      text: name);
  final TextPainter tp = TextPainter(text: span, textDirection: ui.TextDirection.ltr);

  tp.layout();

  tp.paint(context, const Offset(0.0, 0.0));

  context.restore();
}

void drawTextInRect(
  final Canvas context,
  final String name,
  final Rect rect, {
  final TextAlign textAlign = TextAlign.left,
  final Color color = Colors.black,
  final double fontSize = 12.0,
  final double angleRotationInRadians = 0.0,
}) {
  context.save();
  context.translate(rect.left, rect.top);
  context.rotate(angleRotationInRadians);
  final TextSpan span = TextSpan(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
      text: name);

  final TextPainter textPainter = TextPainter(text: span, textAlign: textAlign, textDirection: ui.TextDirection.ltr);

  textPainter.layout();

  textPainter.paint(
    context,
    Offset(
      // Do calculations here:
      (rect.width - textPainter.width) * 0.5,
      (rect.height - textPainter.height) * 0.5,
    ),
  );
  context.restore();
}

void drawChanel({
  required final ui.Canvas canvas,
  required final ChannelPoint start,
  required final ChannelPoint end,
  final Color color = const Color(0xFF56687A),
}) {
  // We render left to right, so lets see what channel goes on the left and the one that goes on the right
  final ChannelPoint channelPointLeft = (start.x < end.x) ? start : end;
  final ChannelPoint channelPointEnd = (start.x < end.x) ? end : start;

  final ui.Size size = Size((channelPointEnd.x - channelPointLeft.x).abs(), 100.0);
  final double halfWidth = size.width / 2;

  final ui.Path path = Path();

  // Start from the Left-Top
  path.moveTo(channelPointLeft.x, channelPointLeft.top);
  path.cubicTo(
    /*P1*/
    channelPointLeft.x + halfWidth,
    channelPointLeft.top,
    /*P2*/
    channelPointEnd.x - halfWidth,
    channelPointEnd.top,
    /*P3*/
    channelPointEnd.x,
    channelPointEnd.top,
  );

  path.lineTo(channelPointEnd.x, channelPointEnd.bottom);

  path.cubicTo(
    /*P1*/
    channelPointEnd.x - halfWidth,
    channelPointEnd.bottom,
    /*P2*/
    channelPointLeft.x + halfWidth,
    channelPointLeft.bottom,
    /*P3*/
    channelPointLeft.x,
    channelPointLeft.bottom,
  );

  // Close at the Left-Bottom
  path.close();

  final ui.Paint paint = Paint();
  paint.color = color;
  paint.style = PaintingStyle.fill;
  canvas.drawPath(path, paint);

  // OUTLINE
  // final ui.Paint paintStroke = Paint();
  // paintStroke.style = PaintingStyle.stroke;
  // paintStroke.strokeWidth = 0;
  // paintStroke.color = color;
  // canvas.drawPath(path, paintStroke);
}

double sumHeight(final List<Block> list) {
  final double sumOfHeight =
      list.fold(0.0, (final double previousValue, final Block element) => previousValue + element.rect.height);
  return sumOfHeight;
}

double sumValue(final List<SanKeyEntry> list) {
  final double sumOfHeight =
      list.fold(0.0, (final double previousValue, final SanKeyEntry element) => previousValue + element.value);
  return sumOfHeight;
}
