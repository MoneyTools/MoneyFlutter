// ignore_for_file: unnecessary_this

import 'package:money/models/money_objects/investments/security_purchase.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/investments/security_sales.dart';
import 'package:money/models/money_objects/securities/security.dart';

/// <summary>
/// We implement a first-in first-out FIFO queue for securities, the assumption is that when
/// securities are sold you will first sell the security you have been holding the longest
/// in order to minimize capital gains taxes.
/// </summary>
class SecurityFifoQueue {
  List<SecurityPurchase> list = [];

  /// <summary>
  /// list of pending sales that we couldn't cover before, we keep these until the matching Buy arrives.
  /// </summary>
  List<SecuritySale> pending = [];

  /// <summary>
  /// The security that we are tracking with this queue.
  /// </summary>
  Security? security;

  /// <summary>
  /// The account the security is held in.
  /// </summary>
  Account? account;

  /// <summary>
  /// Record an Add or Buy for a given security.
  /// </summary>
  /// <param name="datePurchased">The date of the purchase</param>
  /// <param name="units">The number of units purchased</param>
  /// <param name="amount">The total cost basis for this purchase</param>
  void buy(DateTime datePurchased, double units, double costBasis) {
    SecurityPurchase sp = SecurityPurchase();
    sp.security = security;
    sp.datePurchased = datePurchased;
    sp.costBasisPerUnit = costBasis / units;
    sp.unitsRemaining = units;

    // insert the purchase in date order
    for (int i = 0, n = this.list.length; i < n; i++) {
      SecurityPurchase e = this.list[i];
      if (e.datePurchased.millisecond > datePurchased.millisecond) {
        this.list.insert(i, sp);
        return;
      }
    }

    this.list.add(sp);
  }

  /// <summary>
  /// Find the oldest holdings that still have UnitsRemaining, and decrement them by the
  /// number of units we are selling.  This might have to sell from multiple SecurityPurchases
  /// in order to cover the requested number of units.  If there are not enough units to cover
  /// the sale then we have a problem and we return a SecuritySale containing the Error information.
  /// </summary>
  /// <param name="dateSold">The date of the sale</param>
  /// <param name="units">The number of units sold</param>
  /// <param name="amount">The total amount we received from the sale</param>
  /// <returns></returns>
  List<SecuritySale> sell(DateTime dateSold, double units, double amount) {
    double salePricePerUnit = amount / units;
    List<SecuritySale> result = [];
    for (var purchase in this.list) {
      SecuritySale? sale = purchase.sell(dateSold, units, salePricePerUnit);
      if (sale != null) {
        sale.account = account;
        units -= sale.unitsSold;
        result.add(sale);

        if (units <= 0) {
          break; // done!
        }
      }
    }

    if (units.floor() > 0) {
      // Generate an error item so we can report this problem later.
      final ss = SecuritySale();
      ss.security = security;
      ss.account = account;
      ss.dateSold = dateSold;
      ss.unitsSold = units;
      ss.salePricePerUnit = salePricePerUnit;

      this.pending.add(ss);
    }
    return result;
  }

  List<SecuritySale> getPendingSales() {
    return this.pending;
  }

  List<SecuritySale> processPendingSales() {
// now that more has arrived, time to see if we can process those pending sales.
    List<SecuritySale> copy = List.from(this.pending);
    this.pending.clear();
    List<SecuritySale> result = [];
    for (final SecuritySale s in copy) {
      // this will put any remainder back in the pending list if it still can't be covered.
      for (SecuritySale real in this.sell(s.dateSold!, s.unitsSold, s.unitsSold * s.salePricePerUnit)) {
        result.add(real);
      }
    }
    return result;
  }

  List<SecurityPurchase> getHoldings() {
    List<SecurityPurchase> result = [];
    for (SecurityPurchase sp in this.list) {
      if (sp.unitsRemaining > 0) {
        result.add(sp);
      }
    }
    return result;
  }
}
