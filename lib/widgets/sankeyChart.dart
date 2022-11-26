import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:money/widgets/sankeyBand.dart';

import '../helpers.dart';

class SanKeyEntry {
  String name = "";
  double value = 0.00;
}

class SankeyPaint extends CustomPainter {
  List<SanKeyEntry> listOfIncomes;
  List<SanKeyEntry> listOfExpenses;
  double padding;

  SankeyPaint(this.listOfIncomes, this.listOfExpenses, this.padding) {
    //
  }

  @override
  bool shouldRepaint(SankeyPaint oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(SankeyPaint oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    const double targetWidth = 100.0;
    const double targetHeight = 200.0;
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

    // Income and Expense to Net
    var netAmount = totalIncome - totalExpense;
    lastHeight = ratioIncomeToExpense * netAmount;
    lastHeight = max(Block.minBlockHeight, lastHeight);

    var targetLeft = size.width - targetWidth - padding;
    Block targetNet = Block("Net\n${getCurrencyText(netAmount)}", ui.Rect.fromLTWH(targetLeft, 0, targetWidth, lastHeight), const Color(0xff0061ad), false);

    renderSourcesToTargetAsPercentage(canvas, [targetIncome, targetExpense], targetNet);
  }

  double renderSourcesToTarget(ui.Canvas canvas, list, useAsIncome, double left, double top, Block target, Color color) {
    double ratioPriceToHeight = getRatioFromMaxValue(list, useAsIncome);

    drawBoxAndTextFromTarget(canvas, target);

    var verticalPosition = 0.0;
    var sourceWidth = 200.0;

    List<Block> sources = [];

    // Prepare the sources (Left Side)
    for (var element in list) {
      // Prepare a Left Block
      double height = max(10, element.value.abs() * ratioPriceToHeight);
      double boxTop = top + verticalPosition;
      Rect rect = Rect.fromLTWH(left, boxTop, sourceWidth, height);
      Block source = Block(element.name + ": " + getCurrencyText(element.value), rect, color, useAsIncome);
      sources.add(source);

      verticalPosition += height + padding;
    }

    renderSourcesToTargetAsPercentage(canvas, sources, target);

    // how much vertical space was needed to render this
    return verticalPosition;
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
