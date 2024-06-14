// ignore_for_file: unnecessary_this

import 'dart:math';
import 'package:money/models/money_objects/investments/investment_types.dart';
import 'package:money/models/money_objects/investments/security_sales.dart';
import 'package:money/models/money_objects/securities/security.dart';

/// <summary>
/// This class is used to track the cost basis for a given purchase, sometimes this cost basis
/// has to travel across accounts when a transfer occurs.  When securities are purchased
/// </summary>
class SecurityPurchase {
  /// <summary>
  /// The security that was purchased.
  /// </summary>
  Security? security;

  /// <summary>
  /// The date this security was purchased.
  /// </summary>
  late DateTime datePurchased;

  /// <summary>
  /// The number of units remaining from this lot.
  /// </summary>
  double unitsRemaining = 0;

  /// <summary>
  /// The original cost basis for this security per unit.  THis is not necessarily the
  /// UnitPrice we paid for the security, commissions and fees are also taken into account.
  /// </summary>
  double costBasisPerUnit = 0;

  /// <summary>
  /// The total remaining cost basis based on the number of units remaining.
  /// </summary>
  double get totalCostBasis {
    return this.costBasisPerUnit * this.unitsRemaining;
  }

  /// <summary>
  /// Get market value of remaining units.
  /// </summary>
  double? get latestMarketValue {
    return this.futuresFactor * this.unitsRemaining * this.security!.price.value.toDouble();
  }

  double get futuresFactor {
    double factor = 1;
    // futures prices are always listed by the instance.  But wen you buy 1 contract, you always get 100 futures in that contract
    if (security!.securityType.value == SecurityType.futures.index) {
      factor = 100;
    }
    return factor;
  }

  /// <summary>
  /// Perform a sale of the given number of units.  If we don't have enough return all that we have.
  /// </summary>
  /// <param name="date">The date of the sale</param>
  /// <param name="units">The number we'd like to sell</param>
  /// <param name="unitSalePrice">The price per unit we received at date of sale</param>
  /// <returns>The SecuritySale containing the number of units we are selling from this lot or null
  /// if this lot is empty</returns>
  SecuritySale? sell(DateTime date, double units, double unitSalePrice) {
    if (this.unitsRemaining == 0) {
      return null;
    }

    double canSell = min(units, this.unitsRemaining);

    unitsRemaining -= canSell;

    var s = SecuritySale()
      ..dateSold = date
      ..security = security
      ..costBasisPerUnit = costBasisPerUnit
      ..unitsSold = canSell
      ..dateAcquired = datePurchased
      ..salePricePerUnit = unitSalePrice;

    return s;
  }
}
