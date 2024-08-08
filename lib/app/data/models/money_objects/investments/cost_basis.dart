// ignore_for_file: unnecessary_this

import 'dart:collection';

import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/investments/account_holdings.dart';
import 'package:money/app/data/models/money_objects/investments/investment.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/security_group.dart';
import 'package:money/app/data/models/money_objects/investments/security_purchase.dart';
import 'package:money/app/data/models/money_objects/investments/security_sales.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/app/data/storage/data/data.dart';

/// <summary>
/// This class computes the cost basis associated with stock sales.
/// It does this by matching the shares sold against prior stock purchases in a FIFO order, so oldest stocks are sold first.
/// For example, suppose you purchase 20 shares in 2005 and another 50 in 2008, then sold 70 shares in 2010.  The sale will
/// produce two SecuritySale records, one for the batch of 20 shares and another for the batch of 50 shares because these
/// will likely have different Cost Basis and therefore different Gain/Loss amounts for tax purposes.  It takes stock
/// splits into account.
/// </summary>
class CostBasisCalculator {
  /// <summary>
  /// Compute capital gains associated with stock sales and whether they are long term or short term gains.
  /// </summary>
  /// <param name="money">The transactions</param>
  /// <param name="year">The year for the report</param>
  CostBasisCalculator(this.toDate) {
    this.calculate();
  }

  Map<Account, AccountHoldings> byAccount = {};
  List<SecuritySale> sales = [];
  DateTime toDate;

  void applySplit(Security s, StockSplit split) {
    for (AccountHoldings holding in this.byAccount.values) {
      double total = 0;
      for (SecurityPurchase purchase in holding.getPurchases(s)) {
        purchase.unitsRemaining = purchase.unitsRemaining * split.fieldNumerator.value / split.fieldDenominator.value;
        purchase.costBasisPerUnit =
            purchase.costBasisPerUnit * split.fieldDenominator.value / split.fieldNumerator.value;
        total += purchase.unitsRemaining;
      }

      // yikes also have to split the pending sales...?
      for (SecuritySale pending in holding.getPendingSalesForSecurity(s)) {
        if (pending.dateSold!.millisecond < split.fieldDate.value!.millisecond) {
          pending.unitsSold = pending.unitsSold * split.fieldNumerator.value / split.fieldDenominator.value;
          pending.salePricePerUnit =
              pending.salePricePerUnit * split.fieldDenominator.value / split.fieldNumerator.value;
        }
      }

      if (s.fieldSecurityType.value == SecurityType.equity.index) {
        // companies don't want to deal with fractional stocks, they usually distribute a "cash in lieu"
        // transaction in this case to compensate you for the rounding error.
        double floor = total.floor().toDouble();
        if (floor != total) {
          double diff = total - floor;
          double adjustment = (total - diff) / total;

          // distribute this rounding error back into the units remaining so we remember it.
          for (SecurityPurchase purchase in holding.getPurchases(s)) {
            purchase.unitsRemaining = (purchase.unitsRemaining * adjustment);
          }
        }
      }
    }
  }

  void applySplits(Security s, List<StockSplit> splits, DateTime dateTime) {
    StockSplit? next = splits.firstOrNull;
    while (next != null && next.fieldDate.value!.millisecond < dateTime.millisecond) {
      this.applySplit(s, next);
      splits.remove(next);
      next = splits.firstOrNull;
    }
  }

