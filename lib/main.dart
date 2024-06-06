import 'dart:io';

// Import the file_picker package
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/appbar.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/menu.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/file_manager.dart';
import 'package:money/storage/import/import_pdf.dart';
import 'package:money/storage/import/import_qfx.dart';
import 'package:money/storage/import/import_qif.dart';
import 'package:money/storage/import/import_transactions_from_text.dart';
import 'package:money/views/view_accounts/view_accounts.dart';
import 'package:money/views/view_aliases/view_aliases.dart';
import 'package:money/views/view_cashflow/view_cashflow.dart';
import 'package:money/views/view_categories/view_categories.dart';
import 'package:money/views/view_investments/view_investments.dart';
import 'package:money/views/view_loans/view_loans.dart';
import 'package:money/views/view_payees/view_payees.dart';
import 'package:money/views/view_policy.dart';
import 'package:money/views/view_rentals/view_rentals.dart';
import 'package:money/views/view_stocks/view_stocks.dart';
import 'package:money/views/view_transactions/view_transactions.dart';
import 'package:money/views/view_transfers/view_transfers.dart';
import 'package:money/views/view_welcome.dart';
import 'package:money/widgets/keyboard_widget.dart';
import 'package:money/widgets/message_box.dart';
import 'package:money/widgets/snack_bar.dart';
import 'package:money/widgets/working.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Settings().preferrenceLoad();
    return ChangeNotifierProvider.value(
      value: Settings(),
      child: const MainView(),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(final BuildContext context) {
    final settings = Provider.of<Settings>(context);
    settings.isSmallScreen = MediaQuery.of(context).size.width < 800;

    if (!Settings().isPreferenceLoaded) {
      return const WorkingIndicator();
    }

    final themeData = Settings().getThemeData();

    return MaterialApp(
      /// Assign Key Here
      scaffoldMessengerKey: SnackBarService.scaffoldKey,
      navigatorKey: DialogService().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MyMoney by VTeam',
      theme: themeData,
      home: MediaQuery(
        key: Key(Settings().getUniqueSate()),
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(Settings().textScale)),
        child: myScaffold(
          backgroundColor: themeData.colorScheme.secondaryContainer,
          showAppBar: !shouldShowOpenInstructions(),
          body: isPlatformMobile()
              // Mobile has no keyboard support
              ? buildContent(context)
              // Keyboard support for Desktop and Web
              : KeyboardWidget(
                  columnCount: 1,
                  bindings: getKeyboardBindings(context),
                  child: buildContent(context),
                ),
        ),
      ),
    );
  }

  Widget buildContent(final BuildContext context) {
    // Welcome screen
    if (shouldShowOpenInstructions()) {
      return WelcomeScreen(
        onFileNew: onFileNew,
        onFileOpen: onFileOpen,
        onOpenDemoData: onOpenDemoData,
      );
    }

    if (Settings().fileManager.shouldLoadLastDataFile()) {
      // loading a file
      loadData();
      return const WorkingIndicator();
    }

    // small screens
    if (Settings().isSmallScreen) {
      return buildContentForSmallSurface(context);
    }

    // Large screens
    return buildContentForLargeSurface(context);
  }

  Widget buildContentForLargeSurface(final BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MenuVertical(
            key: Key(Settings().selectedView.toString()),
            settings: Settings(),
            onSelectItem: handleScreenChanged,
            selectedView: Settings().selectedView,
            useIndicator: true,
          ),
          Expanded(
            child: Container(
              color: getColorTheme(context).secondaryContainer,
              child: getWidgetForMainContent(context, Settings().selectedView),
            ),
          )
        ],
      ),
    );
  }

  Widget buildContentForSmallSurface(final BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: getWidgetForMainContent(context, Settings().selectedView),
        ),
        MenuHorizontal(
          key: Key(Settings().selectedView.toString()),
          settings: Settings(),
          onSelected: handleScreenChanged,
          selectedView: Settings().selectedView,
        ),
      ],
    );
  }

  List<KeyAction> getKeyboardBindings(final BuildContext context) {
    return <KeyAction>[
      KeyAction(
        LogicalKeyboardKey.equal,
        'Increase text size',
        () {
          Settings().fontScaleIncrease();
        },
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey.minus,
        'Decrease text size',
        () {
          Settings().fontScaleDecrease();
        },
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('0'.codeUnitAt(0)),
        'Normal text size',
        () {
          Settings().setFontScaleTo(1);
        },
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('t'.codeUnitAt(0)),
        'Add transactions',
        () => showImportTransactions(context, ''),
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('v'.codeUnitAt(0)),
        'Paste',
        () async {
          Clipboard.getData('text/plain').then((final ClipboardData? value) {
            if (value != null) {
              showImportTransactions(
                context,
                value.text ?? '',
              );
            }
          });
        },
        isMetaPressed: true,
      ),
    ];
  }

  Widget getWidgetForMainContent(final BuildContext context, final ViewId screenIndex) {
    switch (screenIndex) {
      case ViewId.viewAccounts:
        return const ViewAccounts();

      case ViewId.viewLoans:
        return const ViewLoans();

      case ViewId.viewCategories:
        return const ViewCategories();

      case ViewId.viewPayees:
        return const ViewPayees();

      case ViewId.viewAliases:
        return const ViewAliases();

      case ViewId.viewTransactions:
        return const ViewTransactions();

      case ViewId.viewTransfers:
        return const ViewTransfers();

      case ViewId.viewInvestments:
        return const ViewInvestments();

      case ViewId.viewStocks:
        return const ViewStocks();

      case ViewId.viewRentals:
        return const ViewRentals();

      case ViewId.viewPolicy:
        return const PolicyScreen();

      case ViewId.viewCashFlow:
      default:
        return const ViewCashFlow();
    }
  }

  void handleScreenChanged(final ViewId selectedView) {
    Settings().selectedView = selectedView;
  }

  void loadData() async {
    Settings().fileManager.state = DataFileState.loading;
    Data().loadFromPath(filePathToLoad: Settings().fileManager.fullPathToLastOpenedFile).then((final bool success) {
      if (success) {
        Settings().fileManager.state = DataFileState.loaded;
        Settings().rebuild();
      }
    });
  }

  Widget myScaffold({
    required Color backgroundColor,
    required final Widget body,
    final bool showAppBar = true,
    final Widget? bottomNavigationBar,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? MyAppBar(
              onFileNew: onFileNew,
              onFileOpen: onFileOpen,
              onFileClose: onFileClose,
              onShowFileLocation: onShowFileLocation,
              onImport: onImport,
              onSaveCsv: onSaveToCSV,
              onSaveSql: onSaveToSql,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  void onFileClose() async {
    Settings().fileManager.fullPathToLastOpenedFile = '';
    Settings().preferrenceSave();
    Data().close();
    Settings().rebuild();
  }

  void onFileNew() async {
    Data().close();
    Settings().rebuild();

    Settings().fileManager.fileName = Constants.newDataFile;
    Settings().preferrenceSave();

    Data().accounts.addNewAccount('New Bank Account');
    Settings().selectedView = ViewId.viewAccounts;
    Settings().fileManager.state = DataFileState.loaded;
    Settings().rebuild();
  }

  void onFileOpen() async {
    FilePickerResult? pickerResult;
    const supportedFileTypes = <String>[
      'mmdb',
      'mmcsv',
      'sdf',
      'qfx',
      'ofx',
      'pdf',
      'json',
    ];

    try {
      // WEB
      if (kIsWeb) {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );
      } else
      // Mobile
      if (Platform.isAndroid || Platform.isIOS) {
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
      } else
      // Desktop
      {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: supportedFileTypes,
        );
      }
    } catch (e) {
      debugLog(e.toString());
    }

    if (pickerResult != null && pickerResult.files.isNotEmpty) {
      try {
        final String? fileExtension = pickerResult.files.single.extension;

        if (fileExtension == 'mmdb' || fileExtension == 'mmcsv') {
          if (kIsWeb) {
            PlatformFile file = pickerResult.files.first;

            Settings().fileManager.fullPathToLastOpenedFile = file.name;
            Settings().fileManager.fileBytes = file.bytes!;
          } else {
            Settings().fileManager.fullPathToLastOpenedFile = pickerResult.files.single.path ?? '';
          }
          if (Settings().fileManager.fullPathToLastOpenedFile.isNotEmpty) {
            Settings().preferrenceSave();
            loadData();
          }
        }
      } catch (e) {
        debugLog(e.toString());
      }
    }
  }

  void onImport() async {
    final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
    if (pickerResult != null) {
      switch (pickerResult.files.single.extension?.toLowerCase()) {
        case 'qif':
          importQIF(pickerResult.files.single.path.toString());
        case 'qfx':
          importQFX(pickerResult.files.single.path.toString(), Data());
        case 'pdf':
          importPDF(pickerResult.files.single.path.toString(), Data());
      }
    }
  }

  void onOpenDemoData() async {
    Settings().fileManager.fullPathToLastOpenedFile = '';
    Settings().preferrenceSave();
    Data().loadFromDemoData();
    Settings().rebuild();
  }

  void onSaveToCSV() async {
    final String fullPathToFileName = await Data().saveToCsv();
    Settings().fileManager.rememberWhereTheDataCameFrom(fullPathToFileName);
    Data().assessMutationsCountOfAllModels();
  }

  void onSaveToSql() async {
    if (Settings().fileManager.fullPathToLastOpenedFile.isEmpty) {
      // this happens if the user started with a new file and click save to SQL
      Settings().fileManager.fullPathToLastOpenedFile =
          await Settings().fileManager.defaultFolderToSaveTo('mymoney.mmdb');
    }

    Data().saveToSql(
        filePathToLoad: Settings().fileManager.fullPathToLastOpenedFile,
        callbackWhenLoaded: (final bool success, final String message) {
          if (success) {
            Data().assessMutationsCountOfAllModels();
          } else {
            DialogService().showMessageBox('Error Saving', message);
          }
        });

    Settings().fileManager.rememberWhereTheDataCameFrom(Settings().fileManager.fullPathToLastOpenedFile);
  }

  void onShowFileLocation() async {
    String path = await Settings().fileManager.generateNextFolderToSaveTo();
    openFolder(path);
  }

  bool shouldShowOpenInstructions() {
    if (Settings().isPreferenceLoaded &&
        Data().accounts.isEmpty &&
        Settings().fileManager.fullPathToLastOpenedFile.isEmpty) {
      return true;
    }
    return false;
  }
}
