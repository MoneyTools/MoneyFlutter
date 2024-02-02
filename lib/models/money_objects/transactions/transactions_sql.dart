part of 'transactions.dart';

extension TransactionsSql on Transactions {
  bool _saveSql(final MyDatabase db) {
    for (final Transaction item in getList()) {
      switch (item.change) {
        case ChangeType.none:
          break;
        case ChangeType.inserted:
          db.insert('Transactions', item.getPersistableJSon());
        // sb.Append("INSERT INTO Transactions ([Id],[Number],[Account],[Date],[Amount],[Status],[Memo],[Payee],[Category],[Transfer],[TransferSplit],[FITID],[SalesTax],[Flags],[ReconciledDate],[BudgetBalanceDate],[MergeDate],[OriginalPayee]) VALUES (");
        // sb.Append(string.Format("{0}", t.Id.ToString()));
        // sb.Append(string.Format(",'{0}'", DBString(t.Number)));
        // sb.Append(string.Format(",{0}", t.Account.Id));
        // sb.Append(string.Format(",{0}", DBDateTime(t.Date)));
        // sb.Append(string.Format(",{0}", DBDecimal(t.Amount)));
        // sb.Append(string.Format(",{0}", ((int)t.Status).ToString()));
        // sb.Append(string.Format(",'{0}'", DBString(t.Memo)));
        // sb.Append(string.Format(",{0}", t.Payee != null ? t.Payee.Id.ToString() : "-1"));
        // sb.Append(string.Format(",{0}", t.Category != null ? t.Category.Id.ToString() : "-1"));
        // sb.Append(string.Format(",{0}", t.Transfer != null && t.Transfer.Transaction != null ? t.Transfer.Transaction.Id.ToString() : "-1"));
        // sb.Append(string.Format(",{0}", t.Transfer != null && t.Transfer.Split != null ? t.Transfer.Split.Id.ToString() : "-1"));
        // sb.Append(string.Format(",'{0}'", DBString(t.FITID)));
        // sb.Append(string.Format(",{0}", DBDecimal(t.SalesTax)));
        // sb.Append(string.Format(",{0}", (int)t.Flags));
        // sb.Append(string.Format(",{0}", DBNullableDateTime(t.ReconciledDate)));
        // sb.Append(string.Format(",{0}", DBNullableDateTime(t.BudgetBalanceDate)));
        // sb.Append(string.Format(",{0}", DBNullableDateTime(t.MergeDate)));
        // sb.Append(string.Format(",'{0}'", DBString(t.OriginalPayee)));
        // sb.AppendLine(");");

        case ChangeType.deleted:
        /*
            sb.AppendLine("-- deleting account: " + a.Name);
            sb.AppendLine(string.Format("DELETE FROM Accounts WHERE Id={0};", a.Id.ToString()));
           */
        case ChangeType.changed:
        /*
              sb.AppendLine("-- updating account: " + a.Name);
              sb += "UPDATE Accounts SET ");
              sb += string.Format("AccountId='{0}'", DBString(a.AccountId)));
              sb += string.Format(",OfxAccountId='{0}'", DBString(a.OfxAccountId)));
              sb += string.Format(",Name='{0}'", DBString(a.Name)));
              sb += string.Format(",Type={0}", ((int)a.Type).ToString()));
              sb += string.Format(",Description='{0}'", DBString(a.Description)));
              sb += string.Format(",OnlineAccount={0}", a.OnlineAccount != null ? a.OnlineAccount.Id.ToString() : "-1"));
              sb += string.Format(",OpeningBalance={0}", a.OpeningBalance.ToString()));
              sb += string.Format(",LastSync={0}", DBDateTime(a.LastSync)));
              sb += string.Format(",LastBalance={0}", DBDateTime(a.LastBalance)));
              sb += string.Format(",SyncGuid={0}", DBGuid(a.SyncGuid)));
              sb += string.Format(",Flags={0}", ((int)a.Flags).ToString()));
              sb += string.Format(",Currency='{0}'", DBString(a.Currency)));
              sb += string.Format(",WebSite='{0}'", DBString(a.WebSite)));
              sb += string.Format(",ReconcileWarning={0}", a.ReconcileWarning));
              sb += string.Format(",CategoryIdForPrincipal='{0}'", a.CategoryForPrincipal == null ? "-1" : a.CategoryForPrincipal.Id.ToString()));
              sb += string.Format(",CategoryIdForInterest='{0}'", a.CategoryForInterest == null ? "-1" : a.CategoryForInterest.Id.ToString()));

              sb.AppendLine(string.Format(" WHERE Id={0};", a.Id));
           */
        default:
          debugPrint('Unhandled change ${item.change}');
      }
    }
    return false;
  }
}
