enum CategoryType {
  none, // 0
  income, // 1
  expense, // 2
  saving, // 3
  reserved, // 4 this is not used (but hard to delete because of database).
  transfer, // 5 special category only used by pie charts
  investment, // 6 so you can separate out investment income and expenditures.
  recurringExpense, // 7 so you can clearly mark bills that are repeatable.
}
