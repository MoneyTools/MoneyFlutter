import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';

class DetailsPanelFields<T> extends StatefulWidget {
  final MoneyObject instance;
  final Fields<T> detailPanelFields;
  final bool isReadOnly;

  /// Constructor
  const DetailsPanelFields({
    super.key,
    required this.instance,
    required this.detailPanelFields,
    required this.isReadOnly,
  });

  @override
  State<DetailsPanelFields> createState() => DetailsPanelFieldsState();
}

class DetailsPanelFieldsState extends State<DetailsPanelFields> {
  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.detailPanelFields.getCellsForDetailsPanel(
        widget.instance,
        widget.isReadOnly
            ? null
            : () {
                setState(
                  () {
                    /// update panel
                    Data().notifyTransactionChange(
                      MutationType.changed,
                      widget.instance,
                    );
                  },
                );
              },
      ),
    );
  }
}
