# Change Log

## [version 1.6.3] 2024-03-31

- Update package [file_picker: 8.0.0]
- Update package [fl_chart: ^0.67.0]

## [version 1.6.2] 2024-03-30

### Updated

- Reach MVP for the Text Import feature

## [version 1.6.1] 2024-03-29

### Updated

- List selection is now using Unique Id instead of Index

### Fixed

- Chart reverse order

## [version 1.6.0] 2024-03-28

### Added

- Transfers View

## [version 1.5.1] 2024-03-26

### Updated

- Improve the Delete confirmation dialog

## [version 1.5.0] 2024-03-25

### Added

- Account chart of Max Balances per years

### Fixed

= When loading via json.getInt() we now default to -1 for entity ID, since Zero is a valid ID

## [version 1.4.9] 2024-03-24

### Added

- Dialog showing list of pending changes [Added|Modified|Deleted]

# Change Log

## [version 1.4.8] 2024-03-23

### Added

- Save to new SQL file

### Update

- Display Transfer or Payee Name

## [version 1.4.7] 2024-03-22

### Updated

- Remove unused layoutBuild(constraint)
- Editing of Account [accountId, ofxAccountID, description]

### Added

- User can now Add new Accounts
- Use package [provider] for state management
- Load from CSV [mymoney.mmcsv] file
- Close and create a new file

## [version 1.4.6] 2024-03-20

### Added

- PickerForAccountType

### Updated

- Improve ImportQFX

### Refactor

- Rename class MyMoney to MainApp
- Theme.of(context).colorScheme to getColorTheme(context)

## [version 1.4.5] 2024-03-19

## Fixed

- Fix for Table header filter
- Fix Web version

## Added

- Letter Picker
- Payee helper getPayeeIdFromTextMatchingOrAdd()

## Updated

- ImportQFX: skip duplicates

## Refactor

- Loading screen, app bar header
- Transaction Payee
- [notifyTransactionChange()| MoneyObject.addEntry()] use named parameters

## [version 1.4.4] 2024-03-18

## Fixed

- Transaction Amount List and Dialog

## Updated

- Improve layout for Large and small screen
- Only show the ADD (+) on the details panel if the Transactions tab is selected and expanded

## Added

- Display Green, Orange, Red adornments to list items
- Script for dependency graph using Lakos and to graphviz

## [version 1.4.3] 2024-03-17

### Updated

- MVP use case: Duplicate & Edit (Date, Payee, Amount) of a transaction
- Mutate Dialog for Transaction : Starts from a ReadOnly view user can then decide
  to [Delete|Duplicate|Edit]

## [version 1.4.2] 2024-03-16

### Updated

- Fields support for Editable vs ReadOnly
- List View
    - Optional Un-Selectable row
    - Refresh when data is mutated
    - Prioritize Selection color before Hover color

## [version 1.4.1] 2024-03-15

### Updated

- TextEditWithPicker now has a filter

## [version 1.4.0] 2024-03-14

### Fixed

- Demo data use negative amount for expenses

### Update

- Column Header are now aligned with content [ L | C | R ]
- SanKey
    - More usable on small devices (phones)
    - Net Lost now displays on the left side of Expenses
    - Width is flush to the view port

## [version 1.3.9] 2024-03-13

### Added

- Add new Transaction from Accounts Detail Panel
- ComboEditBox

### Update

- Remember selection and sorting of details panel for Account view
- Improve View Header, use less space
- Improve mobile support when editing text field
- Only display the segment selection '✓' symbol on larger screen

## [version 1.3.8] 2024-03-11

### Added

- Enable editing the Category of a transaction
- Add filter-text-box to Table Column Filter dialog
- Import via batch text Date-Description-Amount

## [version 1.3.7] 2024-03-04

### Added

- Import transactions using free style Itext

## [version 1.3.6] 2024-03-03

### Added

- Column Filter for Text type

### Improved

- Import from clipboard
- Select Account when doing a Clipboard Import
- Scrollable content

## [version 1.3.5] 2024-03-01

### Fixed

- Fix CSV Transaction.Amount

### Added

- Import Account transactions via the Clipboard Date,Description,Amount

### Updated

- Flutter 3.19.2

## [version 1.3.4] 2024-02-25

- Layout Multi columns details panel

## [version 1.3.3] 2024-02-24

- Mutation of MoneyObject
- Ability to change Account is Open or Closed

## [version 1.3.2] 2024-02-22

- Currency toggle in Details panel

## [version 1.3.1] 2024-02-21

- Remember Details panel last tab selection
- Improve the delete dialog
- Add Mouse Hover color to list view items
- Delete Transaction from Details Panel

## [version 1.3.0] 2024-02-19

- Improve Sankey layout
- Update most packages
- Fix deprecated keyboard API

