import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/constants.dart';
import '../../helpers.dart';
import 'sankey_helper.dart';

class SankeyPaint extends CustomPainter {
  List<SanKeyEntry> listOfIncomes;
  List<SanKeyEntry> listOfExpenses;
  double gap = Constants.gapBetweenChannels;
  double topOfCenters = Constants.gapBetweenChannels * 2;
  double columnWidth = Constants.sanKeyColumnWidth;
  double connectorWidth = Constants.sanKeyColumnWidth / 2;
  double incomeHeight = Constants.targetHeight;
  Color textColor = Colors.blue;
  BuildContext context;

  SankeyPaint(this.listOfIncomes, this.listOfExpenses, this.context) {
    //
  }

  @override
  bool shouldRepaint(SankeyPaint oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(SankeyPaint oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var textColor = getTheme(context).textTheme.titleMedium?.color;
    textColor ??= Colors.grey;

    columnWidth = Constants.sanKeyColumnWidth;

    var maxWidth = max(context.size!.width, size.width) - 30;
    var horizontalCenter = maxWidth / 2;

    var verticalStackOfTargets = topOfCenters;

    var totalIncome = listOfIncomes.fold(0.00, (sum, item) => sum + item.value);
    var totalExpense = listOfExpenses.fold(0.00, (sum, item) => sum + item.value).abs();

    // var maNumberOfLeafItems = max(listOfIncomes.length, listOfExpenses.length);

    var h = max(incomeHeight, context.size!.height);

    var ratioIncomeToExpense = h / (totalIncome + totalExpense);

    // Box for "Revenue"
    var lastHeight = ratioIncomeToExpense * totalIncome;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetIncome = Block(
      "Revenue  ${getNumberAsShorthandText(totalIncome)}",
      ui.Rect.fromLTWH(horizontalCenter - (columnWidth * 1.2), verticalStackOfTargets, columnWidth, lastHeight),
      Constants.colorIncome,
      textColor,
      TextAlign.center,
      TextAlign.center,
    );

    // Box for "Total Expenses"
    verticalStackOfTargets += gap + lastHeight;
    lastHeight = ratioIncomeToExpense * totalExpense;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetExpense = Block(
      "Expenses -${getNumberAsShorthandText(totalExpense)}",
      ui.Rect.fromLTWH(horizontalCenter + (columnWidth * 0.2), topOfCenters, columnWidth, lastHeight),
      Constants.colorExpense,
      textColor,
      TextAlign.center,
      TextAlign.center,
    );

    // Box for "Net Profit"
    var netAmount = totalIncome - totalExpense;
    lastHeight = ratioIncomeToExpense * netAmount;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    Block targetNet = Block(
      "Net: ${getNumberAsShorthandText(netAmount)}",
      ui.Rect.fromLTWH(targetExpense.rect.left, targetExpense.rect.bottom + gap, columnWidth, lastHeight),
      Constants.colorNet,
      textColor,
      TextAlign.center,
      TextAlign.center,
    );
    targetNet.draw(canvas);

    // Left Side - "Source of Incomes"
    var stackVerticalPosition = 0.0;

    stackVerticalPosition += renderSourcesToTarget(canvas, listOfIncomes, 0, stackVerticalPosition, targetIncome, Constants.colorIncome, textColor);

    stackVerticalPosition += gap * 5;

    // Right Side - "Source of Expenses"
    stackVerticalPosition += renderSourcesToTarget(canvas, listOfExpenses, maxWidth - columnWidth, 0, targetExpense, Constants.colorExpense, textColor);

    var heightProfitFromIncomeSection = targetIncome.rect.height - targetExpense.rect.height;

    // Render Channel from "Expenses" to "Revenue"
    drawChanel(
      canvas,
      ChannelPoint(targetExpense.rect.left, targetExpense.rect.top, targetExpense.rect.bottom),
      ChannelPoint(targetIncome.rect.right, targetIncome.rect.top, targetIncome.rect.bottom - heightProfitFromIncomeSection),
      color: Colors.grey.withOpacity(0.5),
    );

    // Render from "Revenue" remaining profit to "Net" box
    drawChanel(
      canvas,
      ChannelPoint(targetIncome.rect.right, targetIncome.rect.bottom - heightProfitFromIncomeSection, targetIncome.rect.bottom),
      ChannelPoint(targetNet.rect.left, targetNet.rect.top, targetNet.rect.bottom),
      color: Colors.grey.withOpacity(0.5),
    );
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
      Rect rect = Rect.fromLTWH(left, boxTop, columnWidth, height);
      Block source = Block(element.name + ": " + getNumberAsShorthandText(element.value), rect, color, textColor, TextAlign.center, TextAlign.center);
      source.textColor = textColor;
      blocks.add(source);

      verticalPosition += height + gap;
    }

    renderSourcesToTargetAsPercentage(canvas, blocks, target);

    // Draw the text last to ensure that its on top
    target.draw(canvas);

    // how much vertical space was needed to render this
    return verticalPosition;
  }
}
