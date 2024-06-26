import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payment.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
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
  void loadDemoData() {
    clear();
    final Account? accountForLoan = Data().accounts.iterableList().firstWhereOrNull(
          (final Account element) => element.type.value == AccountType.loan,
        );
    if (accountForLoan != null) {
      for (int i = 0; i < 12 * 20; i++) {
        appendNewMoneyObject(
          LoanPayment(
            id: -1,
            accountId: accountForLoan.id.value,
            date: DateTime.now(),
            principal: 100,
            interest: 10,
            memo: '',
          ),
        );
      }
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
  late DateTime date;
  int accountId = -1;
  String reference = '';
  double principal = 0;
  double interest = 0;
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

  // include the bank transactions matching th Account Categories for Principal and Interest
  var listOfTransactions = Data().transactions.getListFlattenSplits(
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
    pr.reference = concat(pr.reference, t.payeeOrTransferCaption, ';', true);

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
