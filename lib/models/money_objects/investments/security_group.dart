import 'package:money/models/money_objects/investments/security_purchase.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/investments/investment_types.dart';
import 'package:money/models/money_objects/securities/security.dart';

/// <summary>
/// This class is used to track the cost basis for a given sale.
/// </summary>
class SecuritySale {
  /// <summary>
  /// This sale represents an error.
  /// </summary>
  Exception? error;

  /// <summary>
  /// The security that was purchased.
  /// </summary>
  Security? security;

  /// <summary>
  /// The account that it was sold from.
  /// </summary>
  Account? account;

  /// <summary>
  /// The date this security was purchased.
  /// </summary>
  DateTime? dateAcquired;

  /// <summary>
  /// The date this security was sold.
  /// </summary>
  DateTime? dateSold;

  /// <summary>
  /// The price we got for the units at the time of sale (minus fees and commissions)
  /// </summary>
  double salePricePerUnit = 0;

  /// <summary>
  /// The number of units sold
  /// </summary>
  double unitsSold = 0;

  /// <summary>
  /// The original cost basis for this security per unit.  THis is not necessarily the
  /// UnitPrice we paid for the security, commissions and fees are also taken into account.
  /// </summary>
  double costBasisPerUnit = 0;

  /// <summary>
  /// The total remaining cost basis based on the number of units remaining.
  /// </summary>
  double get totalCostBasis {
    return costBasisPerUnit * unitsSold;
  }

  /// <summary>
  /// The total funds received from the transaction
  /// </summary>
  double get saleProceeds {
    return salePricePerUnit * unitsSold;
  }

  /// <summary>
  /// The total difference between the Proceeds and the TotalCostBasis
  /// </summary>
  double get totalGain {
    return saleProceeds - totalCostBasis;
  }

  /// <summary>
  /// For a roll-up report where individual SecuritySale is too much detail we
  /// can consolidate here, but only if the salePricePerUnit and costBasisPerUnit
  /// match.  If they do not match then we set them to zero so they are reported
  /// as "unknown".
  /// </summary>
  /// <param name="cg">The other sale to consolidate</param>
  void consolidate(SecuritySale cg) {
    unitsSold += cg.unitsSold;

    if (dateAcquired != cg.dateAcquired) {
      // will be reported to IRS as "VARIOUS"
      dateAcquired = null;
      costBasisPerUnit = 0;
    }
    if (salePricePerUnit != cg.salePricePerUnit) {
      salePricePerUnit = 0;
    }

    if (costBasisPerUnit != cg.costBasisPerUnit) {
      costBasisPerUnit = 0;
    }
  }
}

class SecurityGroup {
  DateTime? date;
  Security? security;
  SecurityType? type;
  List<SecurityPurchase> purchases = [];
  TaxStatus taxStatus = TaxStatus.any;
  Account? filter;
}

enum TaxStatus {
  taxable,
  taxDeferred,
  taxFree,
  any,
}