  /// <summary>
  /// Calculate the CapitalGains
  /// </summary>
  void calculate() {
    Map<Security, List<Investment>> map = Data().getTransactionsGroupedBySecurity(null, this.toDate);

    this.byAccount = <Account, AccountHoldings>{};

    // Now build the AccountHoldings  for all non-transfer add/buy transactions.
    // Don't handle transfers yet - for that we need to be able to compute the cost basis.
    for (final pair in map.entries) {
      Security s = pair.key;
      List<Investment> list = pair.value;

      List<StockSplit> splits = Data().stockSplits.getStockSplitsForSecurity(s);
      splits.sort((a, b) {
        return sortByDate(a.fieldDate.value, b.fieldDate.value); // ascending
      });

      for (Investment i in list) {
        // Now we need to apply any splits that are now valid as of  i.Date so we have the correct number of shares
        // computed for any future transactions.  Question is, if someone buys the stock on the very same day that it
        // was split, do they get the split or not?  This assumes not.
        this.applySplits(s, splits, i.date);
        var holdings = this.getHolding(i.transactionInstance!.instanceOfAccount!);

        if (i.fieldInvestmentType.value == InvestmentType.add.index ||
            i.fieldInvestmentType.value == InvestmentType.buy.index) {
          // transfer "adds" will be handled on the "remove" side below so we get the right cost basis.
          if (i.transactionInstance!.instanceOfTransfer == null && i.fieldUnits.value > 0) {
            holdings.buy(s, i.date, i.fieldUnits.value, i.originalCostBasis);
            for (SecuritySale pending in holdings.processPendingSales(s)) {
              this.sales.add(pending);
            }
          } else if ((i.fieldInvestmentType.value == InvestmentType.remove.index ||
                  i.fieldInvestmentType.value == InvestmentType.sell.index) &&
              i.fieldUnits.value > 0) {
            if (i.transactionInstance!.instanceOfTransfer == null) {
              for (SecuritySale sale in holdings.sell(
                Data().securities.get(i.fieldSecurity.value)!,
                i.date,
                i.fieldUnits.value,
                i.originalCostBasis,
              )) {
                this.sales.add(sale);
              }
            }
          } else {
            // track cost basis of securities transferred across accounts.
            // BugBug; could this ever be a split? Don't think so...
            if (i.transactionInstance?.instanceOfTransfer != null) {
              Investment? add = i.transactionInstance!.instanceOfTransfer!.receiverTransaction?.instanceOfInvestment;
              assert(
                add != null,
                'Other side of the Transfer needs to be an Investment transaction',
              );
              if (add != null) {
                if (add.fieldInvestmentType.value == InvestmentType.add.index) {
                  // assert(add.investmentType.value == InvestmentType.add.index,
                  // "Other side of transfer should be an Add transaction");
                  continue;
                }

                // now instead of doing a simple Add on the other side, we need to remember the cost basis of each purchase
                // used to cover the remove
                var securityInstance = Data().securities.get(i.fieldSecurity.value);
                if (securityInstance != null) {
                  for (SecuritySale sale in holdings.sell(
                    securityInstance,
                    i.date,
                    i.fieldUnits.value,
                    0,
                  )) {
                    var targetHoldings = this.getHolding(add.transactionInstance!.instanceOfAccount!);
                    if (sale.dateAcquired != null) {
                      // now transfer the cost basis over to the target account.
                      targetHoldings.buy(
                        s,
                        sale.dateAcquired!,
                        sale.unitsSold,
                        sale.costBasisPerUnit * sale.unitsSold,
                      );
                      for (SecuritySale pending in targetHoldings.processPendingSales(s)) {
                        this.sales.add(pending);
                      }
                    } else {
                      // this is the error case, but the error will be re-generated on the target account when needed.
                    }
                  }
                }
              }
            }
          }

          this.applySplits(s, splits, this.toDate);
        }
      }
    }
  }

  /// <summary>
  /// Get the current holdings per account.
  /// </summary>
  /// <param name="a">The account</param>
  /// <returns>The holdings listing securities that are still owned</returns>
  AccountHoldings getHolding(Account a) {
    AccountHoldings? holdings = this.byAccount[a];
    if (holdings == null) {
      holdings = AccountHoldings();
      holdings.account = a;
    }
    this.byAccount[a] = holdings;
    return holdings;
  }

  /// <summary>
  /// Return all securities that are still owned (have not been sold)
  /// </summary>
  /// <param name="account">Specified account or null for all accounts.</param>
  /// <returns></returns>
  List<SecurityGroup> getHoldingsBySecurityType(Account filter) {
    // Map<SecurityType, SecurityGroup> result = {};
    //
    // for (var accountHolding in this.byAccount.values) {
    //   if (filter == null || filter(accountHolding.Account)) {
    //     for (var sp in accountHolding.getHoldings()) {
    //       var type = sp.Security.SecurityType;
    //       SecurityGroup? group;
    //       if (!result.TryGetValue(type, out group)) {
    //         group = SecurityGroup();
    //         group.date = this.toDate;
    //         group.security = sp.Security;
    //         group.type = type;
    //         group.purchases = [];
    // // result[type] = group;
    // // }
    // // else if (group.Security != sp.Security)
    // // {
    // // group.Security = null; // is a multiSecurity group.
    // // }
    // // group.Purchases.add(sp);
    // // }
    // // }
    // // }
    // return List<SecurityGroup>(result.values
    // );
    return [];
  }

  List<SecuritySale> getPendingSales(Function(Account) forAccounts) {
    List<SecuritySale> result = [];
    for (var pair in this.byAccount.entries) {
      Account a = pair.key;
      if (forAccounts(a)) {
        for (SecuritySale pending in pair.value.getPendingSales()) {
          result.add(pending);
        }
      }
    }
    return result;
  }

  List<SecuritySale> getSales() {
    return this.sales;
  }

  /// <summary>
  /// Get all non-zero holdings remaining for the purchases listed in the given groupByType and
  /// group them be individual security.
  /// </summary>
  /// <returns></returns>
  List<SecurityGroup> regroupBySecurity(SecurityGroup groupByType) {
    SplayTreeMap<Security, SecurityGroup> holdingsBySecurity = SplayTreeMap<Security, SecurityGroup>();

    // Sort all add, remove, buy, sell transactions by date and by security.
    for (SecurityPurchase sp in groupByType.purchases) {
      Security? s = sp.security;
      if (s != null) {
        SecurityGroup? group = holdingsBySecurity[s];
        if (group == null) {
          group = SecurityGroup();
          group.date = this.toDate;
          group.security = s;
          group.type = SecurityType.values[s.fieldSecurityType.value];
          group.purchases = [];
          holdingsBySecurity[s] = group;
        }
        group.purchases.add(sp);
      }
    }

    return List<SecurityGroup>.from(holdingsBySecurity.values);
  }
}
