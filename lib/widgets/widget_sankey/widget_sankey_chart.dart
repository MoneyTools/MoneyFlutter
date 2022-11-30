import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../helpers.dart';
import 'sankey_helper.dart';

class SankeyPaint extends CustomPainter {
  List<SanKeyEntry> listOfIncomes;
  List<SanKeyEntry> listOfExpenses;
  double gap = Constants.gapBetweenChannels;
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

    var horizontalCenter = size.width / 2;

    var topOfCenters = 100.0;

    var verticalStackOfTargets = topOfCenters;

    var totalIncome = listOfIncomes.fold(0.00, (sum, item) => sum + item.value);
    var totalExpense = listOfExpenses.fold(0.00, (sum, item) => sum + item.value).abs();

    var ratioIncomeToExpense = (Constants.targetHeight) / (totalIncome + totalExpense);

    // Box for "Revenue"
    var lastHeight = ratioIncomeToExpense * totalIncome;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetIncome = Block(
      "Revenue\n${getCurrencyText(totalIncome)}",
      ui.Rect.fromLTWH(horizontalCenter - (withOfEntry * 1.2), verticalStackOfTargets, withOfEntry, lastHeight),
      Constants.colorIncome,
      getTheme(context).backgroundColor,
    );

    // Box for "Total Expenses"
    verticalStackOfTargets += gap + lastHeight;
    lastHeight = ratioIncomeToExpense * totalExpense;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetExpense = Block(
      "Expenses\n-${getCurrencyText(totalExpense)}",
      ui.Rect.fromLTWH(horizontalCenter + (withOfEntry * 0.2), topOfCenters, withOfEntry, lastHeight),
      Constants.colorExpense,
      getTheme(context).backgroundColor,
    );

    // Box for "Net Profit"
    var netAmount = totalIncome - totalExpense;
    lastHeight = ratioIncomeToExpense * netAmount;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetNet = Block(
      "Net: ${getCurrencyText(netAmount)}",
      ui.Rect.fromLTWH(targetExpense.rect.left, targetExpense.rect.bottom + gap, withOfEntry, lastHeight),
      Constants.colorNet,
      getTheme(context).backgroundColor,
    );
    drawBoxAndTextFromTarget(canvas, targetNet);

    // Left Side - "Source of Incomes"
    var stackVerticalPosition = 0.0;
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfIncomes, 0, stackVerticalPosition, targetIncome, Constants.colorIncome, getTheme(context).backgroundColor);

    stackVerticalPosition += gap * 5;

    // Right Side - "Source of Expenses"
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfExpenses, size.width - withOfEntry, 0, targetExpense, Constants.colorExpense, getTheme(context).backgroundColor);

    var heightProfitFromIncomeSection = targetIncome.rect.height - targetExpense.rect.height;

    // Render Channel from "Expenses" to "Revenue"
    drawChanel(
      canvas,
      ChannelPoint(targetExpense.rect.left, targetExpense.rect.top, targetExpense.rect.bottom),
      ChannelPoint(targetIncome.rect.right, targetIncome.rect.top, targetIncome.rect.bottom - heightProfitFromIncomeSection),
    );

    // Render from "Revenue" remaining profit to "Net" box
    drawChanel(
        canvas, ChannelPoint(targetIncome.rect.right, targetIncome.rect.bottom - heightProfitFromIncomeSection, targetIncome.rect.bottom), ChannelPoint(targetNet.rect.left, targetNet.rect.top, targetNet.rect.bottom),
        color: Constants.colorNet);
  }

  double renderSourcesToTarget(ui.Canvas canvas, list, double left, double top, Block target, Color color, Color textColor) {
    var sumOfHeight = sumValue(list);

    double ratioPriceToHeight = target.rect.height / sumOfHeight.abs();

    var verticalPosition = 0.0;

    List<Block> blocks = [];

    // Prepare the sources (Left Side)
    for (var element in list) {
      // Prepare a Left Block
      double height = max(Constants.minBlockHeight, element.value.abs() * ratioPriceToHeight);
      double boxTop = top + verticalPosition;
      Rect rect = Rect.fromLTWH(left, boxTop, withOfEntry, height);
      Block source = Block(element.name + ": " + getCurrencyText(element.value), rect, color, textColor);
      source.textColor = textColor;
      blocks.add(source);

      verticalPosition += height + gap;
    }

    renderSourcesToTargetAsPercentage(canvas, blocks, target);

    // Draw the text last to ensure that its on top
    drawBoxAndTextFromTarget(canvas, target);

    // how much vertical space was needed to render this
    return verticalPosition;
  }
}
