import 'package:money/app/data/models/money_objects/currencies/currency.dart';

class RentalPnL {
  RentalPnL({
    required this.date,
    this.income = 0,
    this.expenseInterest = 0,
    this.expenseMaintenance = 0,
    this.expenseManagement = 0,
    this.expenseRepairs = 0,
    this.expenseTaxes = 0,
    this.currency = 'USD',
    Map<String, double>? distributions,
  }) {
    this.distributions = distributions ?? {};
  }
  final DateTime date;
  double income;
  double expenseInterest;
  double expenseMaintenance;
  double expenseManagement;
  double expenseRepairs;
  double expenseTaxes;
  String currency;
  late Map<String, double> distributions;

  double get expenses => expenseInterest + expenseMaintenance + expenseManagement + expenseRepairs + expenseTaxes;

  double get profit => income + expenses; // since Expense is stored as a negative value we use a [+]

  @override
  String toString() {
    String text = textAmount('Income', income) +
        textAmount('Expenses', expenses) +
        textAmount('  Interest', expenseInterest) +
        textAmount('  Maintenance', expenseMaintenance) +
        textAmount('  Management', expenseManagement) +
        textAmount('  Repairs', expenseRepairs) +
        textAmount('  Taxes', expenseTaxes) +
        textAmount('Profit', profit);

    text += appendDistribution();

    return text;
  }

  String textAmount(final String text, final double amount) {
    String textPadded = '$text:'.padRight(15);
    String amountPadded = Currency.getAmountAsStringUsingCurrency(amount, iso4217code: currency).padLeft(15);
    return '$textPadded\t$amountPadded\n';
  }

  String appendDistribution() {
    String text = '';

    distributions.forEach((name, percentage) {
      if (name.isNotEmpty) {
        text += textAmount(name, profit * (percentage / 100));
      }
    });
    return text;
  }
}
