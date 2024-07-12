part of 'view_investments.dart';

extension ViewInvestmentsDetailsPanels on ViewInvestmentsState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> list = <PairXY>[];
    for (final Investment entry in getList()) {
      list.add(
        PairXY(entry.security.value.toString(), entry.originalCostBasis),
      );
    }

    return Chart(
      list: list,
      variableNameHorizontal: 'Stock',
      variableNameVertical: 'value',
    );
  }

  int _getAccountIdForInvestment(final int investmentTransactionId) {
    final Transaction? transactionFound = Data().transactions.get(investmentTransactionId);
    if (transactionFound != null) {
      debugLog(
        '${transactionFound.accountId.value}  ${transactionFound.accountInstance!.name.value} ${transactionFound.amountAsText}',
      );
      return transactionFound.accountId.value;
    }
    return -1;
  }

  bool _isSameSecurityFromTheSameAccount(final Investment investment, final int securityId, int accountId) {
    if (investment.security.value != securityId) {
      return false;
    }
    if (_getAccountIdForInvestment(investment.uniqueId) != accountId) {
      return false;
    }
    return true;
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Investment? instance = getMoneyObjectFromFirstSelectedId<Investment>(indices, list);
    if (instance != null) {
      // get the related Transaction in order to get the associated Account
      final listOfInvestmentIdForThisSecurityAndAccount = Data()
          .investments
          .iterableList()
          .where(
            (i) => _isSameSecurityFromTheSameAccount(
              i,
              instance.security.value,
              _getAccountIdForInvestment(instance.uniqueId),
            ),
          )
          .map((i) => i.uniqueId)
          .toList();

      final List<Transaction> list = getTransactions(
        filter: (final Transaction transaction) =>
            listOfInvestmentIdForThisSecurityAndAccount.contains(transaction.uniqueId),
      );
      final SelectionController selectionController = Get.put(SelectionController());
      return ListViewTransactions(
        key: Key(instance.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdPayee),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => list,
        selectionController: selectionController,
      );
    }
    return CenterMessage.noTransaction();
  }
}
