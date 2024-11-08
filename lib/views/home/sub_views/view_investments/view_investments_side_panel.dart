part of 'view_investments.dart';

extension ViewInvestmentsSidePanel on ViewInvestmentsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    double balance = 0.00;

    var investments = getList();
    investments.sort((a, b) => sortByDate(a.date, b.date, true));

    List<FlSpot> dataPoints = [];
    if (investments.isEmpty) {
      return const CenterMessage(message: 'No data');
    }

    for (final Investment investment in investments) {
      balance += investment.activityAmount;
      dataPoints.add(
        FlSpot(
          investment.date.millisecondsSinceEpoch.toDouble(),
          balance,
        ),
      );
    }

    return MyLineChart(
      dataPoints: dataPoints,
      showDots: true,
    );
  }

  int _getAccountIdForInvestment(final int investmentTransactionId) {
    final Transaction? transactionFound = Data().transactions.get(investmentTransactionId);
    if (transactionFound != null) {
      return transactionFound.fieldAccountId.value;
    }
    return -1;
  }

  bool _isSameSecurityFromTheSameAccount(final Investment investment, final int securityId, int accountId) {
    if (investment.fieldSecurity.value != securityId) {
      return false;
    }
    if (_getAccountIdForInvestment(investment.uniqueId) != accountId) {
      return false;
    }
    return true;
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions({required final List<int> selectedIds, required bool showAsNativeCurrency}) {
    final Investment? instance = getMoneyObjectFromFirstSelectedId<Investment>(selectedIds, list);

    if (instance == null) {
      return CenterMessage.noTransaction();
    }

    // get the related Transaction in order to get the associated Account
    final listOfInvestmentIdForThisSecurityAndAccount = Data()
        .investments
        .iterableList()
        .where(
          (i) => _isSameSecurityFromTheSameAccount(
            i,
            instance.fieldSecurity.value,
            _getAccountIdForInvestment(instance.uniqueId),
          ),
        )
        .map((i) => i.uniqueId)
        .toList();

    final List<Transaction> listOfTransactions = getTransactions(
      filter: (final Transaction transaction) =>
          listOfInvestmentIdForThisSecurityAndAccount.contains(transaction.uniqueId),
    );
    final SelectionController selectionController = Get.put(SelectionController());
    return ListViewTransactions(
      key: Key(instance.uniqueId.toString()),
      listController: Get.find<ListControllerSidePanel>(),
      columnsToInclude: <Field>[
        Transaction.fields.getFieldByName(columnIdDate),
        Transaction.fields.getFieldByName(columnIdAccount),
        Transaction.fields.getFieldByName(columnIdPayee),
        Transaction.fields.getFieldByName(columnIdCategory),
        Transaction.fields.getFieldByName(columnIdMemo),
        Transaction.fields.getFieldByName(columnIdAmount),
      ],
      getList: () => listOfTransactions,
      selectionController: selectionController,
    );
  }
}
