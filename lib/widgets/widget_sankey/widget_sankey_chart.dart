import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';

import 'package:money/models/constants.dart';
import 'package:money/widgets/widget_sankey/sankey_helper.dart';

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
  bool shouldRepaint(final SankeyPaint oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(final SankeyPaint oldDelegate) => false;

  @override
  void paint(final Canvas canvas, final Size size) {
    ui.Color? textColor = getTheme(context).textTheme.titleMedium?.color;
    textColor ??= Colors.grey;

    columnWidth = Constants.sanKeyColumnWidth;

    final double maxWidth = max(context.size!.width, size.width) - 30;
    final double horizontalCenter = maxWidth / 2;

    double verticalStackOfTargets = topOfCenters;

    final double totalIncome = listOfIncomes.fold(0.00, (final double sum, final SanKeyEntry item) => sum + item.value);
    final double totalExpense =
        listOfExpenses.fold(0.00, (final double sum, final SanKeyEntry item) => sum + item.value).abs();

    // var maNumberOfLeafItems = max(listOfIncomes.length, listOfExpenses.length);

    final double h = max(incomeHeight, context.size!.height);

    final double ratioIncomeToExpense = h / (totalIncome + totalExpense);

    // Box for "Revenue"
    double lastHeight = ratioIncomeToExpense * totalIncome;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    final Block targetIncome = Block(
      'Revenue  ${getNumberAsShorthandText(totalIncome)}',
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
    final Block targetExpense = Block(
      'Expenses -${getNumberAsShorthandText(totalExpense)}',
      ui.Rect.fromLTWH(horizontalCenter + (columnWidth * 0.2), topOfCenters, columnWidth, lastHeight),
      Constants.colorExpense,
      textColor,
      TextAlign.center,
      TextAlign.center,
    );

    // Box for "Net Profit"
    final double netAmount = totalIncome - totalExpense;
    lastHeight = ratioIncomeToExpense * netAmount;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    final Block targetNet = Block(
      'Net: ${getNumberAsShorthandText(netAmount)}',
      ui.Rect.fromLTWH(targetExpense.rect.left, targetExpense.rect.bottom + gap, columnWidth, lastHeight),
      Constants.colorNet,
      textColor,
      TextAlign.center,
      TextAlign.center,
    );
    targetNet.draw(canvas);

    // Left Side - "Source of Incomes"
    double stackVerticalPosition = 0.0;

    stackVerticalPosition += renderSourcesToTarget(
        canvas, listOfIncomes, 0, stackVerticalPosition, targetIncome, Constants.colorIncome, textColor);

    stackVerticalPosition += gap * 5;

    // Right Side - "Source of Expenses"
    stackVerticalPosition += renderSourcesToTarget(
        canvas, listOfExpenses, maxWidth - columnWidth, 0, targetExpense, Constants.colorExpense, textColor);

    final double heightProfitFromIncomeSection = targetIncome.rect.height - targetExpense.rect.height;

    // Render Channel from "Expenses" to "Revenue"
    drawChanel(
      canvas,
      ChannelPoint(targetExpense.rect.left, targetExpense.rect.top, targetExpense.rect.bottom),
      ChannelPoint(
          targetIncome.rect.right, targetIncome.rect.top, targetIncome.rect.bottom - heightProfitFromIncomeSection),
      color: Colors.grey.withOpacity(0.5),
    );

    // Render from "Revenue" remaining profit to "Net" box
    drawChanel(
      canvas,
      ChannelPoint(
          targetIncome.rect.right, targetIncome.rect.bottom - heightProfitFromIncomeSection, targetIncome.rect.bottom),
      ChannelPoint(targetNet.rect.left, targetNet.rect.top, targetNet.rect.bottom),
      color: Colors.grey.withOpacity(0.5),
    );
  }

  double renderSourcesToTarget(
    final ui.Canvas canvas,
    final List<SanKeyEntry> list,
    final double left,
    final double top,
    final Block target,
    final Color color,
    final Color textColor,
  ) {
    final double sumOfHeight = sumValue(list);

    final double ratioPriceToHeight = target.rect.height / sumOfHeight.abs();

    double verticalPosition = 0.0;

    final List<Block> blocks = <Block>[];

    // Prepare the sources (Left Side)
    for (SanKeyEntry element in list) {
      // Prepare a Left Block
      final double height = max(Constants.minBlockHeight, element.value.abs() * ratioPriceToHeight);
      final double boxTop = top + verticalPosition;
      final Rect rect = Rect.fromLTWH(left, boxTop, columnWidth, height);
      final Block source = Block('${element.name}: ${getNumberAsShorthandText(element.value)}', rect, color, textColor,
          TextAlign.center, TextAlign.center);
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
