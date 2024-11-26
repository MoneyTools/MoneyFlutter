import 'package:get/get.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/widgets.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/transactions/list_view_transaction_splits.dart';

void showTransactionSplits(final Transaction transaction) {
  adaptiveScreenSizeDialog(
    context: Get.context!,
    title: 'Transaction split',
    child: IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(transaction.toString()),
          gapLarge(),
          SizedBox(
            height: 300,
            width: 800,
            child: ListViewTransactionSplits(getList: () => transaction.splits),
          ),
        ],
      ),
    ),
    actionButtons: [],
  );
}
