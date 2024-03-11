import 'package:flutter/material.dart';
import 'package:money/models/value_parser.dart';
import 'package:money/widgets/semantic_text.dart';

class ImportTransactionsList extends StatelessWidget {
  final List<ValuesQuality> values;

  const ImportTransactionsList({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return buildWarning(context, 'No transactions');
    }
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date', textAlign: TextAlign.center),
              Text('Description', textAlign: TextAlign.center),
              Text('Amount', textAlign: TextAlign.center)
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: values.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        SizedBox(width: 100, child: values[index].date.valueAsDateWidget(context)),
                        // Date
                        Expanded(
                          child: values[index].description.valueAsTextWidget(context),
                        ),
                        // Description
                        SizedBox(width: 100, child: values[index].amount.valueAsAmountWidget(context)),
                        // Amount
                      ]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
