import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/transactions.dart';

import '../helpers.dart';
import '../models/accounts.dart';
import '../widgets/header.dart';
import '../widgets/widget_sankey/sankey_helper.dart';
import '../widgets/widget_sankey/widget_sankey_chart.dart';

class ViewCashFlow extends StatefulWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewCashFlow> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends State<ViewCashFlow> {
  var accountsOpened = Accounts.getOpenAccounts();
  var totalIncomes = 0.00;
  var totalExpenses = 0.00;
  var totalSavings = 0.00;
  var totalInvestments = 0.00;
  var totalNones = 0.00;
  var padding = 10.0;
  var totalHeight = 0.0;

  var mapOfIncomes = <Category, double>{};
  var mapOfExpenses = <Category, double>{};
  List<SanKeyEntry> sanKeyListOfIncomes = [];
  List<SanKeyEntry> sanKeyListOfExpenses = [];

  ViewCashFlowState();

  @override
  void initState() {
    super.initState();
    transformData();
  }

  void transformData() {
    for (var element in Transactions.list) {
      var category = Categories.get(element.categoryId);
      if (category != null) {
        switch (category.type) {
          case CategoryType.income:
          case CategoryType.saving:
          case CategoryType.investment:
            totalIncomes += element.amount;

            var topCategory = Categories.getTopAncestor(category);
            if (topCategory != null) {
              var mapValue = mapOfIncomes[topCategory];
              mapValue ??= 0;
              mapOfIncomes[topCategory] = mapValue + element.amount;
            }
            break;
          case CategoryType.expense:
            totalExpenses += element.amount;
            var topCategory = Categories.getTopAncestor(category);
            if (topCategory != null) {
              var mapValue = mapOfExpenses[topCategory];
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
    mapOfIncomes.removeWhere((k, v) => v <= 0.00);
    // Sort Descending
    mapOfIncomes = Map.fromEntries(mapOfIncomes.entries.toList()..sort((e1, e2) => (e2.value - e1.value).toInt()));

    mapOfIncomes.forEach((key, value) {
      sanKeyListOfIncomes.add(SanKeyEntry()
        ..name = key.name
        ..value = value);
    });

    // Clean up the Expenses, drop 0.00
    mapOfExpenses.removeWhere((k, v) => v == 0.00);

    // Sort Descending, in the case of expenses that means the largest negative number to the least negative number
    mapOfExpenses = Map.fromEntries(mapOfExpenses.entries.toList()..sort((e1, e2) => (e1.value - e2.value).toInt()));

    mapOfExpenses.forEach((key, value) {
      sanKeyListOfExpenses.add(SanKeyEntry()
        ..name = key.name
        ..value = value);
    });

    var heightNeededToRenderIncomes = getHeightNeededToRender(sanKeyListOfIncomes);
    var heightNeededToRenderExpenses = getHeightNeededToRender(sanKeyListOfExpenses);
    totalHeight = max(heightNeededToRenderIncomes, heightNeededToRenderExpenses);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView(
      scrollDirection: Axis.vertical,
      children: [
        Header("Cash Flow", totalIncomes + totalExpenses, "See where assets are allocated"),
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: SizedBox(
              height: totalHeight,
              child: CustomPaint(
                painter: SankeyPaint(sanKeyListOfIncomes, sanKeyListOfExpenses, context),
              ),
            )),
      ],
    ));
  }
}
