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
import 'package:money/widgets/keyboard_widget.dart';
import 'package:money/widgets/snack_bar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Settings settings = Settings();
  bool _isLoading = true;
  final Data data = Data();

  @override
  void initState() {
    settings.load().then((void _) {
      loadData();
    });

    settings.onChanged = () {
      // force refresh the app UI
      setState(() {
        // settings = Settings();
      });
    };
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    Settings().isSmallScreen = MediaQuery.of(context).size.width < 800;

    return MaterialApp(
      /// Assign Key Here
      scaffoldMessengerKey: SnackBarService.scaffoldKey,
      debugShowCheckedModeBanner: false,
      title: 'MyMoney by VTeam',
      theme: settings.getThemeData(),
      home: Container(
          key: Key('key_data_version_${Data().version}'),
          color: getColorTheme(context).background,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(settings.textScale)),
            child: myScaffold(
              showAppBar: !shouldShowOpenInstructions(),
              body: Container(
                color: getColorTheme(context).secondaryContainer,
                child: isPlatformMobile()
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
          )),
    );
  }

  Widget buildContent(final BuildContext context) {
    // Welcome screen
    if (shouldShowOpenInstructions()) {
      return welcomePanel(context);
    }

    // Loading ...
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            child: getWidgetForMainContent(context, settings.screenIndex),
          ),
          MenuHorizontal(
            settings: settings,
            onSelectItem: handleScreenChanged,
            selectedIndex: settings.screenIndex,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MenuVertical(
            settings: settings,
            onSelectItem: handleScreenChanged,
            selectedIndex: settings.screenIndex,
            useIndicator: true,
          ),
          Expanded(
            child: Container(
              color: getColorTheme(context).secondaryContainer,
              child: getWidgetForMainContent(context, settings.screenIndex),
            ),
          )
        ],
      ),
    );
  }

  bool shouldShowOpenInstructions() {
    if (settings.prefLoaded && data.fullPathToDataSource == null) {
      return true;
    }
    return false;
  }

  void loadData() async {
    data.loadFromPath(filePathToLoad: settings.lastOpenedDataSource).then((final bool success) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void handleScreenChanged(final int selectedScreen) {
    setState(() {
      settings.screenIndex = selectedScreen;
    });
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
    settings.fireOnChanged();
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
      settings.fireOnChanged();
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
    if (_isLoading) {
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

  Widget welcomePanel(final BuildContext context) {
    return Row(
      children: <Widget>[
        renderWelcomeAndOpen(context),
      ],
    );
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

  Widget renderWelcomeAndOpen(final BuildContext context) {
    final TextTheme textTheme = getTextTheme(context);
    return Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text('Welcome to MyMoney', textAlign: TextAlign.left, style: textTheme.headlineSmall),
      const SizedBox(height: 40),
      Text('No data loaded', textAlign: TextAlign.left, style: textTheme.bodySmall),
      const SizedBox(height: 40),
      Wrap(
        spacing: 10,
        children: <Widget>[
          OutlinedButton(onPressed: onFileNew, child: const Text('New File ...')),
          OutlinedButton(onPressed: onFileOpen, child: const Text('Open File ...')),
          OutlinedButton(onPressed: onOpenDemoData, child: const Text('Use Demo Data'))
        ],
      ),
    ]));
  }

  void onSettingsChanged(final Settings settings) {
    settings.fireOnChanged();
  }

  List<KeyAction> getKeyboardBindings(final BuildContext context) {
    return <KeyAction>[
      KeyAction(
        LogicalKeyboardKey.equal,
        'Increase text size',
        () {
          setState(() {
            Settings().fontScaleIncrease();
          });
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
