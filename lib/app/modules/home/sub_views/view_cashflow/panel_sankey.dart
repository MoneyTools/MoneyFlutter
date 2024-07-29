// ignore_for_file: unnecessary_this

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/theme_controler.dart';
import 'package:money/app/core/widgets/sankey/sankey.dart';
import 'package:money/app/core/widgets/sankey/sankey_colors.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

// ignore: must_be_immutable
class PanelSanKey extends StatelessWidget {
  PanelSanKey({required this.minYear, required this.maxYear, super.key});

  final int maxYear;
  final int minYear;

  late Map<Category, double> mapOfExpenses = <Category, double>{};
  late Map<Category, double> mapOfIncomes = <Category, double>{};
  late double padding = 10.0;
  late List<SanKeyEntry> sanKeyListOfExpenses = <SanKeyEntry>[];
  late List<SanKeyEntry> sanKeyListOfIncomes = <SanKeyEntry>[];
  late double totalExpenses = 0.00;
  late double totalHeight = 0.0;
  late double totalIncomes = 0.00;
  late double totalInvestments = 0.00;
  late double totalNones = 0.00;
  late double totalSavings = 0.00;

  @override
  Widget build(final BuildContext context) {
    transformData();
    final ThemeController themeController = Get.find();
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
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
                colors: SankeyColors(darkTheme: themeController.isDarkTheme.value),
              ),
            ),
          ),
        );
      },
    );
  }

  void transformData() {
    final transactions = Data().transactions.transactionInYearRange(
          minYear: minYear,
          maxYear: maxYear,
          incomesOrExpenses: null,
        );

    for (Transaction element in transactions) {
      final Category? category = Data().categories.get(element.fieldCategoryId.value);
      if (category != null) {
        switch (category.fieldType.value) {
          case CategoryType.income:
          case CategoryType.saving:
          case CategoryType.investment:
            totalIncomes += element.fieldAmount.value.toDouble();

            final Category topCategory = Data().categories.getTopAncestor(category);
            double? mapValue = mapOfIncomes[topCategory];
            mapValue ??= 0;
            mapOfIncomes[topCategory] = mapValue + element.fieldAmount.value.toDouble();
            break;
          case CategoryType.expense:
          case CategoryType.recurringExpense:
            totalExpenses += element.fieldAmount.value.toDouble();
            final Category topCategory = Data().categories.getTopAncestor(category);
            double? mapValue = mapOfExpenses[topCategory];
            mapValue ??= 0;
            mapOfExpenses[topCategory] = mapValue + element.fieldAmount.value.toDouble();
            break;
          default:
            totalNones += element.fieldAmount.value.toDouble();
            break;
        }
      }
    }

    // Clean up the Incomes, drop 0.00
    mapOfIncomes.removeWhere((final Category k, final double v) => v <= 0.00);
    // Sort Descending
    mapOfIncomes = Map<Category, double>.fromEntries(
      mapOfIncomes.entries.toList()
        ..sort(
          (
            final MapEntry<Category, double> e1,
            final MapEntry<Category, double> e2,
          ) =>
              (e2.value - e1.value).toInt(),
        ),
    );

    mapOfIncomes.forEach((final Category key, final double value) {
      sanKeyListOfIncomes.add(
        SanKeyEntry()
          ..name = key.fieldName.value
          ..value = value,
      );
    });

    // Clean up the Expenses, drop 0.00
    mapOfExpenses.removeWhere((final Category k, final double v) => v == 0.00);

    // Sort Ascending, in the case of expenses that means the largest negative number to the least negative number
    mapOfExpenses = Map<Category, double>.fromEntries(
      mapOfExpenses.entries.toList()
        ..sort(
          (
            final MapEntry<Category, double> e1,
            final MapEntry<Category, double> e2,
          ) =>
              (e1.value - e2.value).toInt(),
        ),
    );

    mapOfExpenses.forEach((final Category key, final double value) {
      sanKeyListOfExpenses.add(
        SanKeyEntry()
          ..name = key.fieldName.value
          ..value = value,
      );
    });

    final double heightNeededToRenderIncomes = getHeightNeededToRender(sanKeyListOfIncomes);
    final double heightNeededToRenderExpenses = getHeightNeededToRender(sanKeyListOfExpenses);
    totalHeight = max(heightNeededToRenderIncomes, heightNeededToRenderExpenses);
  }
}
