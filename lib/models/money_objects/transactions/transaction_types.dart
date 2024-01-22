enum TransactionStatus {
  none,
  electronic,
  cleared,
  reconciled,
  voided,
}

enum TransactionFlags {
  none, // 0
  unaccepted, // 1
  // 2
  budgeted,
  // 3
  filler3,
  // 4
  hasAttachment,
  // 5
  filler5,
  // 6
  filler6,
  // 7
  filler7,
  // 8
  notDuplicate,
  filler9,
  filler10,
  filler11,
  filler12,
  filler13,
  filler14,
  filler15,
  // 16
  hasStatement,
}

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdStatus = 'Status';
const String columnIdMemo = 'Memo';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';
