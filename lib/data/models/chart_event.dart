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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ChartEvent) {
      return false;
    }

    return date == other.date &&
        amount == other.amount &&
        quantity == other.quantity &&
        description == other.description;
  }

  @override
  int get hashCode => Object.hash(date, amount, quantity, description);

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
