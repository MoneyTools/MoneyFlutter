import 'package:flutter/material.dart';
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
  int _sortBy = 0; // 0=Date, 1=Memo, 2=Amount
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return buildWarning(context, 'No transactions');
    }
    ValuesQuality.sort(widget.values, _sortBy, _sortAscending);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildColumnHeaderButton(
              context,
              'Date',
              TextAlign.left,
              1,
              getSortIndicator(_sortBy, 0, _sortAscending),
              false,
              () => updateSortChoice(0),
              null,
            ),
            buildColumnHeaderButton(
              context,
              'Description/Payee',
              TextAlign.left,
              2,
              getSortIndicator(_sortBy, 1, _sortAscending),
              false,
              () => updateSortChoice(1),
              null,
            ),
            buildColumnHeaderButton(
              context,
              'Amount',
              TextAlign.right,
              1,
              getSortIndicator(_sortBy, 2, _sortAscending),
              false,
              () => updateSortChoice(2),
              null,
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemCount: widget.values.length,
            itemBuilder: (context, index) {
              final dateAsWidget = widget.values[index].date.valueAsDateWidget(context);
              final payeAsWidget = _buildDescriptionOrPayee(context, widget.values[index].description);
              final amountAsWidget = widget.values[index].amount.valueAsAmountWidget(context);

              return MyBanner(
                on: widget.values[index].exist,
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  // Date
                  Expanded(flex: 1, child: dateAsWidget),
                  // Description
                  Expanded(
                    flex: 2,
                    child: payeAsWidget,
                  ),
                  // Amount
                  Expanded(flex: 1, child: amountAsWidget),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  void updateSortChoice(final int sortBy) {
    setState(() {
      if (sortBy == _sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
      }
    });
  }

  Widget _buildDescriptionOrPayee(BuildContext context, ValueQuality valueQuality) {
    late Widget foundMatchingPayee;
    if (Data().payees.getByName(valueQuality.valueAsString) == null) {
      foundMatchingPayee = const SizedBox();
    } else {
      foundMatchingPayee = const Badge(
        label: Text("Payee Match"),
        backgroundColor: Colors.lightBlue,
        textColor: Colors.black,
      );
    }
    return Row(
      children: [
        Expanded(child: valueQuality.valueAsTextWidget(context)),
        foundMatchingPayee,
      ],
    );
  }
}
