import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/confirmation_dialog.dart';
import 'package:money/app/core/widgets/import_transactions_list_preview.dart';
import 'package:money/app/core/widgets/picker_panel.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/import/import_transactions_from_text.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/picker_security_type.dart';

class ImportData {
  List<ImporEntry> entries = [];
  String fileType = '';

  Account? account;
  AccountType? accountType;
}

class ImporEntry {
  ImporEntry({
    required this.type,
    required this.date,
    required this.amount,
    required this.name,
    required this.fitid,
    this.memo = '',
    this.number = '',
    this.stockAction = '',
    this.stockSymbol = '',
    this.stockQuantity = 0.00,
    this.stockPrice = 0.00,
    this.stockCommision = 0.00,
  });

  factory ImporEntry.blank() {
    return ImporEntry(
      type: '',
      date: DateTime.now(),
      amount: 0.00,
      name: '',
      fitid: '',
      stockAction: '',
      stockSymbol: '',
    );
  }

  late double amount;
  late DateTime date;
  late String fitid;
  late String memo;
  late String name;
  late String number;
  late String stockAction;
  late double stockCommision;
  late double stockPrice;
  late double stockQuantity;
  late String stockSymbol;
  late String type;

  /// when there's no 'name' then fallback to 'memo'
  String getDescription() {
    if (name.isNotEmpty) {
      return name;
    }
    if (memo.isNotEmpty) {
      return memo;
    }
    return '$stockSymbol $stockAction ${formatDoubleTrimZeros(stockQuantity)} x ${stockPrice.toString()}';
  }
}

void showAndConfirmTransactionToImport(
  final BuildContext context,
  final ImportData importData,
) {
  if (importData.account == null) {
    final List<String> activeAccountNames =
        Data().accounts.getListSorted().map((element) => element.name.value).toList();

    showPopupSelection(
      title: 'Pick account to import to',
      context: context,
      items: activeAccountNames,
      selectedItem: '',
      onSelected: (final String text) {
        final Account? accountSelected = Data().accounts.getByName(text);
        if (accountSelected != null) {
          _showAndConfirmTransactionToImport(context, importData.fileType, importData.entries, accountSelected);
        } else {
          SnackBarService.displayWarning(
            autoDismiss: false,
            message:
                'Import - No matching "${importData.fileType}" accounts with ID "${importData.account?.uniqueId.toString() ?? '-1'}"',
          );
          return false;
        }
      },
    );
  } else {
    _showAndConfirmTransactionToImport(context, importData.fileType, importData.entries, importData.account!);
  }
}

void _showAndConfirmTransactionToImport(
  final BuildContext context,
  final String fileType,
  final List<ImporEntry> list,
  final Account account,
) {
  final List<ValuesQuality> valuesQuality = [];

  // attempt to find or add new transactions
  for (final ImporEntry item in list) {
    valuesQuality.add(
      ValuesQuality(
        date: ValueQuality(dateToString(item.date), dateFormat: 'yyyy-MM-dd'),
        // final int payeeIdMatchingPayeeText = Data().aliases.getPayeeIdFromTextMatchingOrAdd(payeeText, fireNotification: false);
        description: ValueQuality(item.getDescription()),
        amount: ValueQuality(item.amount.toString()),
      ),
    );
  }

  String messageToUser =
      '${list.length} transactions found in $fileType file, to be imported into "${account.name.value}"';

  Widget questionContent = SizedBox(
    height: 400,
    child: Center(
      child: ImportTransactionsListPreview(
        accountId: account.uniqueId,
        values: valuesQuality,
      ),
    ),
  );

  showConfirmationDialog(
    context: context,
    title: 'Import QFX',
    question: messageToUser,
    content: questionContent,
    buttonText: 'Import',
    onConfirmation: () {
      final List<Transaction> transactionsToAdd = [];
      for (final ValuesQuality singleTransactionInput in valuesQuality) {
        if (!singleTransactionInput.exist) {
          final t = createNewTransactionFromDateDescriptionAmount(
            account,
            singleTransactionInput.date.asDate() ?? DateTime.now(),
            singleTransactionInput.description.asString(),
            singleTransactionInput.amount.asAmount(),
          );
          transactionsToAdd.add(t);
        }
      }
      addNewTransactions(
        transactionsToAdd,
        'Imported - ${transactionsToAdd.length} transactions into "${account.name.value}"',
      );
    },
  );
}
