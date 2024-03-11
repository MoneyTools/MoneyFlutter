import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';

class DetailsPanelFields2<T> extends StatefulWidget {
  final MoneyObject instance;
  final Fields<T> detailPanelFields;

  /// Constructor
  const DetailsPanelFields2({
    super.key,
    required this.instance,
    required this.detailPanelFields,
  });

  @override
  State<DetailsPanelFields2> createState() => _DetailsPanelFields2State();
}

class _DetailsPanelFields2State extends State<DetailsPanelFields2> {
  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.detailPanelFields.getCellsForDetailsPanel(
        widget.instance,
        () {
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
