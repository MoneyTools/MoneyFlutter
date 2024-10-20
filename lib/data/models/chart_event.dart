import 'package:money/core/widgets/widgets.dart';

class ChartEvent {
  ChartEvent({
    required this.date,
    required this.amount,
    required this.quantity,
    required this.description,
    required this.colorBasedOnQuantity,
    this.color,
  });

  final double amount;
  final Color? color;
  final bool colorBasedOnQuantity;
  final DateTime date;
  final String description;
  final double quantity;

  Color get colorToUse {
    if (this.color == null) {
      return colorBasedOnQuantity
          ? (quantity == 0 ? Colors.grey : (isBuy ? Colors.orange : Colors.blue))
          : (amount == 0 ? Colors.grey : (amount.isNegative ? Colors.orange : Colors.blue));
    }
    return this.color!;
  }

  bool get isBuy => quantity > 0;

  bool get isSell => quantity < 0;
}
