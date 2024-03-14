// Imports
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';

import 'package:money/models/constants.dart';
import 'package:money/widgets/sankey/sankey_colors.dart';
import 'package:money/widgets/sankey/sankey_helper.dart';

// Exports
export 'package:money/widgets/sankey/sankey_helper.dart';

class SankeyPainter extends CustomPainter {
  List<SanKeyEntry> listOfIncomes;
  List<SanKeyEntry> listOfExpenses;
  double gap = Constants.gapBetweenChannels;
  double topOfCenters = Constants.gapBetweenChannels * 2;
  double columnWidth = Constants.sanKeyColumnWidth;
  double connectorWidth = Constants.sanKeyColumnWidth / 2;
  double incomeHeight = Constants.targetHeight;
  SankeyColors colors;

  /// Constructor
  SankeyPainter({
    required this.listOfIncomes,
    required this.listOfExpenses,
    required this.colors,
  });

  @override
  bool shouldRepaint(final SankeyPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(final SankeyPainter oldDelegate) => false;

  @override
  void paint(final Canvas canvas, final Size size) {
    columnWidth = Constants.sanKeyColumnWidth;

    final double maxWidth = size.width;
    final double horizontalCenter = maxWidth / 2;

    double verticalStackOfTargets = topOfCenters;

    final double totalIncome = listOfIncomes.fold(0.00, (final double sum, final SanKeyEntry item) => sum + item.value);
    final double totalExpense =
        listOfExpenses.fold(0.00, (final double sum, final SanKeyEntry item) => sum + item.value).abs();

    final double h = max(incomeHeight, size.height);

    final double ratioIncomeToExpense = h / (totalIncome + totalExpense);

    // Box for "Revenue"
    double lastHeight = ratioIncomeToExpense * totalIncome;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    final Block targetRevenues = Block(
      'Revenue  ${getNumberAsShorthandText(totalIncome)}',
      ui.Rect.fromLTWH(horizontalCenter - (columnWidth), verticalStackOfTargets, columnWidth, lastHeight),
      colors.colorIncome,
      colors.textColor,
      TextAlign.center,
      TextAlign.center,
    );

    // Box for "Total Expenses"
    verticalStackOfTargets += gap + lastHeight;
    lastHeight = ratioIncomeToExpense * totalExpense;
    lastHeight = max(Block.minBlockHeight, lastHeight);
    final Block targetExpenses = Block(
      'Expenses -${getNumberAsShorthandText(totalExpense)}',
      ui.Rect.fromLTWH(horizontalCenter + columnWidth * 0.1, topOfCenters, columnWidth, lastHeight),
      colors.colorExpense,
      colors.textColor,
      TextAlign.center,
      TextAlign.center,
    );

    // Left Side - "Source of Incomes"
    double stackVerticalPosition = 0.0;

    stackVerticalPosition += renderSourcesToTarget(
        canvas, listOfIncomes, 0, stackVerticalPosition, targetRevenues, colors.colorIncome, colors.textColor);

    stackVerticalPosition += gap * 5;

    // Right Side - "Source of Expenses"
    stackVerticalPosition += renderSourcesToTarget(
        canvas, listOfExpenses, maxWidth - columnWidth, 0, targetExpenses, colors.colorExpense, colors.textColor);

    final double heightProfitFromIncomeSection = targetRevenues.rect.height - targetExpenses.rect.height;

    // Render Channel from "Revenue" to "Expenses"
    drawChanel(
      canvas: canvas,
      // right side of the Revenues Box
      start: ChannelPoint(targetRevenues.rect.right, targetRevenues.rect.top,
          targetRevenues.rect.bottom - heightProfitFromIncomeSection),
      // Left side of the Expenses box
      end: ChannelPoint(targetExpenses.rect.left + 1, targetExpenses.rect.top, targetExpenses.rect.bottom),
      color: colors.colorExpense,
    );

    // Render from "Revenues" remaining profit to "Net" box
    // Box for "Net Profit/Lost"
    final double netAmount = totalIncome - totalExpense;
    renderNetProfitOrLost(
      netAmount,
      lastHeight,
      ratioIncomeToExpense,
      horizontalCenter,
      targetRevenues,
      targetExpenses,
      canvas,
      heightProfitFromIncomeSection,
    );
  }

  // Box for "Net Profit/Lost"
  // The box may show on both side
  // The right when depicting a "Net Profit"
  // or
  // The left when depicting a "Net Lost"
  void renderNetProfitOrLost(
    double netAmount,
    double lastHeight,
    double ratioIncomeToExpense,
    double horizontalCenter,
    Block targetRevenues,
    Block targetExpenses,
    ui.Canvas canvas,
    double heightProfitFromIncomeSection,
  ) {
    Block targetNet = buildSegmentForNetProfitLost(
      netAmount,
      lastHeight,
      ratioIncomeToExpense,
      horizontalCenter,
      targetRevenues,
      targetExpenses,
    );
    targetNet.draw(canvas);

    late ChannelPoint netStart;
    late ChannelPoint netEnd;
    if (netAmount < 0) {
      netStart = ChannelPoint(targetNet.rect.right - 1, targetNet.rect.top, targetNet.rect.bottom);
      netEnd = ChannelPoint(targetRevenues.rect.right, targetRevenues.rect.bottom, targetExpenses.rect.bottom);
    } else {
      netStart = ChannelPoint(targetRevenues.rect.right, targetRevenues.rect.bottom - heightProfitFromIncomeSection,
          targetRevenues.rect.bottom);
      netEnd = ChannelPoint(targetNet.rect.left + 1, targetNet.rect.top, targetNet.rect.bottom);
    }

    drawChanel(
      canvas: canvas,
      start: netStart,
      end: netEnd,
      color: colors.colorNet,
    );
  }

  // Box for "Net Profit/Lost"
  // The box may show on both side
  // The right when depicting a "Net Profit"
  // or
  // The left when depicting a "Net Lost"
  Block buildSegmentForNetProfitLost(
    double netAmount,
    double lastHeight,
    double ratioIncomeToExpense,
    double horizontalCenter,
    Block targetRevenues,
    Block targetExpenses,
  ) {
    lastHeight = ratioIncomeToExpense * netAmount.abs();
    lastHeight = max(Block.minBlockHeight, lastHeight);

    String text = 'Net ';
    late Rect rect;
    if (netAmount < 0) {
      // Net Lost
      text += 'Lost ';
      rect = ui.Rect.fromLTWH(
          horizontalCenter - (columnWidth + gap), targetRevenues.rect.bottom + (gap), columnWidth, lastHeight);
    } else {
      // Net Profit
      text += 'Profit ';
      rect = ui.Rect.fromLTWH(
          horizontalCenter + (columnWidth * 0.1), targetExpenses.rect.bottom + (gap), columnWidth, lastHeight);
    }
    text += getNumberAsShorthandText(netAmount);

    final Block targetNet = Block(
      text,
      rect,
      colors.colorNet,
      colors.textColor,
      TextAlign.center,
      TextAlign.center,
    );

    return targetNet;
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
      final ui.Rect rect = Rect.fromLTWH(left, boxTop, columnWidth, height);
      final Block source = Block('${element.name}: ${getNumberAsShorthandText(element.value)}', rect, color, textColor,
          TextAlign.center, TextAlign.center);
      source.textColor = textColor;
      blocks.add(source);

      verticalPosition += height + gap;
    }

    renderSourcesToTargetAsPercentage(canvas, blocks, target);

    // Draw the target box and text last to ensure that its on top
    target.draw(canvas);

    // how much vertical space was needed to render this
    return verticalPosition;
  }
}
