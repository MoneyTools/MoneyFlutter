import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/appbar.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/date_helper.dart';
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
import 'package:money/views/view_loans/view_loans.dart';
import 'package:money/views/view_payees/view_payees.dart';
import 'package:money/views/view_rentals/view_rentals.dart';
import 'package:money/views/view_transactions/view_transactions.dart';
import 'package:money/views/view_welcome.dart';
import 'package:money/widgets/keyboard_widget.dart';
import 'package:money/widgets/snack_bar.dart';
import 'package:money/widgets/working.dart';
import 'package:provider/provider.dart';

final Settings settings = Settings();
final Data data = Data();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    settings.retrieve();
    return ChangeNotifierProvider.value(
      value: settings,
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

    if (!settings.isPreferenceLoaded) {
      return const WorkingIndicator();
    }
    return MaterialApp(
      /// Assign Key Here
      scaffoldMessengerKey: SnackBarService.scaffoldKey,
      debugShowCheckedModeBanner: false,
      title: 'MyMoney by VTeam',
      theme: settings.getThemeData(),
      home: MediaQuery(
        key: Key(settings.getUniqueSate()),
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(settings.textScale)),
        child: myScaffold(
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

    if (settings.fileManager.shouldLoadLastDataFile()) {
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

  Widget buildContentForSmallSurface(final BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: getWidgetForMainContent(context, settings.selectedView),
          ),
          MenuHorizontal(
            settings: settings,
            onSelected: handleScreenChanged,
            selectedView: settings.selectedView,
          ),
        ],
      ),
    );
  }

  Widget buildContentForLargeSurface(final BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MenuVertical(
            settings: settings,
            onSelectItem: handleScreenChanged,
            selectedView: settings.selectedView,
            useIndicator: true,
          ),
          Expanded(
            child: Container(
              color: getColorTheme(context).secondaryContainer,
              child: getWidgetForMainContent(context, settings.selectedView),
            ),
          )
        ],
      ),
    );
  }

  bool shouldShowOpenInstructions() {
    if (settings.isPreferenceLoaded &&
        Data().accounts.isEmpty &&
        settings.fileManager.fullPathToLastOpenedFile.isEmpty) {
      return true;
    }
    return false;
  }

  void loadData() async {
    settings.fileManager.state = DataFileState.loading;
    data.loadFromPath(filePathToLoad: settings.fileManager.fullPathToLastOpenedFile).then((final bool success) {
      settings.fileManager.state = DataFileState.loaded;
      settings.rebuild();
    });
  }

  void handleScreenChanged(final ViewId selectedView) {
    settings.selectedView = selectedView;
  }

  void onFileNew() async {
    data.close();
    Settings().rebuild();

    settings.fileManager.fileName = Constants.newDataFile;
    settings.store();

    Data().accounts.addNewAccount('New Bank Account');
    settings.selectedView = ViewId.viewAccounts;
    settings.fileManager.state = DataFileState.loaded;
    Settings().rebuild();
  }

  void onFileOpen() async {
    FilePickerResult? pickerResult;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Special case for Android
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
      } else {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: <String>[
            'mmdb',
            'mmcsv',
            'sdf',
            'qfx',
            'ofx',
            'pdf',
            'json',
          ],
        );
      }
    } catch (e) {
      debugLog(e.toString());
    }

    if (pickerResult != null) {
      try {
        final String? fileExtension = pickerResult.files.single.extension;

        if (fileExtension == 'mmdb' || fileExtension == 'mmcsv') {
          if (kIsWeb) {
            settings.fileManager.fullPathToLastOpenedFile = pickerResult.files.single.path ?? '';

            final Uint8List? file = pickerResult.files.single.bytes;
            if (file != null) {
              // String s = String.fromCharCodes(file);
              // var outputAsUint8List = new Uint8List.fromList(s.codeUnits);
              // debugLog("--------$s");
            }
          } else {
            settings.fileManager.fullPathToLastOpenedFile = pickerResult.files.single.path ?? '';
          }
          if (settings.fileManager.fullPathToLastOpenedFile.isNotEmpty) {
            settings.store();
            loadData();
          }
        }
      } catch (e) {
        debugLog(e.toString());
      }
    }
  }

  void onOpenDemoData() async {
    settings.fileManager.fullPathToLastOpenedFile = '';
    settings.store();
    Data().loadFromDemoData();
    Settings().rebuild();
  }

  void onFileClose() async {
    settings.fileManager.fullPathToLastOpenedFile = '';
    settings.store();
    data.close();
    Settings().rebuild();
  }

  void onImport() async {
    final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
    if (pickerResult != null) {
      switch (pickerResult.files.single.extension?.toLowerCase()) {
        case 'qif':
          importQIF(pickerResult.files.single.path.toString());
        case 'qfx':
          importQFX(pickerResult.files.single.path.toString(), data);
        case 'pdf':
          importPDF(pickerResult.files.single.path.toString(), data);
      }
    }
  }

  void onShowFileLocation() async {
    String path = await settings.fileManager.generateNextFolderToSaveTo();
    openFolder(path);
  }

  void onSaveToCSV() async {
    final String fullPathTofileName = await data.saveToCsv();
    settings.fileManager.rememberWhereTheDataCameFrom(fullPathTofileName);
    data.assessMutationsCountOfAllModels();
  }

  void onSaveToSql() {
    data.saveToSql(
        filePathToLoad: settings.fileManager.fullPathToLastOpenedFile,
        callbackWhenLoaded: (final bool success) {
          data.assessMutationsCountOfAllModels();
        });

    settings.fileManager.rememberWhereTheDataCameFrom(settings.fileManager.fullPathToLastOpenedFile);
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

      case ViewId.viewRentals:
        return const ViewRentals();

      case ViewId.viewCashFlow:
      default:
        return const ViewCashFlow();
    }
  }

  Widget myScaffold({
    required final Widget body,
    final bool showAppBar = true,
    final Widget? bottomNavigationBar,
  }) {
    return Scaffold(
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
        () => showImportTransactions(context, '${dateToString(DateTime.now())} memo 1.00'),
        isMetaPressed: true,
      ),
      KeyAction(
        LogicalKeyboardKey('v'.codeUnitAt(0)),
        'Paste',
        () async {
          Clipboard.getData('text/plain').then((final ClipboardData? value) {
            if (value != null) {
              if (Settings().mostRecentlySelectedAccount != null) {
                showImportTransactions(
                  context,
                  value.text ?? '',
                );
              }
            }
          });
        },
        isMetaPressed: true,
      ),
    ];
  }
}
