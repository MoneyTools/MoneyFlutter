import 'package:flutter/material.dart';
import 'package:money/core/controller/keyboard_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/date_helper.dart';
import 'package:money/core/widgets/form_field_widget.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/my_text_input.dart';
import 'package:money/core/widgets/picker_edit_box_date.dart';
import 'package:money/data/models/money_objects/accounts/account.dart';
import 'package:money/data/models/money_objects/investments/investment_types.dart';
import 'package:money/data/models/money_objects/investments/picker_investment_type.dart';

class InvestmentImportFields {
  InvestmentImportFields({
    required this.account,
    required this.date,
    required this.investmentType,
    required this.symbol,
    required this.units,
    required this.amountPerUnit,
    required this.transactionAmount,
    required this.description,
  });

  Account account;
  double amountPerUnit;
  DateTime date;
  String description;
  InvestmentType investmentType;
  String symbol;
  double transactionAmount;
  double units;
}

/// use for free style text to transaction import
class ImportInvestmentPanel extends StatefulWidget {
  const ImportInvestmentPanel({
    super.key,
    required this.inputFields,
  });

  final InvestmentImportFields inputFields;

  @override
  ImportInvestmentPanelState createState() => ImportInvestmentPanelState();
}

class ImportInvestmentPanelState extends State<ImportInvestmentPanel> {
  late final _controllerAmount = TextEditingController(text: widget.inputFields.amountPerUnit.toString());
  late final _controllerDescription = TextEditingController(text: widget.inputFields.description.toString());
  late final _controllerSymbol = TextEditingController(text: widget.inputFields.symbol.toString());
  late final _controllerTransactionAmount =
      TextEditingController(text: widget.inputFields.transactionAmount.toString());

  late final _controllerUnites = TextEditingController(text: widget.inputFields.units.toString());
  final _focusNode = FocusNode();
  final _keyboardHandler = SafeKeyboardHandler();

  late DateTime _date = widget.inputFields.date;

  @override
  void dispose() {
    _controllerSymbol.dispose();
    _controllerUnites.dispose();
    _controllerAmount.dispose();
    _controllerTransactionAmount.dispose();
    _controllerDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerSymbol.addListener(_updateInputFields);
    _controllerUnites.addListener(_updateInputFields);
    _controllerAmount.addListener(_updateInputFields);
    _controllerTransactionAmount.addListener(_updateInputFields);
    _controllerDescription.addListener(_updateInputFields);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (final bool hasFocus) {
        if (!hasFocus) {
          _keyboardHandler.clearKeys();
        }
      },
      child: KeyboardListener(
        onKeyEvent: _keyboardHandler.onKeyEvent,
        focusNode: _focusNode,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 24,
              children: [
                // Title
                Text(
                  'Add investment to account',
                  style: getTextTheme(context).bodyLarge,
                ),

                // Account
                Text(
                  widget.inputFields.account.fieldName.value,
                  style: getTextTheme(context).titleLarge,
                ),
                gapMedium(),

                // Date
                myFormField(
                  title: 'Date',
                  child: PickerEditBoxDate(
                    initialValue: dateToString(_date),
                    onChanged: (String? newDateSelected) {
                      if (newDateSelected != null) {
                        _date = attemptToGetDateFromText(newDateSelected) ?? DateTime.now();
                      }
                    },
                  ),
                ),
                // Investment Type
                myFormField(
                  title: 'Investment Type',
                  child: pickerInvestmentType(
                    itemSelected: widget.inputFields.investmentType,
                    onSelected: (final InvestmentType newSelection) {
                      widget.inputFields.investmentType = newSelection;
                    },
                  ),
                ),

                // Symbol
                MyTextInput(
                  hintText: 'Symbol',
                  controller: _controllerSymbol,
                ),

                // Units
                MyTextInput(
                  hintText: 'Units',
                  controller: _controllerUnites,
                ),

                // Amount per unit
                MyTextInput(
                  hintText: 'Amount per unit',
                  controller: _controllerAmount,
                ),

                // Transaction Amount
                MyTextInput(
                  hintText: 'Total Transaction Amount',
                  controller: _controllerTransactionAmount,
                ),

                // Description
                MyTextInput(
                  hintText: 'Description',
                  controller: _controllerDescription,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void removeFocus() {
    _focusNode.unfocus();
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _updateInputFields() {
    widget.inputFields.date = _date;
    widget.inputFields.symbol = _controllerSymbol.text;
    widget.inputFields.units = double.tryParse(_controllerUnites.text) ?? 0.0;
    widget.inputFields.amountPerUnit = double.tryParse(_controllerAmount.text) ?? 0.0;
    widget.inputFields.transactionAmount = double.tryParse(_controllerTransactionAmount.text) ?? 0.0;
    widget.inputFields.description = _controllerDescription.text;
  }
}
