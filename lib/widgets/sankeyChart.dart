import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../helpers.dart';

class SanKeyEntry {
  String name = "";
  double value = 0.00;
}

class Block {
  String name = "";
  Rect rect;
  Color color;
  bool useAsIncome = true;

  Block(this.name, this.rect, this.color, this.useAsIncome) {
    //
  }

  static const minBlockHeight = 30.0;
}

class SankyPaint extends CustomPainter {
  List<SanKeyEntry> listOfIncomes;
  List<SanKeyEntry> listOfExpenses;
  double padding;

  SankyPaint(this.listOfIncomes, this.listOfExpenses, this.padding) {
    //
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double targetWidth = 100.0;
    var targetLeft = size.width - targetWidth - padding;
    var targetHeight = 200.0;
    var horizontalCenter = size.width / 2;

    var verticalStackOfTargets = 0.0;

    var totalIncome = listOfIncomes.fold(0.00, (sum, item) => sum + item.value);
    var totalExpense = listOfExpenses.fold(0.00, (sum, item) => sum + item.value.abs());

    var ratioIncomeToExpense = (targetHeight) / (totalIncome + totalExpense);

    var lastHeight = ratioIncomeToExpense * totalIncome;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetIncome = Block("Incomes\n${getCurrencyText(totalIncome)}", ui.Rect.fromLTWH(horizontalCenter, verticalStackOfTargets, targetWidth, lastHeight), const Color(0xff387000), true);

    verticalStackOfTargets += padding + lastHeight;
    lastHeight = ratioIncomeToExpense * totalExpense;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetExpense = Block("Expenses\n${getCurrencyText(totalExpense)}", ui.Rect.fromLTWH(horizontalCenter, verticalStackOfTargets, targetWidth, lastHeight), const Color(0xff8c0e00), false);

    var stackVerticalPosition = 0.0;
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfIncomes, true, padding, stackVerticalPosition, targetIncome, const Color(0xaa2f6001));
    stackVerticalPosition += padding * 5;
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfExpenses, false, padding, stackVerticalPosition, targetExpense, const Color(0x9b730000));

    var netAmount = totalIncome - totalExpense;
    lastHeight = ratioIncomeToExpense * netAmount;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetNet = Block("Net\n${getCurrencyText(netAmount)}", ui.Rect.fromLTWH(targetLeft, 0, targetWidth, lastHeight), const Color(0xff0061ad), false);
    drawBoxAndTextFromTarget(canvas, targetNet);

    drawPathFromTarget(canvas, targetIncome, targetNet);
    drawPathFromTarget(canvas, targetExpense, targetNet);
  }

  double renderSourcesToTarget(ui.Canvas canvas, list, useAsIncome, double left, double top, Block target, Color color) {
    double ratioPriceToHeight = getRatioFromMaxValue(list, useAsIncome);

    drawBoxAndTextFromTarget(canvas, target);

    var verticalPosition = 0.0;
    var sourceWidth = 200.0;

    for (var element in list) {
      double height = max(10, element.value.abs() * ratioPriceToHeight);
      double boxTop = top + verticalPosition;
      Rect rect = Rect.fromLTWH(left, boxTop, sourceWidth, height);
      Block source = Block(element.name + ": " + getCurrencyText(element.value), rect, color, useAsIncome);
      drawBoxAndTextFromTarget(canvas, source);
      drawPathFromTarget(canvas, source, target);

      verticalPosition += height + padding;
    }

    // how much vertical space was needed to render this
    return verticalPosition;
  }

  ui.Path drawPath(ui.Canvas canvas, ui.Offset topLeft, ui.Offset topRight, ui.Offset bottomLeft, ui.Offset bottomRight, color, useCurve) {
    Path downwardPath = Path();

    // Move Top Left
    downwardPath.moveTo(topLeft.dx, topLeft.dy);

    // Draw Line to top Right
    if (useCurve) {
      var topWidth = topRight.dx - topLeft.dx;
      downwardPath.quadraticBezierTo(
        topRight.dx + 10,
        topRight.dy + 10,
        topRight.dx,
        topRight.dy,
      );
    } else {
      downwardPath.lineTo(topRight.dx, topRight.dy);
    }

    // Draw vertical line Top to bottom on to Right Side
    downwardPath.lineTo(bottomRight.dx, bottomRight.dy);

    // Draw a line back left to right at the bottom
    if (useCurve) {
      var bottomWidth = bottomRight.dx - bottomLeft.dx;
      var bottomHeight = bottomRight.dy - bottomLeft.dy;
      downwardPath.quadraticBezierTo(
        bottomLeft.dx - 10,
        bottomLeft.dy - 10,
        bottomLeft.dx,
        bottomLeft.dy,
      );
    } else {
      downwardPath.lineTo(bottomLeft.dx, bottomLeft.dy);
    }

    Paint paint = Paint();
    paint.color = color;
    canvas.drawPath(downwardPath, paint);

    return downwardPath;
  }

  ui.Path drawPathFromTarget(ui.Canvas canvas, Block source, Block target) {
    var offsetTopLeft = ui.Offset(source.rect.right, source.rect.top);
    var offsetTopRight = ui.Offset(target.rect.left, target.rect.top);
    var offsetBottomLeft = ui.Offset(source.rect.right, source.rect.bottom);
    var offsetBottomRight = ui.Offset(target.rect.left, target.rect.bottom);

    return drawPath(canvas, offsetTopLeft, offsetTopRight, offsetBottomLeft, offsetBottomRight, const Color(0x4556687A), true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void drawBoxAndText(canvas, x, y, w, h, text, Color color) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
    drawText(canvas, text, x, y, color: Colors.white);
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
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(context, const Offset(0.0, 0.0));
    context.restore();
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
  var largest = double.minPositive;
  var smallest = double.maxFinite;

  for (var element in list) {
    largest = min(largest, element.value);
    smallest = max(smallest, element.value);
  }

  const double heightOfSmallest = 100.0;
  double ratioPriceToHeight = (heightOfSmallest / largest).abs();
  return ratioPriceToHeight;
}