## [version 1.2.17] 2024-02-18

- Adaptive menus - show label on left side menu when the screen is larger than 1000 pixels
- Flutter 3.19.0 Dart 3.3.0

## [version 1.2.16] 2024-02-14

- Adjusted - Improve Dialog full screen on small devices (Widget smaller than 600 pixels)

## [version 1.2.15] 2024-02-14

- Improve Dialog full screen on small devices

## [version 1.2.14] 2024-02-11

- Improve List view for mobile

## [version 1.2.08] 2024-02-04

- Ensure Model ID are unique and not -1
- Implement Delete Payee

## [version 1.2.07] 2024-02-03

- fix web version

## [version 1.2.06] 2024-02-02

- Implement SQL "Inserts|Update|Delete"

## [version 1.2.05] 2024-02-01

- Improved Badge for Changes, now showing +Added -Deleted
- Improved Import QFX

## [version 1.2.04] 2024-01-31

- Badge counter show number of changes
- Improve the Delete confirmation Dialog

## [version 1.2.03] 2024-01-30

- Render Amount in any ISO4217 currency
- Normalize balance amount to currency USD
- Demo Data for Aliases
- Add Flags to Currencies & Accounts
- fix the iOS build, min iOS version 13

## [version 1.2.02] 2024-01-29

- Load and Save Currencies

## [version 1.2.01] 2024-01-28

- Better Demo Data
- Refactor onOpen...onSave

## [version 1.2.00] 2024-01-27

- Complete Rental fields
- Text filter on all table views

## [version 1.1.05] 2024-01-26

- All the fields for Transaction

## [version 1.1.04] 2024-01-25

- Add Status column to Transaction Table
- Improve font scaling UX

## [version 1.1.03] 2024-01-23

- Improve Table List column by using adjustable widths

## [version 1.1.02] 2024-01-21

- MyJson helper
- Compact List for Categories

## [version 1.1.01] 2024-01-22

- Adaptive View content (Accounts and Transactions)
- LINT enforce all Functions and Methods must have a return type

## [version 1.1.00] 2024-01-20

- Category list & Details panel show Colors
- Major refactor moved to Self describing Declarative Properties

## [version 1.0.21] 2024-01-17

- Refactor reduce code to deal with all tables
- All 16 tables now have Load & Save implementations, not all fields are implemented

## [version 1.0.20] 2024-01-16

- Refactor saving toCSV

## [version 1.0.19] 2024-01-15

- Detail Panel, Split transaction

## [version 1.0.18] 2024-01-14

- Start basic documentation
- Refactor MoneyObjects

## [version 1.0.17] 2024-01-13

- Field [type.widget] used in CategoryList for Color
- Load all Account,Alias,Category,Payee,Rental,RentUnit SQLite fields
- Add Filter input to ViewTransaction List

## [version 1.0.16] 2024-01-11

- Load data for Transaction.Status
- Refactor use [Field Definition] model

## [version 1.0.15] 2024-01-10

- Basic Save as CSV
- Show OS container folder

## [version 1.0.14] 2024-01-09

- Performance improvement on Transaction list

## [version 1.0.13] 2024-01-08

- UX for Delete from the [DetailsPanel]
- Remember each views list selected item
- Refactor views - use TableTransactions for details panel
- Improve theme color layout

## [version 1.0.12] 2024-01-06

- SegmentControl for DetailsPanel
- Improve Detail panel Tab Selection
- View Aliases - Show transactions for the selected alias

## [version 1.0.11] 2024-01-05

- Persist user sorting preference of all Views
- User choice "Include Closed Accounts"
- Fix the execution of tests

## [version 1.0.10] 2024-01-04

- Basic QFX import
- View Aliases
- Convert MoneyEntity ID from [num] to [int]

## [version 1.0.9] 2024-01-01

- Improve Table performance
- Refactor Transaction Table view

## [version 1.0.8] 2023-12-31

- Improve performance of Table View Row selection

## [version 1.0.7] 2023-12-30

- Detail Transactions for Payees and Categories
- Center & scrollable left menu bar
- Improve Chart tooltips
- Migrate to sqlite3 & sqlite3_flutter_libs

## [version 1.0.6] 2023-12-29

- Migrate to FL_CHART
- Refactor to use strong typed everywhere

## [version 1.0.5] 2023-10-28

- ViewCategories - filter by types
- Double Click to open Details Panel
- Package path: 1.9.0

## [version 1.0.4] 2023-10-27

- Fix Chart on ViewByAccounts
- Add keyboard binding
- Upgrade to Flutter 3.16.5

## [version 1.0.2] 2023-10-19

- macOS is working again
- Transaction 1 year Chart period

## [version 1.0.1]

- Improve a few area

## [version 1.0.0]

- Initial app