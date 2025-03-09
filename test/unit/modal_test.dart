import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/data/models/money_objects/categories/categories.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/storage/data/data.dart';

void main() {
  setUp(() {
    // ignore: unused_local_variable
    final DataController dataController = Get.put(DataController());
  });

  test('Category', () {
    final Categories categories = Data().categories;
    expect(
      categories.interestEarned.getTypeAsText(),
      Category.getTextFromType(CategoryType.income),
    );
    expect(
      categories.salesTax.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.salesTax.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.savings.getTypeAsText(),
      Category.getTextFromType(CategoryType.income),
    );
    expect(
      categories.transferFromDeletedAccount.getTypeAsText(),
      Category.getTextFromType(CategoryType.none),
    );
    expect(
      categories.transferToDeletedAccount.getTypeAsText(),
      Category.getTextFromType(CategoryType.none),
    );
    expect(
      categories.unassignedSplit.getTypeAsText(),
      Category.getTextFromType(CategoryType.none),
    );
    expect(
      categories.unknown.getTypeAsText(),
      Category.getTextFromType(CategoryType.none),
    );

    // standard categories for investments
    expect(
      categories.investmentBonds.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentCredit.getTypeAsText(),
      Category.getTextFromType(CategoryType.income),
    );
    expect(
      categories.investmentDebit.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentDividends.getTypeAsText(),
      Category.getTextFromType(CategoryType.income),
    );
    expect(
      categories.investmentFees.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentInterest.getTypeAsText(),
      Category.getTextFromType(CategoryType.income),
    );
    expect(
      categories.investmentLongTermCapitalGainsDistribution.getTypeAsText(),
      Category.getTextFromType(CategoryType.income),
    );
    expect(
      categories.investmentMiscellaneous.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentOptions.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentOther.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentReinvest.getTypeAsText(),
      Category.getTextFromType(CategoryType.none),
    );
    expect(
      categories.investmentStocks.getTypeAsText(),
      Category.getTextFromType(CategoryType.expense),
    );
    expect(
      categories.investmentTransfer.getTypeAsText(),
      Category.getTextFromType(CategoryType.none),
    );
  });
}
