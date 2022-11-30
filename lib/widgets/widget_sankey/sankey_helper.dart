import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../helpers.dart';

class SanKeyEntry {
  String name = "";
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
  String name = "";
  Rect rect = const Rect.fromLTWH(0, 0, 10, 20);
  Color color;
  Color textColor = Colors.black;

  Block(this.name, this.rect, this.color, this.textColor) {
    //
  }

  static const minBlockHeight = 20.0;
  static const blockWidth = 50.0;
}

void renderSourcesToTargetAsPercentage(ui.Canvas canvas, List<Block> list, Block target) {
  var sumOfHeight = sumHeight(list);

  var rollingVerticalPositionDrawnOnTheTarget = target.rect.top;

  for (var block in list) {
    var ratioSourceBlockHeightToSumHeight = (block.rect.height / sumOfHeight);
    var targetSectionHeight = (target.rect.height * ratioSourceBlockHeightToSumHeight);

    var blockSideToStartFrom = target.rect.center.dx > block.rect.center.dx ? block.rect.right : block.rect.left;
    var targetSideToStartFrom = target.rect.center.dx > block.rect.center.dx ? target.rect.left : target.rect.right;

    drawChanel(canvas, ChannelPoint(blockSideToStartFrom, block.rect.top, block.rect.bottom),
        ChannelPoint(targetSideToStartFrom, rollingVerticalPositionDrawnOnTheTarget, rollingVerticalPositionDrawnOnTheTarget + targetSectionHeight),
        color: block.color);

    rollingVerticalPositionDrawnOnTheTarget += targetSectionHeight;
    drawBoxAndTextFromTarget(canvas, block);
  }
}

double getHeightNeededToRender(List<SanKeyEntry> list) {
  var sum = sumValue(list);

  var verticalPosition = 0.0;

  for (var element in list) {
    double height = (element.value.abs() / sum.abs()) * Constants.targetHeight;
    verticalPosition += height;
    verticalPosition += Constants.gapBetweenChannels;
  }

  // how much vertical space was needed to render this
  return verticalPosition;
}

// ignore: unused-code
List<num> getMinMaxValues(list) {
  if (list.isEmpty) {
    return [0, 0];
  }
  if (list.length == 1) {
    return [list[0], list[0]];
  }

  double valueMin = 0;
  double valueMax = 0;
  if (list[0] < list[1]) {
    valueMin = list[0];
    valueMax = list[1];
  } else {
    valueMin = list[1];
    valueMax = list[0];

    for (var value in list) {
      valueMin = min(valueMin, value);
      valueMax = max(valueMax, value);
    }
  }
  return [valueMin, valueMax];
}

void drawBoxAndTextFromTarget(canvas, Block block) {
  var paint = Paint();
  paint.color = block.color.withOpacity(0.5);
  canvas.drawRect(block.rect, paint);
  drawText(canvas, block.name, block.rect.left + 4, block.rect.top + 2, color: block.textColor);
}

void drawText(Canvas context, String name, double x, double y, {Color color = Colors.black, double fontSize = 12.0, double angleRotationInRadians = 0.0}) {
  context.save();
  context.translate(x, y);
  context.rotate(angleRotationInRadians);
  TextSpan span = TextSpan(
      style: TextStyle(
        color: invertColor(color),
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
  TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: ui.TextDirection.ltr);
  tp.layout();
  tp.paint(context, const Offset(0.0, 0.0));

  context.restore();
}

void drawChanel(canvas, ChannelPoint a, ChannelPoint b, {Color color = const Color(0xFF56687A)}) {
  // We render left to right, so lets see what channel goes on the left and the one that goes on the right
  ChannelPoint channelPointLeft = (a.x < b.x) ? a : b;
  ChannelPoint channelPointEnd = (a.x < b.x) ? b : a;

  var size = Size((channelPointEnd.x - channelPointLeft.x).abs(), 100.0);
  var halfWidth = size.width / 2;

  Path path = Path();

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

  Paint paint = Paint();
  paint.color = color.withOpacity(0.4);
  canvas.drawPath(path, paint);

  Paint paintStroke = Paint();
  paintStroke.style = PaintingStyle.stroke;
  paintStroke.strokeWidth = 0.5;
  paintStroke.color = Colors.black.withOpacity(0.3);
  canvas.drawPath(path, paintStroke);
}

sumHeight(List<Block> list) {
  var sumOfHeight = list.fold(0.0, (previousValue, element) => previousValue + element.rect.height);
  return sumOfHeight;
}

sumValue(List<SanKeyEntry> list) {
  var sumOfHeight = list.fold(0.0, (previousValue, element) => previousValue + element.value);
  return sumOfHeight;
}
