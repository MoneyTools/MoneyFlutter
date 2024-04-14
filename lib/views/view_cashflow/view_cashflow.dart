import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view_header.dart';
import 'package:money/widgets/sankey/sankey_colors.dart';
import 'package:money/widgets/sankey/sankey.dart';
import 'package:money/views/view.dart';

class ViewCashFlow extends ViewWidget {
  const ViewCashFlow({super.key});

  @override
  State<ViewWidget> createState() => ViewCashFlowState();
}

class ViewCashFlowState extends ViewWidgetState {
  List<Account> accountsOpened = Data().accounts.getOpenAccounts();
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
    for (Transaction element in Data().transactions.iterableList()) {
      final Category? category = Data().categories.get(element.categoryId.value);
      if (category != null) {
        switch (category.type.value) {
          case CategoryType.income:
          case CategoryType.saving:
          case CategoryType.investment:
            totalIncomes += element.amount.value.amount;

            final Category topCategory = Data().categories.getTopAncestor(category);
            double? mapValue = mapOfIncomes[topCategory];
            mapValue ??= 0;
            mapOfIncomes[topCategory] = mapValue + element.amount.value.amount;
            break;
          case CategoryType.expense:
            totalExpenses += element.amount.value.amount;
            final Category topCategory = Data().categories.getTopAncestor(category);
            double? mapValue = mapOfExpenses[topCategory];
            mapValue ??= 0;
            mapOfExpenses[topCategory] = mapValue + element.amount.value.amount;
            break;
          default:
            totalNones += element.amount.value.amount;
            break;
        }
      }
    }

    // Clean up the Incomes, drop 0.00
    mapOfIncomes.removeWhere((final Category k, final double v) => v <= 0.00);
    // Sort Descending
    mapOfIncomes = Map<Category, double>.fromEntries(mapOfIncomes.entries.toList()
      ..sort(
          (final MapEntry<Category, double> e1, final MapEntry<Category, double> e2) => (e2.value - e1.value).toInt()));

    mapOfIncomes.forEach((final Category key, final double value) {
      sanKeyListOfIncomes.add(SanKeyEntry()
        ..name = key.name.value
        ..value = value);
    });

    // Clean up the Expenses, drop 0.00
    mapOfExpenses.removeWhere((final Category k, final double v) => v == 0.00);

    // Sort Ascending, in the case of expenses that means the largest negative number to the least negative number
    mapOfExpenses = Map<Category, double>.fromEntries(mapOfExpenses.entries.toList()
      ..sort(
          (final MapEntry<Category, double> e1, final MapEntry<Category, double> e2) => (e1.value - e2.value).toInt()));

    mapOfExpenses.forEach((final Category key, final double value) {
      sanKeyListOfExpenses.add(SanKeyEntry()
        ..name = key.name.value
        ..value = value);
    });

    final double heightNeededToRenderIncomes = getHeightNeededToRender(sanKeyListOfIncomes);
    final double heightNeededToRenderExpenses = getHeightNeededToRender(sanKeyListOfExpenses);
    totalHeight = max(heightNeededToRenderIncomes, heightNeededToRenderExpenses);
  }

  @override
  Widget build(final BuildContext context) {
    return buildViewContent(
      Column(
        children: <Widget>[
          ViewHeader(
            title: 'Cash Flow',
            count: totalIncomes + totalExpenses,
            description: 'See where assets are allocated.',
          ),
          Expanded(child: getView()),
        ],
      ),
    );
  }

  Widget getView() {
    return LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: constraints.maxWidth,
          height: max(constraints.maxHeight, 1000),
          padding: const EdgeInsets.all(8),
          child: CustomPaint(
            painter: SankeyPainter(
              listOfIncomes: sanKeyListOfIncomes,
              listOfExpenses: sanKeyListOfExpenses,
              compactView: isSmallDevice(context),
              colors: SankeyColors(darkTheme: Settings().useDarkMode),
            ),
          ),
        ),
      );
    });
  }
}
