import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../helpers.dart';

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
  bool useAsIncome = true;

  Block(this.name, this.rect, this.color, this.textColor, this.useAsIncome) {
    //
  }

  static const minBlockHeight = 20.0;
  static const blockWidth = 50.0;
}

class SankeyBandPaint extends CustomPainter {
  final List<Block> blocksLeft;
  final Block blockOnRight;

  SankeyBandPaint(this.blocksLeft, this.blockOnRight) {
    //
  }

  @override
  bool shouldRepaint(SankeyBandPaint oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(SankeyBandPaint oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    renderSourcesToTargetAsPercentage(canvas, blocksLeft, blockOnRight);

    drawChanel(canvas, ChannelPoint(400.0, 100.0, 200.0), ChannelPoint(500, 50, 300));
  }
}

void renderSourcesToTargetAsPercentage(ui.Canvas canvas, List<Block> list, Block target) {
  var sumOfHeight = list.fold(0.0, (previousValue, element) => previousValue + element.rect.height);

  drawBoxAndTextFromTarget(canvas, target);

  var rollingVerticalPositionDrawnOnTheTarget = target.rect.top;

  for (var block in list) {
    drawBoxAndTextFromTarget(canvas, block);

    var ratioSourceBlockHeightToSumHeight = (block.rect.height / sumOfHeight);
    var targetSectionHeight = (target.rect.height * ratioSourceBlockHeightToSumHeight);

    var blockSideToStartFrom = target.rect.center.dx > block.rect.center.dx ? block.rect.right : block.rect.left;
    var targetSideToStartFrom = target.rect.center.dx > block.rect.center.dx ? target.rect.left : target.rect.right;

    drawChanel(
      canvas,
      ChannelPoint(blockSideToStartFrom, block.rect.top, block.rect.bottom),
      ChannelPoint(targetSideToStartFrom, rollingVerticalPositionDrawnOnTheTarget, rollingVerticalPositionDrawnOnTheTarget + targetSectionHeight),
    );

    rollingVerticalPositionDrawnOnTheTarget += targetSectionHeight;
  }
}

double getHeightNeededToRender(list, useAsIncome) {
  var ratioPriceToHeight = useAsIncome ? getHeightRationIncome(list) : getHeightRatioExpense(list);

  var verticalPosition = 0.0;
  var gap = 20.0;

  for (var element in list) {
    double height = element.value.abs() * ratioPriceToHeight;
    verticalPosition += height + gap;
  }

  // how much vertical space was needed to render this
  return verticalPosition;
}

double getRatioFromMaxValue(list, useAsIncome) {
  if (useAsIncome) {
    return getHeightRationIncome(list);
  }

  return getHeightRatioExpense(list);
}

double getHeightRationIncome(list) {
  var largest = double.minPositive;
  var smallest = double.maxFinite;

  for (var element in list) {
    largest = max(largest, element.value);
    smallest = min(smallest, element.value);
  }

  const double heightOfSmallest = 100.0;
  double ratioPriceToHeight = heightOfSmallest / largest;
  return ratioPriceToHeight;
}

double getHeightRatioExpense(list) {
  var largest = double.maxFinite;
  var smallest = double.minPositive;

  for (var element in list) {
    largest = min(largest, element.value);
    smallest = max(smallest, element.value);
  }

  const double heightOfSmallest = 100.0;
  double ratioPriceToHeight = (heightOfSmallest / largest).abs();
  return ratioPriceToHeight;
}

void drawBoxAndTextFromTarget(canvas, Block target) {
  canvas.drawRect(target.rect, Paint()..color = target.color.withOpacity(0.5));
  drawText(canvas, target.name, target.rect.left + 4, target.rect.top + 2, color: target.textColor);
}

void drawText(Canvas context, String name, double x, double y, {Color color = Colors.black, double fontSize = 12.0, double angleRotationInRadians = 0.0}) {
  context.save();
  context.translate(x, y);
  context.rotate(angleRotationInRadians);
  TextSpan span = TextSpan(
      style: TextStyle(
        color: invertColor(color),
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
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

void drawChanel(canvas, ChannelPoint a, ChannelPoint b) {
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
  paint.color = const Color(0x4556687A);
  canvas.drawPath(path, paint);

  Paint paintStroke = Paint();
  paintStroke.style = PaintingStyle.stroke;
  paintStroke.strokeWidth = 0.5;
  paintStroke.color = Colors.black.withOpacity(0.3);
  canvas.drawPath(path, paintStroke);
}
