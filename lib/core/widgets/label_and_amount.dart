import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/core/widgets/quantity_widget.dart';
import 'package:money/data/models/money_model.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_selection.dart';
import 'package:money/views/home/sub_views/view_stocks/picker_security_type.dart';

class LabelAndAmount extends StatelessWidget {
  const LabelAndAmount({
    super.key,
    required this.caption,
    required this.amount,
    this.currencyIso4217 = Constants.defaultCurrency,
    this.small = false,
  });

  final double amount;
  final String caption;
  final String currencyIso4217;
  final bool small;

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            style: small ? getTextTheme(context).bodySmall : getTextTheme(context).bodyMedium,
          ),
        ),
        MoneyWidget(
          amountModel: MoneyModel(
            amount: amount,
            iso4217: currencyIso4217,
            showCurrency: false,
            autoColor: true,
          ),
        ),
      ],
    );
  }
}

class LabelAndQuantity extends StatelessWidget {
  const LabelAndQuantity({
    super.key,
    required this.caption,
    required this.quantity,
    this.small = false,
  });

  final String caption;
  final double quantity;
  final bool small;

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            style: small ? getTextTheme(context).bodySmall : getTextTheme(context).bodyMedium,
          ),
        ),
        QuantityWidget(
          quantity: quantity,
          align: TextAlign.right,
        ),
      ],
    );
  }
}
