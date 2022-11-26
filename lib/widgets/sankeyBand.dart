import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Block {
  String name = "";
  Rect rect = const Rect.fromLTWH(0, 0, 10, 20);
  Color color;
  bool useAsIncome = true;

  Block(this.name, this.rect, this.color, this.useAsIncome) {
    //
  }

  static const minBlockHeight = 30.0;
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
  }
}

void renderSourcesToTargetAsPercentage(ui.Canvas canvas, list, target) {
  var sumOfHeight = list.fold(0.0, (previousValue, element) => previousValue + element.rect.height);

  drawBoxAndTextFromTarget(canvas, target);

  var heightOfTarget = target.rect.height;
  var rollingVerticalPositionDrawnOnTheTarget = 0.0;

  print("Right $heightOfTarget");

  for (var block in list) {
    drawBoxAndTextFromTarget(canvas, block);
    var ratioSourceBlockHeightToSumHeight = (block.rect.height / sumOfHeight);
    drawPathFromBlockToBlockSlot(canvas, block, target, rollingVerticalPositionDrawnOnTheTarget, ratioSourceBlockHeightToSumHeight);
    rollingVerticalPositionDrawnOnTheTarget += ratioSourceBlockHeightToSumHeight;
  }
}

double getHeightNeededToRender(list, useAsIncome) {
  var ratioPriceToHeight = useAsIncome ? getHeightRationIncome(list) : getHeightRatioExpense(list);

  var verticalPosition = 0.0;
  var gap = 10.0;

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

ui.Path drawPath(ui.Canvas canvas, ui.Offset topLeft, ui.Offset topRight, ui.Offset bottomLeft, ui.Offset bottomRight, color) {
  // Move Top Left
  var size = Size((topRight.dx - topLeft.dx).abs(), 100.0);
  var halfWidth = size.width / 2;

  Path path = Path();

  path.moveTo(topLeft.dx, topLeft.dy);
  path.cubicTo(
    /*P1*/
    topLeft.dx + halfWidth,
    topLeft.dy,
    /*P2*/
    topRight.dx - halfWidth,
    topRight.dy,
    /*P3*/
    topRight.dx,
    topRight.dy,
  );

  path.lineTo(bottomRight.dx, bottomRight.dy);

  path.cubicTo(
    /*P1*/
    bottomRight.dx - halfWidth,
    bottomRight.dy,
    /*P2*/
    bottomLeft.dx + halfWidth,
    bottomLeft.dy,
    /*P3*/
    bottomLeft.dx,
    bottomLeft.dy,
  );

  path.close();

  Paint paint = Paint();
  paint.color = color;
  canvas.drawPath(path, paint);

  Paint paintStroke = Paint();
  paintStroke.style = PaintingStyle.stroke;
  paintStroke.strokeWidth = 0.5;
  paintStroke.color = Colors.black.withOpacity(0.2);
  canvas.drawPath(path, paintStroke);

  return path;
}

ui.Path drawPathFromTarget(ui.Canvas canvas, Block source, Block target) {
  var offsetTopLeft = ui.Offset(source.rect.right, source.rect.top);
  var offsetTopRight = ui.Offset(target.rect.left, target.rect.top);
  var offsetBottomLeft = ui.Offset(source.rect.right, source.rect.bottom);
  var offsetBottomRight = ui.Offset(target.rect.left, target.rect.bottom);

  return drawPath(canvas, offsetTopLeft, offsetTopRight, offsetBottomLeft, offsetBottomRight, const Color(0x4556687A));
}

ui.Path drawPathFromBlockToBlockSlot(ui.Canvas canvas, Block source, Block target, double targetStartPercentage, double heightPercentage) {
  print("${source.name} targetH:${target.rect.height} vS:$targetStartPercentage vH:$heightPercentage");
  var offsetTopLeft = ui.Offset(source.rect.right, source.rect.top);
  var offsetBottomLeft = ui.Offset(source.rect.right, source.rect.bottom);

  var targetTop = target.rect.top + (target.rect.height * targetStartPercentage);
  var offsetTopRight = ui.Offset(target.rect.left, targetTop);
  var targetSectionHeight = target.rect.height * heightPercentage;
  var offsetBottomRight = ui.Offset(target.rect.left, targetTop + targetSectionHeight);

  return drawPath(canvas, offsetTopLeft, offsetTopRight, offsetBottomLeft, offsetBottomRight, const Color(0x4556687A));
}

void drawBoxAndText(canvas, x, y, w, h, text, Color color) {
  canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
  drawText(canvas, text, x, y + (h / 2), color: Colors.white);
}

void drawBoxAndTextFromTarget(canvas, Block target) {
  canvas.drawRect(target.rect, Paint()..color = target.color);
  drawText(canvas, target.name, target.rect.left, target.rect.top, color: Colors.white);
}

void drawText(Canvas context, String name, double x, double y, {Color color = Colors.black, double fontSize = 10.0, double angleRotationInRadians = 0.0}) {
  context.save();
  context.translate(x, y);
  context.rotate(angleRotationInRadians);
  TextSpan span = TextSpan(style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'Roboto'), text: name);
  TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr);
  tp.layout();
  tp.paint(context, const Offset(0.0, 0.0));
  context.restore();
}
