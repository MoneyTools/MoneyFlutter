part of 'view_payees.dart';

extension ViewPayeesDetailsPanels on ViewPayeesState {
  /// Details panels Chart panel for Payees
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    if (selectedIds.isEmpty) {
      final List<PairXY> list = <PairXY>[];
      for (final Payee item in getList()) {
        if (item.name.value != 'Transfer') {
          list.add(PairXY(item.name.value, item.count.value));
        }
      }

      list.sort((final PairXY a, final PairXY b) {
        return (b.yValue.abs() - a.yValue.abs()).toInt();
      });

      return Chart(
        key: Key(selectedIds.toString()),
        list: list.take(10).toList(),
        variableNameHorizontal: 'Payee',
        variableNameVertical: 'Transactions',
      );
    }

    final List<Transaction> flatTransactions = Transactions.flatTransactions(
      Data().transactions.iterableList().where((t) => t.payee.value == selectedIds.first),
    );

    if (flatTransactions.isEmpty) {
      return const Center(child: Text('No transactions'));
    }

    final DateRange dateRange = DateRange();
    for (final t in flatTransactions) {
      dateRange.inflate(t.dateTime.value);
    }

    double maxValue = 0;
    final List<Pair<int, double>> sumByDays = Transactions.transactionSumByTime(flatTransactions);
    for (final pair in sumByDays) {
      maxValue = max(maxValue, pair.second.abs());
    }

    // Transaction graph of the selected Payee
    final int yearStart = dateRange.min!.year;
    final int yearEnd = dateRange.max!.year;
    final borderColor = getColorTheme(context).onSecondaryContainer.withOpacity(0.3);
    final TextStyle textStyle = getTextTheme(context).labelSmall!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(getAmountAsShorthandText(maxValue), style: textStyle),
                  Text(
                    getAmountAsShorthandText(maxValue / 2),
                    style: textStyle,
                  ),
                  Text('0.00', style: textStyle),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: borderColor,
                            width: 1.0,
                          ),
                          bottom: BorderSide(
                            color: borderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: MiniTimelineDaily(
                        offsetStartingDay: sumByDays.first.first,
                        yearStart: yearStart,
                        yearEnd: yearEnd,
                        values: sumByDays,
                        lineWidth: 3,
                      ),
                    ),
                  ),
                  gapMedium(),
                  DateRangeTimeline(
                    startDate: dateRange.min!,
                    endDate: dateRange.max!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Details Panel for Transactions Payees
  Widget _getSubViewContentForTransactions(final List<int> indices) {
    final Payee? payee = getMoneyObjectFromFirstSelectedId<Payee>(indices, list);
    if (payee != null && payee.id.value > -1) {
      final SelectionController selectionController = Get.put(SelectionController());
      return ListViewTransactions(
        key: Key(payee.uniqueId.toString()),
        columnsToInclude: <Field>[
          Transaction.fields.getFieldByName(columnIdDate),
          Transaction.fields.getFieldByName(columnIdAccount),
          Transaction.fields.getFieldByName(columnIdCategory),
          Transaction.fields.getFieldByName(columnIdMemo),
          Transaction.fields.getFieldByName(columnIdAmount),
        ],
        getList: () => getTransactions(
          filter: (final Transaction transaction) => transaction.payee.value == payee.id.value,
        ),
        selectionController: selectionController,
      );
    }
    return CenterMessage.noTransaction();
  }
}
