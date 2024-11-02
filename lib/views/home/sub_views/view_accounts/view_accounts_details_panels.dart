part of 'view_accounts.dart';

extension ViewAccountsDetailsPanels on ViewAccountsState {
  Widget _getInfoPanelViewDetails({
    required final List<int> selectedIds,
    required final bool isReadOnly,
  }) {
    final Account? selectedAccount = getFirstSelectedItem() as Account?;
    if (selectedAccount == null) {
      return const CenterMessage(message: 'No item selected.');
    }

    if (selectedAccount.isInvestmentAccount()) {
      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(SizeForPadding.large),
              child: MoneyObjectCard(
                title: getClassNameSingular(),
                moneyObject: selectedAccount,
              ),
            ),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 10,
                spacing: 10,
                children: _buildStockHoldingCards(selectedAccount),
              ),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Center(
          child: MoneyObjectCard(
            title: getClassNameSingular(),
            moneyObject: selectedAccount,
          ),
        ),
      );
    }
  }

  List<Widget> _buildStockHoldingCards(final Account account) {
    AccumulatorList<String, Investment> groupBySymbol = AccumulatorList<String, Investment>();
    Accounts.groupAccountStockSymbols(account, groupBySymbol);

    if (groupBySymbol.getKeys().isEmpty) {
      return [];
    }

    List<StockSummary> stockSummaries = [];

    groupBySymbol.values.forEach((String key, dynamic listOfInvestmentsForAccount) {
      final double sharesForThisStock = Investments.applyHoldingSharesAdjustedForSplits(
        listOfInvestmentsForAccount.toList(),
      );

      if (isConsideredZero(sharesForThisStock) == false) {
        //  "123|MSFT" >> "MSFT"
        final symbol = key.split('|')[1];

        final Security? stock = Data().securities.getBySymbol(symbol);
        double stockPrice = 1.00;

        if (stock != null) {
          stockPrice = stock.fieldPrice.value.toDouble();
        }

        stockSummaries.add(StockSummary(symbol: symbol, shares: sharesForThisStock, sharePrice: stockPrice));
      }
    });

    // sort by descending holding-value
    stockSummaries.sort((a, b) => b.holdingValue.compareTo(a.holdingValue));

    const cardHeight = 150.0;
    final List<Widget> stockPanels = stockSummaries
        .map(
          (summary) => BoxWithScrollingContent(
            height: cardHeight,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextTitle(summary.symbol),
                  ),
                  buildJumpToButton([
                    InternalViewSwitching.toInvestments(symbol: summary.symbol, accountName: account.fieldName.value),
                    InternalViewSwitching.toWeb(url: 'https://finance.yahoo.com/quote/${summary.symbol}/'),
                  ]),
                ],
              ),
              gapMedium(),

              // number of shares
              LabelAndQuantity(
                caption: 'Shares',
                quantity: summary.shares,
              ),

              // Price per share
              LabelAndAmount(
                caption: 'Share price',
                amount: summary.sharePrice,
              ),
              const Divider(),
              // Hold value
              LabelAndAmount(
                caption: 'Value',
                amount: summary.holdingValue,
              ),
            ],
          ),
        )
        .toList();

    // also add Summary Cash and Stock
    double totalInvestment = 0.0;
    stockSummaries.forEach((element) => totalInvestment += element.holdingValue);

    double totalCash = account.balance - totalInvestment;

    stockPanels.insert(
      0,
      BoxWithScrollingContent(
        height: cardHeight,
        children: [
          gapMedium(),
          // Cash
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextTitle('Cash'),
              MoneyWidget(
                amountModel: MoneyModel(
                  amount: totalCash,
                  iso4217: account.getAccountCurrencyAsText(),
                  autoColor: true,
                ),
              ),
            ],
          ),
          gapMedium(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextTitle('Investments'),
              MoneyWidget(
                amountModel: MoneyModel(
                  amount: totalInvestment,
                  iso4217: account.getAccountCurrencyAsText(),
                  autoColor: true,
                ),
              ),
            ],
          ),
          const Divider(),
          LabelAndAmount(
            caption: 'Value',
            amount: account.balance,
          ),
        ],
      ),
    );

    return stockPanels;
  }

  /// Details panels Chart panel for Accounts
  Widget _getSubViewContentForChart({
    required final List<int> selectedIds,
    required final bool showAsNativeCurrency,
  }) {
    final List<PairXY> listOfPairXY = <PairXY>[];

    if (selectedIds.length == 1) {
      final Account? account = getFirstSelectedItemFromSelectedList(selectedIds) as Account?;
      if (account == null) {
        // this should not happen
        return const Text('No account selected');
      }

      account.maxBalancePerYears.forEach((key, value) {
        double valueCurrencyChoice = showAsNativeCurrency ? value : value * account.getCurrencyRatio();

        listOfPairXY.add(PairXY(key.toString(), valueCurrencyChoice));
      });
      listOfPairXY.sort((a, b) => compareAsciiLowerCase(a.xText, b.xText));

      return Chart(
        key: Key('$selectedIds $showAsNativeCurrency'),
        list: listOfPairXY.take(100).toList(),
        variableNameHorizontal: 'Year',
        variableNameVertical: 'FBar',
        currency: showAsNativeCurrency ? account.fieldCurrency.value : Constants.defaultCurrency,
      );
    } else {
      for (final MoneyObject item in getList()) {
        final Account account = item as Account;
        if (account.isOpen) {
          listOfPairXY.add(
            PairXY(
              account.fieldName.value,
              showAsNativeCurrency ? account.balance : account.fieldBalanceNormalized.getValueForDisplay(account),
            ),
          );
        }
      }

      listOfPairXY.sort(
        (final PairXY a, final PairXY b) => (b.yValue.abs() - a.yValue.abs()).toInt(),
      );

      return Chart(
        key: Key(selectedIds.toString()),
        list: listOfPairXY.take(10).toList(),
        variableNameHorizontal: 'Account',
        variableNameVertical: 'Balance',
      );
    }
  }

  // Details Panel for Transactions
  Widget _getSubViewContentForTransactions({
    required final Account account,
    required final bool showAsNativeCurrency,
  }) {
    int sortFieldIndex = PreferenceController.to.getInt(getPreferenceKey('info_$settingKeySortBy'), 0);
    bool sortAscending = PreferenceController.to.getBool(getPreferenceKey('info_$settingKeySortAscending'), true);

    final SelectionController selectionController =
        Get.put(SelectionController(getPreferenceKey('info_$settingKeySelectedListItemId')));

    selectionController.load();

    final FieldDefinitions columnsToDisplay = <Field>[
      Transaction.fields.getFieldByName(columnIdDate),
      Transaction.fields.getFieldByName(columnIdPayee),
      Transaction.fields.getFieldByName(columnIdCategory),
      Transaction.fields.getFieldByName(columnIdMemo),
      Transaction.fields.getFieldByName(columnIdStatus),
      Transaction.fields.getFieldByName(
        showAsNativeCurrency ? columnIdAmount : columnIdAmountNormalized,
      ),
      Transaction.fields.getFieldByName(
        showAsNativeCurrency ? columnIdBalance : columnIdBalanceNormalized,
      ),
      // Credit Card account has a PaidOn column to help with balancing Statements
      if (account.fieldType.value == AccountType.credit) Transaction.fields.getFieldByName(columnIdPaidOn),
    ];

    return Obx(
      () {
        return ListViewTransactions(
          key: Key(
            'transaction_list_currency_${showAsNativeCurrency}_changedOn${DataController.to.lastUpdateAsString}',
          ),
          columnsToInclude: columnsToDisplay,
          getList: () => getTransactionForLastSelectedAccount(account),
          sortFieldIndex: sortFieldIndex,
          sortAscending: sortAscending,
          listController: Get.find<ListControllerInfoPanel>(),
          selectionController: selectionController,
          onUserChoiceChanged: (int sortByFieldIndex, bool sortAscending, final int selectedTransactionId) {
            // keep track of user choice
            sortFieldIndex = sortByFieldIndex;
            sortAscending = sortAscending;

            // Save user choices
            PreferenceController.to.setInt(
              getPreferenceKey('info_$settingKeySortBy'),
              sortByFieldIndex,
            );
            PreferenceController.to.setBool(
              getPreferenceKey('info_$settingKeySortAscending'),
              sortAscending,
            );
          },
        );
      },
    );
  }

  // Details Panel for Transactions
  Widget _getSubViewContentForTransactionsForLoans({
    required final Account account,
    required final bool showAsNativeCurrency,
  }) {
    int sortFieldIndex = PreferenceController.to.getInt(getPreferenceKey('info_$settingKeySortBy'), 0);
    bool sortAscending = PreferenceController.to.getBool(getPreferenceKey('info_$settingKeySortAscending'), true);
    int selectedItemId = PreferenceController.to.getInt(getPreferenceKey('info_$settingKeySelectedListItemId'), -1);

    List<LoanPayment> aggregatedList = getAccountLoanPayments(account);

    MoneyObjects.sortList(
      aggregatedList,
      LoanPayment.fieldsForColumnView.definitions,
      sortFieldIndex,
      sortAscending,
    );

    return AdaptiveListColumnsOrRows(
      list: aggregatedList,
      fieldDefinitions: LoanPayment.fieldsForColumnView.definitions,
      filters: FieldFilters(),
      sortByFieldIndex: sortFieldIndex,
      sortAscending: sortAscending,
      listController: Get.find<ListControllerInfoPanel>(),

      // Display as Cards or Columns
      // On small device you can display rows a Cards instead of Columns
      displayAsColumns: true,
      backgroundColorForHeaderFooter: Colors.transparent,
      onColumnHeaderTap: (int columnHeaderIndex) {
        // ignore: invalid_use_of_protected_member
        setState(() {
          if (columnHeaderIndex == sortFieldIndex) {
            // toggle order
            sortAscending = !sortAscending;
          } else {
            sortFieldIndex = columnHeaderIndex;
          }
          PreferenceController.to.setInt(
            getPreferenceKey('info_$settingKeySortBy'),
            sortFieldIndex,
          );
          PreferenceController.to.setBool(
            getPreferenceKey('info_$settingKeySortAscending'),
            sortAscending,
          );
        });
      },
      isMultiSelectionOn: false,
      selectedItemsByUniqueId: ValueNotifier<List<int>>([selectedItemId]),
      onSelectionChanged: (int uniqueId) {
        // ignore: invalid_use_of_protected_member
        setState(() {
          selectedItemId = uniqueId;
          PreferenceController.to.setInt(
            getPreferenceKey('info_$settingKeySelectedListItemId'),
            selectedItemId,
          );
        });
      },
      onItemLongPress: (BuildContext context2, int itemId) {
        final LoanPayment instance = findObjectById(itemId, aggregatedList) as LoanPayment;
        myShowDialogAndActionsForMoneyObject(
          title: 'Loan Payment',
          context: context2,
          moneyObject: instance,
        );

        selectedItemId = itemId;
        PreferenceController.to.setInt(
          getPreferenceKey('info_$settingKeySelectedListItemId'),
          selectedItemId,
        );
      },
    );
  }

  List<Transaction> getTransactionForLastSelectedAccount(
    final Account account,
  ) {
    return getTransactions(
      filter: (Transaction transaction) {
        return filterByAccountId(transaction, account.uniqueId);
      },
    );
  }
}

class StockSummary {
  StockSummary({required this.symbol, required this.shares, required this.sharePrice});

  final double sharePrice;
  final double shares;
  final String symbol;

  double get holdingValue => shares * sharePrice;
}
