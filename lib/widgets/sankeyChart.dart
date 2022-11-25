import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../helpers.dart';

class SanKeyEntry {
  String name = "";
  double value = 0.00;
}

class FunnelTarget {
  String name = "";
  Rect rect;
  Color color;
  bool useAsIncome = true;

  FunnelTarget(this.name, this.rect, this.color, this.useAsIncome) {
    //
  }
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
    var targetHeight = 100.0;
    var horizontalCenter = size.width / 2;

    var verticalStackOfTargets = 0.0;

    var totalIncome = listOfIncomes.fold(0.00, (sum, item) => sum + item.value);
    var totalExpense = listOfExpenses.fold(0.00, (sum, item) => sum + item.value.abs());

    var ratioIncomeToExpense = (targetHeight) / (totalIncome + totalExpense);

    var lastHeight = ratioIncomeToExpense * totalIncome;

    FunnelTarget targetIncome = FunnelTarget(
      "Incomes\n${getCurrencyText(totalIncome)}",
      ui.Rect.fromLTWH(
        horizontalCenter,
        verticalStackOfTargets,
        targetWidth,
        lastHeight,
      ),
      const Color(0xff254406),
      true,
    );

    verticalStackOfTargets += padding + lastHeight;
    lastHeight = ratioIncomeToExpense * totalExpense;
    FunnelTarget targetExpense = FunnelTarget(
      "Expenses\n${getCurrencyText(totalExpense)}",
      ui.Rect.fromLTWH(
        horizontalCenter,
        verticalStackOfTargets,
        targetWidth,
        lastHeight,
      ),
      const Color(0xFF4D0C05),
      false,
    );

    var stackVerticalPosition = 0.0;
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfIncomes, true, padding, stackVerticalPosition, targetIncome);
    stackVerticalPosition += padding;
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfExpenses, false, padding, stackVerticalPosition, targetExpense);

    FunnelTarget targetNet = FunnelTarget("Net\n${getCurrencyText(totalIncome - totalExpense)}", ui.Rect.fromLTWH(targetLeft, 0, targetWidth, targetHeight / 2), const Color(0xFF003965), false);
    drawBoxAndTextFromTarget(canvas, targetNet);

    drawPathFromTarget(canvas, targetIncome, targetNet);
    drawPathFromTarget(canvas, targetExpense, targetNet);
  }

  double renderSourcesToTarget(ui.Canvas canvas, list, useAsIncome, double left, double top, FunnelTarget target) {
    double ratioPriceToHeight = getRatioFromMaxValue(list, useAsIncome);

    drawBoxAndTextFromTarget(canvas, target);

    var verticalPosition = 0.0;
    var sourceWidth = 200.0;

    var destinationRightLeft = ui.Offset(target.rect.left, target.rect.top);
    var destinationRightBottom = ui.Offset(target.rect.left, target.rect.bottom);
    for (var element in list) {
      double height = element.value.abs() * ratioPriceToHeight;
      double boxTop = top + verticalPosition;
      drawBoxAndText(canvas, left, boxTop, sourceWidth, height, element.name, target.color);
      var offsetLeftTop = ui.Offset(left + sourceWidth, boxTop);
      var offsetLeftBottom = ui.Offset(left + sourceWidth, boxTop + height);
      drawPath(canvas, offsetLeftTop, offsetLeftBottom, destinationRightLeft, destinationRightBottom, Colors.grey);
      verticalPosition += height + padding;
    }

    // how much vertical space was needed to render this
    return verticalPosition;
  }

  ui.Path drawPath(
    ui.Canvas canvas,
    ui.Offset topLeft,
    ui.Offset topRight,
    ui.Offset bottomLeft,
    ui.Offset bottomRight,
    color,
  ) {
    Path downwardPath = Path();
    downwardPath.moveTo(topLeft.dx, topLeft.dy);

    downwardPath.lineTo(topRight.dx, topRight.dy);
    downwardPath.lineTo(bottomRight.dx, bottomRight.dy);
    downwardPath.lineTo(bottomLeft.dx, bottomLeft.dy);

    Paint paint = Paint();
    paint.color = color;
    canvas.drawPath(downwardPath, paint);

    return downwardPath;
  }

  ui.Path drawPathFromTarget(ui.Canvas canvas, FunnelTarget source, FunnelTarget target) {
    var offsetTopLeft = ui.Offset(source.rect.right, source.rect.top);
    var offsetTopRight = ui.Offset(target.rect.left, target.rect.top);
    var offsetBottomLeft = ui.Offset(source.rect.right, source.rect.bottom);
    var offsetBottomRight = ui.Offset(target.rect.left, target.rect.bottom);

    return drawPath(canvas, offsetTopLeft, offsetTopRight, offsetBottomLeft, offsetBottomRight, Colors.lightBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void drawBoxAndText(canvas, x, y, w, h, text, Color color) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
    drawText(canvas, text, x, y, color: Colors.white);
  }

  void drawBoxAndTextFromTarget(canvas, FunnelTarget target) {
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
