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
  double gap = 10;
  double withOfEntry = 100.0;
  Color textColor = Colors.blue;
  BuildContext context;

  SankeyPaint(this.listOfIncomes, this.listOfExpenses, this.context) {
    //
  }

  @override
  bool shouldRepaint(SankeyPaint oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(SankeyPaint oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    withOfEntry = size.width * 0.10; // 10% of width
    const double targetHeight = 200.0;
    var horizontalCenter = size.width / 2;

    var topOfCenters = 100.0;

    var verticalStackOfTargets = topOfCenters;

    var totalIncome = listOfIncomes.fold(0.00, (sum, item) => sum + item.value);
    var totalExpense = listOfExpenses.fold(0.00, (sum, item) => sum + item.value).abs();

    var ratioIncomeToExpense = (targetHeight) / (totalIncome + totalExpense);

    // Box for "Revenue"
    var lastHeight = ratioIncomeToExpense * totalIncome;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetIncome = Block("Revenue\n${getCurrencyText(totalIncome)}", ui.Rect.fromLTWH(horizontalCenter - (withOfEntry * 1.2), verticalStackOfTargets, withOfEntry, lastHeight), const Color(0xff387000),
        getTheme(context).backgroundColor, true);

    // Box for "Total Expenses"
    verticalStackOfTargets += gap + lastHeight;
    lastHeight = ratioIncomeToExpense * totalExpense;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetExpense = Block(
        "Expenses\n-${getCurrencyText(totalExpense)}", ui.Rect.fromLTWH(horizontalCenter + (withOfEntry * 0.2), topOfCenters, withOfEntry, lastHeight), const Color(0xff8c0e00), getTheme(context).backgroundColor, false);

    // Box for "Net Profit"
    var netAmount = totalIncome - totalExpense;
    lastHeight = ratioIncomeToExpense * netAmount;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetNet =
        Block("Net: ${getCurrencyText(netAmount)}", ui.Rect.fromLTWH(targetExpense.rect.left, targetExpense.rect.bottom + gap, withOfEntry, lastHeight), const Color(0xff0061ad), getTheme(context).backgroundColor, false);
    drawBoxAndTextFromTarget(canvas, targetNet);

    // Render "Source of Incomes" on the left
    var stackVerticalPosition = 0.0;
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfIncomes, true, 0, stackVerticalPosition, targetIncome, const Color(0xaa2f6001), getTheme(context).backgroundColor);
    stackVerticalPosition += gap * 5;

    // Render "Source of Expenses" on the right
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfExpenses, false, size.width - withOfEntry, 0, targetExpense, const Color(0x9b730000), getTheme(context).backgroundColor);

    var heightProfitFromIncomeSection = targetIncome.rect.height - targetExpense.rect.height;
    // Render Channel from "Expenses" to "Revenue"
    drawChanel(
      canvas,
      ChannelPoint(targetExpense.rect.left, targetExpense.rect.top, targetExpense.rect.bottom),
      ChannelPoint(targetIncome.rect.right, targetIncome.rect.top, targetIncome.rect.bottom - heightProfitFromIncomeSection),
    );

    // Render from "Revenue" remaining profit to "Net" box
    drawChanel(
      canvas,
      ChannelPoint(targetIncome.rect.right, targetIncome.rect.bottom - heightProfitFromIncomeSection, targetIncome.rect.bottom),
      ChannelPoint(targetNet.rect.left, targetNet.rect.top, targetNet.rect.bottom),
    );
  }

  double renderSourcesToTarget(ui.Canvas canvas, list, useAsIncome, double left, double top, Block target, Color color, Color textColor) {
    double ratioPriceToHeight = getRatioFromMaxValue(list, useAsIncome);

    drawBoxAndTextFromTarget(canvas, target);

    var verticalPosition = 0.0;

    List<Block> sources = [];

    // Prepare the sources (Left Side)
    for (var element in list) {
      // Prepare a Left Block
      double height = max(4, element.value.abs() * ratioPriceToHeight);
      double boxTop = top + verticalPosition;
      Rect rect = Rect.fromLTWH(left, boxTop, withOfEntry, height);
      Block source = Block(element.name + ": " + getCurrencyText(element.value), rect, color, textColor, useAsIncome);
      source.textColor = textColor;
      sources.add(source);

      verticalPosition += height + gap;
    }

    renderSourcesToTargetAsPercentage(canvas, sources, target);

    // how much vertical space was needed to render this
    return verticalPosition;
  }
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
