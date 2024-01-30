part of 'view_loans.dart';

extension ViewLoansDetailsPanels on ViewLoansState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart(final List<int> indices) {
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
    final LoanPayment? loan = getFirstElement<LoanPayment>(indices, list);

    if (loan != null) {
      final List<Transaction> list = getFilteredTransactions(
          (final Transaction transaction) => transaction.accountId.value == loan.accountId.value);

      return ListViewTransactions(
        key: Key(loan.id.toString()),
        columnsToInclude: const <String>[
          columnIdAccount,
          columnIdDate,
          columnIdPayee,
          columnIdCategory,
          columnIdMemo,
          columnIdAmount,
        ],
        getList: () => list,
      );
    }
    return const Text('No transactions');
  }
}
