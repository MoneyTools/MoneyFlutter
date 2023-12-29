import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/transactions.dart';

import 'package:money/helpers.dart';
import 'package:money/models/accounts.dart';
import 'package:money/models/constants.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/scroll_both_ways.dart';
import 'package:money/widgets/widget_sankey/sankey_helper.dart';
import 'package:money/widgets/widget_sankey/widget_sankey_chart.dart';
import 'package:money/widgets/widget_view.dart';

class ViewCashFlow extends ViewWidget<SanKeyEntry> {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget<SanKeyEntry>> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends ViewWidgetState<SanKeyEntry> {
  List<Account> accountsOpened = Accounts.getOpenAccounts();
  double totalIncomes = 0.00;
  double totalExpenses = 0.00;
  double totalSavings = 0.00;
  double totalInvestments = 0.00;
  double totalNones = 0.00;
  double padding = 10.0;
  double totalHeight = 0.0;

  Map<Category, double> mapOfIncomes = <Category, double>{};
  Map<Category, double> mapOfExpenses = <Category, double>{};
  List<SanKeyEntry> sanKeyListOfIncomes = <SanKeyEntry>[];
  List<SanKeyEntry> sanKeyListOfExpenses = <SanKeyEntry>[];

  ViewCashFlowState();

  @override
  void initState() {
    super.initState();
    transformData();
  }

  void transformData() {
    for (Transaction element in Transactions.list) {
      final Category? category = Categories.get(element.categoryId);
      if (category != null) {
        switch (category.type) {
          case CategoryType.income:
          case CategoryType.saving:
          case CategoryType.investment:
            totalIncomes += element.amount;

            final Category? topCategory = Categories.getTopAncestor(category);
            if (topCategory != null) {
              double? mapValue = mapOfIncomes[topCategory];
              mapValue ??= 0;
              mapOfIncomes[topCategory] = mapValue + element.amount;
            }
            break;
          case CategoryType.expense:
            totalExpenses += element.amount;
            final Category? topCategory = Categories.getTopAncestor(category);
            if (topCategory != null) {
              double? mapValue = mapOfExpenses[topCategory];
              mapValue ??= 0;
              mapOfExpenses[topCategory] = mapValue + element.amount;
            }
            break;
          default:
            totalNones += element.amount;
            break;
        }
      }
    }

    // Clean up the Incomes, drop 0.00
    mapOfIncomes.removeWhere((final Category k, final double v) => v <= 0.00);
    // Sort Descending
    mapOfIncomes = Map<Category, double>.fromEntries(mapOfIncomes.entries.toList()..sort((final MapEntry<Category, double> e1, final MapEntry<Category, double> e2) => (e2.value - e1.value).toInt()));

    mapOfIncomes.forEach((final Category key, final double value) {
      sanKeyListOfIncomes.add(SanKeyEntry()
        ..name = key.name
        ..value = value);
    });

    // Clean up the Expenses, drop 0.00
    mapOfExpenses.removeWhere((final Category k, final double v) => v == 0.00);

    // Sort Descending, in the case of expenses that means the largest negative number to the least negative number
    mapOfExpenses = Map<Category, double>.fromEntries(mapOfExpenses.entries.toList()..sort((final MapEntry<Category, double> e1, final MapEntry<Category, double> e2) => (e1.value - e2.value).toInt()));

    mapOfExpenses.forEach((final Category key, final double value) {
      sanKeyListOfExpenses.add(SanKeyEntry()
        ..name = key.name
        ..value = value);
    });

    final double heightNeededToRenderIncomes = getHeightNeededToRender(sanKeyListOfIncomes);
    final double heightNeededToRenderExpenses = getHeightNeededToRender(sanKeyListOfExpenses);
    totalHeight = max(heightNeededToRenderIncomes, heightNeededToRenderExpenses);
  }

  @override
  Widget build(final BuildContext context) {
    return getViewExpandAndPadding(
      Column(
        children: <Widget>[
          Header('Cash Flow', totalIncomes + totalExpenses, 'See where assets are allocated.'),
          Expanded(child: ScrollBothWay(child: getView(context))),
        ],
      ),
    );
  }

  Widget getView(final BuildContext context) {
    return SizedBox(
      height: 600, // let the child determine the height
      width: Constants.sanKeyColumnWidth * 5, // let the child determine the width
      child: CustomPaint(
        painter: SankeyPaint(sanKeyListOfIncomes, sanKeyListOfExpenses, context),
      ),
    );
  }
}
