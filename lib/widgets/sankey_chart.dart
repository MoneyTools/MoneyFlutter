import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants.dart';
import '../helpers.dart';

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

class SanKeyEntry {
  String name = "";
  double value = 0.00;
}

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

  Block(this.name, this.rect, this.color, this.textColor) {
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
  var sumOfHeight = sumHeight(list);

  var rollingVerticalPositionDrawnOnTheTarget = target.rect.top;

  for (var block in list) {
    var ratioSourceBlockHeightToSumHeight = (block.rect.height / sumOfHeight);
    var targetSectionHeight = (target.rect.height * ratioSourceBlockHeightToSumHeight);

    var blockSideToStartFrom = target.rect.center.dx > block.rect.center.dx ? block.rect.right : block.rect.left;
    var targetSideToStartFrom = target.rect.center.dx > block.rect.center.dx ? target.rect.left : target.rect.right;

    drawChanel(canvas, ChannelPoint(blockSideToStartFrom, block.rect.top, block.rect.bottom),
        ChannelPoint(targetSideToStartFrom, rollingVerticalPositionDrawnOnTheTarget, rollingVerticalPositionDrawnOnTheTarget + targetSectionHeight),
        color: block.color);

    rollingVerticalPositionDrawnOnTheTarget += targetSectionHeight;
    drawBoxAndTextFromTarget(canvas, block);
  }
}

double getHeightNeededToRender(List<SanKeyEntry> list) {
  var sum = sumValue(list);

  var verticalPosition = 0.0;

  for (var element in list) {
    double height = (element.value.abs() / sum.abs()) * Constants.targetHeight;
    verticalPosition += height;
    verticalPosition += Constants.gapBetweenChannels;
  }

  // how much vertical space was needed to render this
  return verticalPosition;
}

List<double> getMinMaxValues(List<SanKeyEntry> list) {
  if (list.isEmpty) {
    return [0, 0];
  }
  if (list.length == 1) {
    return [list[0].value, list[0].value];
  }

  double valueMin = 0;
  double valueMax = 0;
  if (list[0].value < list[1].value) {
    valueMin = list[0].value;
    valueMax = list[1].value;
  } else {
    valueMin = list[1].value;
    valueMax = list[0].value;

    for (var element in list) {
      valueMin = min(valueMin, element.value);
      valueMax = max(valueMax, element.value);
    }
  }
  return [valueMin, valueMax];
}

double getHeightRationIncome(List<SanKeyEntry> list) {
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

double getHeightRatioExpense(List<SanKeyEntry> list) {
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

void drawBoxAndTextFromTarget(canvas, Block block) {
  var paint = Paint();
  paint.color = block.color.withOpacity(0.5);
  canvas.drawRect(block.rect, paint);
  drawText(canvas, block.name, block.rect.left + 4, block.rect.top + 2, color: block.textColor);
}

void drawText(Canvas context, String name, double x, double y, {Color color = Colors.black, double fontSize = 12.0, double angleRotationInRadians = 0.0}) {
  context.save();
  context.translate(x, y);
  context.rotate(angleRotationInRadians);
  TextSpan span = TextSpan(
      style: TextStyle(
        color: invertColor(color),
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
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

void drawChanel(canvas, ChannelPoint a, ChannelPoint b, {Color color = const Color(0xFF56687A)}) {
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
  paint.color = color.withOpacity(0.4);
  canvas.drawPath(path, paint);

  Paint paintStroke = Paint();
  paintStroke.style = PaintingStyle.stroke;
  paintStroke.strokeWidth = 0.5;
  paintStroke.color = Colors.black.withOpacity(0.3);
  canvas.drawPath(path, paintStroke);
}

sumHeight(List<Block> list) {
  var sumOfHeight = list.fold(0.0, (previousValue, element) => previousValue + element.rect.height);
  return sumOfHeight;
}

sumValue(List<SanKeyEntry> list) {
  var sumOfHeight = list.fold(0.0, (previousValue, element) => previousValue + element.value);
  return sumOfHeight;
}
