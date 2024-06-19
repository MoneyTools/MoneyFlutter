import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/value_parser.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/columns/column_header_button.dart';
import 'package:money/widgets/semantic_text.dart';
import 'package:money/widgets/mybanner.dart';

class ImportTransactionsList extends StatefulWidget {
  final List<ValuesQuality> values;

  const ImportTransactionsList({super.key, required this.values});

  @override
  State<ImportTransactionsList> createState() => _ImportTransactionsListState();
}

class _ImportTransactionsListState extends State<ImportTransactionsList> {
  int _sortColumnIndex = 0; // 0=Date, 1=Memo, 2=Amount
  bool _sortAscending = false;
  late final List<Triple<String, TextAlign, int>> _columnNames = [
    Triple<String, TextAlign, int>('Date', TextAlign.left, 1),
    Triple<String, TextAlign, int>('Description/Payee', TextAlign.left, 2),
    Triple<String, TextAlign, int>('Amount', TextAlign.right, 1),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return buildWarning(context, 'No transactions');
    }

    _sortValues();

    return Column(
      children: [
        _buildColumnHeaders(context),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: widget.values.length,
            itemBuilder: (context, index) => _buildTransactionRow(widget.values[index]),
          ),
        ),
      ],
    );
  }

  void _sortValues() {
    ValuesQuality.sort(widget.values, _sortColumnIndex, _sortAscending);
  }

  Widget _buildColumnHeaders(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        _columnNames.length,
        (index) => buildColumnHeaderButton(
          context: context,
          text: _columnNames[index].first,
          textAlign: _columnNames[index].second,
          flex: _columnNames[index].third,
          sortIndicator: getSortIndicator(_sortColumnIndex, index, _sortAscending),
          hasFilters: false,
          onPressed: () => _updateSortChoice(index),
          onLongPress: null,
        ),
      ),
    );
  }

  void _updateSortChoice(int columnIndex) {
    setState(() {
      if (columnIndex == _sortColumnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
      }
      _sortValues();
    });
  }

  Widget _buildTransactionRow(ValuesQuality value) {
    final dateAsWidget = value.date.valueAsDateWidget(context);
    final payeAsWidget = _buildDescriptionOrPayee(context, value.description);
    final amountAsWidget = value.amount.valueAsAmountWidget(context);

    return MyBanner(
      on: value.exist,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: dateAsWidget),
          Expanded(flex: 2, child: payeAsWidget),
          Expanded(flex: 1, child: amountAsWidget),
        ],
      ),
    );
  }

  Widget _buildDescriptionOrPayee(BuildContext context, ValueQuality valueQuality) {
    final payeeName = valueQuality.valueAsString;
    final payeeMatch = Data().payees.getByName(payeeName) != null;

    return Row(
      children: [
        Expanded(child: valueQuality.valueAsTextWidget(context)),
        if (payeeMatch)
          const Badge(
            label: Text("Payee Match"),
            backgroundColor: Colors.lightBlue,
            textColor: Colors.black,
          ),
      ],
    );
  }
}
