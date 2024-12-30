import 'package:money/core/widgets/picker_edit_box.dart';
import 'package:money/views/home/sub_views/view_stocks/picker_security_type.dart';

enum InvestmentTradeType {
  none, // 0
  buy, // 1
  buyToOpen, // 2
  buyToCover, // 3,
  buyToClose, // 4,
  sell, // 5
  sellShort, // 6
}

String getInvestmentTradeTypeText(final InvestmentTradeType type) {
  return type.name.toUpperCase();
}

String getInvestmentTradeTypeTextFromValue(final int value) {
  return getInvestmentTradeTypeText(getInvestmentTradeTypeFromValue(value));
}

InvestmentTradeType getInvestmentTradeTypeFromValue(final int value) {
  return InvestmentTradeType.values[value];
}

InvestmentTradeType getInvestmentTradeTypeFromText(final String name) {
  return InvestmentTradeType.values.byName(name);
}

List<String> getInvestmentTradeTypeNames() {
  return InvestmentTradeType.values.map((item) => item.toString().split('.').last).toList();
}

InvestmentTradeType fromInvestmentType(final InvestmentType type) {
  switch (type) {
    case InvestmentType.buy:
    case InvestmentType.add:
      return InvestmentTradeType.buy;
    case InvestmentType.sell:
    case InvestmentType.remove:
      return InvestmentTradeType.sell;
    case InvestmentType.dividend:
    case InvestmentType.none:
      return InvestmentTradeType.none;
  }
}

Widget pickerInvestmentTradeType({
  required final InvestmentTradeType itemSelected,
  required final Function(InvestmentTradeType) onSelected,
}) {
  String selectedName = getInvestmentTradeTypeText(itemSelected);

  return PickerEditBox(
    title: 'Investment Trade Type',
    items: getInvestmentTradeTypeNames(),
    initialValue: selectedName,
    onChanged: (String newSelection) {
      onSelected(getInvestmentTradeTypeFromText(newSelection));
    },
  );
}
