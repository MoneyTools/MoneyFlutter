part of 'transactions.dart';

extension TransactionsSql on Transactions {
  bool _saveSql(final MyDatabase db) {
    for (final Transaction item in getList(true)) {
      switch (item.change) {
        case ChangeType.none:
          break;
        case ChangeType.inserted:
          db.insert('Transactions', item.getPersistableJSon());

        case ChangeType.deleted:
          db.delete('Transactions', item.uniqueId);

        case ChangeType.changed:
          db.update('Transactions', item.uniqueId, item.getPersistableJSon());
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
