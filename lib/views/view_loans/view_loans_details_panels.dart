part of 'view_loans.dart';

extension ViewLoansDetailsPanels on ViewLoansState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> list = <PairXY>[];
    // for (final Loan entry in getList()) {
    //   list.add(PairXY(entry.name, entry.profit));
    // }

    return Chart(
      list: list,
      variableNameHorizontal: 'Rental',
      variableNameVertical: 'Profit',
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final LoanPayment? loan = getMoneyObjectFromFirstSelectedId<LoanPayment>(indices, list);

    if (loan != null) {
      return ListViewTransactions(
        key: Key(loan.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdPayee),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
            filter: (final Transaction transaction) => transaction.accountId.value == loan.accountId.value),
      );
    }
    return CenterMessage.noTransaction();
  }
}
