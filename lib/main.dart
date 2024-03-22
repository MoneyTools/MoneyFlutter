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
    settings.loadSettings();
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
        key: Key('key_100_${settings.useDarkMode}'),
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
    // Loading ...
    if (!settings.isPreferenceLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // Welcome screen
    if (shouldShowOpenInstructions()) {
      return WelcomeScreen(
        onFileNew: onFileNew,
        onFileOpen: onFileOpen,
        onOpenDemoData: onOpenDemoData,
      );
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
            child: getWidgetForMainContent(context, settings.selectedScreen),
          ),
          MenuHorizontal(
            settings: settings,
            onSelectItem: handleScreenChanged,
            selectedIndex: settings.selectedScreen,
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
            selectedIndex: settings.selectedScreen,
            useIndicator: true,
          ),
          Expanded(
            child: Container(
              color: getColorTheme(context).secondaryContainer,
              child: getWidgetForMainContent(context, settings.selectedScreen),
            ),
          )
        ],
      ),
    );
  }

  bool shouldShowOpenInstructions() {
    if (settings.isPreferenceLoaded && data.fullPathToDataSource == null) {
      return true;
    }
    return false;
  }

  void loadData() async {
    data.loadFromPath(filePathToLoad: settings.lastOpenedDataSource).then((final bool success) {
      settings.isDataFileLoaded = true;
    });
  }

  void handleScreenChanged(final int selectedScreen) {
    settings.selectedScreen = selectedScreen;
  }

  void onFileNew() async {
    Data().clear();
    settings.lastOpenedDataSource = Constants.newDataFile;
    settings.save();
    loadData();
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
            settings.lastOpenedDataSource = pickerResult.files.single.path;

            final Uint8List? file = pickerResult.files.single.bytes;
            if (file != null) {
              // String s = String.fromCharCodes(file);
              // var outputAsUint8List = new Uint8List.fromList(s.codeUnits);
              // debugLog("--------$s");
            }
          } else {
            settings.lastOpenedDataSource = pickerResult.files.single.path;
          }
          if (settings.lastOpenedDataSource != null) {
            settings.save();
            loadData();
          }
        }
      } catch (e) {
        debugLog(e.toString());
      }
    }
  }

  void onOpenDemoData() async {
    settings.lastOpenedDataSource = Constants.demoData;
    settings.save();
    loadData();
  }

  void onFileClose() async {
    settings.lastOpenedDataSource = null;
    settings.save();
    data.close();
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

  void onShowFileLocation() {
    openFolder(data.fullPathToNextDataSave!);
  }

  void onSaveToCav() {
    data.saveToCsv();
  }

  void onSaveToSql() {
    data.saveToSql(
        filePathToLoad: settings.lastOpenedDataSource,
        callbackWhenLoaded: (final bool success) {
          data.assessMutationsCountOfAllModels();
        });
  }

  Widget showLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget getWidgetForMainContent(final BuildContext context, final int screenIndex) {
    if (!settings.isDataFileLoaded) {
      return showLoading();
    }

    switch (screenIndex) {
      case Constants.viewAccounts:
        return const ViewAccounts();

      case Constants.viewLoans:
        return const ViewLoans();

      case Constants.viewCategories:
        return const ViewCategories();

      case Constants.viewPayees:
        return const ViewPayees();

      case Constants.viewAliases:
        return const ViewAliases();

      case Constants.viewTransactions:
        return const ViewTransactions();

      case Constants.viewRentals:
        return const ViewRentals();

      case 0:
      default:
        return ViewCashFlow(
          key: Key('cashflow_${Data().fullPathToDataSource}'),
        );
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
              onSaveCsv: onSaveToCav,
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
