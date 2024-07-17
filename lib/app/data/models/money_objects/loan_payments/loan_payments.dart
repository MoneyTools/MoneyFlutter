import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payment.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

// Export
export 'package:money/app/data/models/money_objects/loan_payments/loan_payment.dart';

class LoanPayments extends MoneyObjects<LoanPayment> {
  LoanPayments() {
    collectionName = 'LoanPayments';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(LoanPayment.fromJson(row));
    }
  }

  @override
  void onAllDataLoaded() {}

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}

class PaymentRollup {
  int accountId = -1;
  late DateTime date;
  double interest = 0;
  double principal = 0;
  String reference = '';
}

List<LoanPayment> getAccountLoanPayments(Account account) {
  final List<int> categoriesToMatch = [
    account.categoryIdForInterest.value,
    account.categoryIdForPrincipal.value,
  ];

  // include the manual entries done in the LoanPayments table
  List<LoanPayment> aggregatedList = Data()
      .loanPayments
      .iterableList(includeDeleted: false)
      .where((a) => a.accountId.value == account.uniqueId)
      .toList();

  // include the bank transactions matching the Account Categories for Principal and Interest
  final List<Transaction> listOfTransactions = Data().transactions.getListFlattenSplits(
        whereClause: (t) => t.isMatchingAnyOfTheseCategoris(categoriesToMatch),
      );

  // Rollup into a single Payment based on Date to match Principal and Interest payment
  Map<String, PaymentRollup> payments = {};

  for (final t in listOfTransactions) {
    // Key is based on date
    String key = '${t.dateTimeAsText} ${t.uniqueId}';
    PaymentRollup? pr = payments[key];

    bool isFromSplit = false;
    if (pr == null) {
      pr = PaymentRollup();
      pr.accountId = t.accountId.value;
      payments[key] = pr;
    } else {
      isFromSplit = true;
    }

    // Date
    pr.date = t.dateTime.value!;

    // Reference (combination of Memo and Payee)
    pr.reference = concat(pr.reference, t.memo.value, ';', true);
    if (isFromSplit) {
      pr.reference = concat(pr.reference, '<Split>', ';', true);
    }
    pr.reference = concat(pr.reference, t.getPayeeOrTransferCaption(), ';', true);

    // Principal
    if (t.categoryId.value == account.categoryIdForPrincipal.value) {
      pr.principal = t.amount.value.toDouble();
    }

    // Interest
    if (t.categoryId.value == account.categoryIdForInterest.value) {
      pr.interest = t.amount.value.toDouble();
    }
  }

  int fakeId = 10000000;

  for (final pr in payments.values) {
    aggregatedList.add(
      LoanPayment(
        id: fakeId++,
        accountId: pr.accountId,
        date: pr.date,
        interest: pr.interest,
        principal: pr.principal,
        memo: '',
        reference: pr.reference,
      ),
    );
  }

  aggregatedList.sort((a, b) => sortByDate(a.date.value, b.date.value, true));

  double runningBalance = 0.00;

  for (final p in aggregatedList) {
    runningBalance += p.principal.value.toDouble();
    p.balance.value.setAmount(runningBalance);

    // Special hack to include the Manual LoanPayment memo into th reference text
    p.reference.value = concat(p.memo.value, p.reference.value);
  }
  return aggregatedList;
}
