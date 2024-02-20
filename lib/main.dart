import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/storage/import/import_pdf.dart';
import 'package:money/storage/import/import_qfx.dart';
import 'package:money/storage/import/import_qif.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_aliases/view_aliases.dart';
import 'package:money/views/view_cashflow/view_cashflow.dart';
import 'package:money/views/view_loans/view_loans.dart';
import 'package:money/views/view_rentals/view_rentals.dart';
import 'package:money/widgets/keyboard_widget.dart';
import 'package:money/appbar.dart';
import 'package:money/models/constants.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/menu.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_accounts/view_accounts.dart';
import 'package:money/views/view_categories/view_categories.dart';
import 'package:money/views/view_payees/view_payees.dart';
import 'package:money/views/view_transactions/view_transactions.dart';
import 'package:money/widgets/snack_bar.dart';

void main() {
  runApp(const MyMoney());
}

class MyMoney extends StatefulWidget {
  const MyMoney({super.key});

  @override
  State<MyMoney> createState() => _MyMoneyState();
}

class _MyMoneyState extends State<MyMoney> {
  Settings settings = Settings();
  bool _isLoading = true;
  final Data data = Data();

  @override
  void initState() {
    super.initState();
    settings.load(onLoaded: () {
      loadData();
    });

    settings.onChanged = () {
      // force refresh the app UI
      setState(() {
        settings = Settings();
        // _isLoading = true;
      });
    };
  }

  @override
  Widget build(final BuildContext context) {
    Settings().isSmallDevice = MediaQuery.of(context).size.width < 800;

    return MaterialApp(
        scaffoldMessengerKey: SnackBarService.scaffoldKey,

        /// Assign Key Here
        debugShowCheckedModeBanner: false,
        title: 'MyMoney',
        theme: settings.getThemeData(),
        home: LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
              data: data.copyWith(textScaler: TextScaler.linear(settings.textScale)),
              child: KeyboardWidget(
                columnCount: 1,
                bindings: <KeyAction>[
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
                    'Normal text suze',
                    () {
                      Settings().setFontScaleTo(1);
                    },
                    isMetaPressed: true,
                  ),
                ],
                child: Container(
                  key: Key('key_data_version_${Data().version}'),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: buildContent(context, constraints),
                ),
              ));
        }));
  }

  Widget buildContent(final BuildContext context, final BoxConstraints constraints) {
    if (shouldShowOpenInstructions()) {
      return welcomePanel(context);
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (Settings().isSmallDevice) {
        return buildContentForSmallSurface(context);
      } else {
        return buildContentForLargeSurface(context);
      }
    }
  }

  Widget buildContentForSmallSurface(final BuildContext context) {
    return myScaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
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
        ),
      ),
    );
  }

  Widget buildContentForLargeSurface(final BuildContext context) {
    return myScaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
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
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: getWidgetForMainContent(context, settings.screenIndex),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool shouldShowOpenInstructions() {
    if (settings.prefLoaded && data.fullPathToDataSource == null) {
      return true;
    }
    return false;
  }

  void loadData() {
    data.loadFromPath(
        filePathToLoad: settings.lastOpenedDataSource,
        callbackWhenLoaded: (final bool success) {
          _isLoading = false;
          setState(() {
            _isLoading;
            data;
          });
        });
  }

  void handleScreenChanged(final int selectedScreen) {
    setState(() {
      settings.screenIndex = selectedScreen;
    });
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
        if (pickerResult.files.single.extension == 'mmdb') {
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
      case 1:
        return const ViewAccounts();
      case 2:
        return const ViewLoans();
      case 3:
        return const ViewCategories();
      case 4:
        return const ViewPayees();
      case 5:
        return const ViewAliases();
      case 6:
        return const ViewTransactions();
      case 7:
        return const ViewRentals();
      case 0:
      default:
        return const ViewCashFlow();
    }
  }

  Widget welcomePanel(final BuildContext context) {
    return myScaffold(
      body: Row(
        children: <Widget>[
          renderWelcomeAndOpen(context),
        ],
      ),
    );
  }

  Widget myScaffold({
    required final Widget body,
    final Widget? bottomNavigationBar,
  }) {
    return Scaffold(
      appBar: MyAppBar(
        onFileOpen: onFileOpen,
        onFileClose: onFileClose,
        onShowFileLocation: onShowFileLocation,
        onImport: onImport,
        onSaveCsv: onSaveToCav,
        onSaveSql: onSaveToSql,
      ),
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
          OutlinedButton(onPressed: onFileOpen, child: const Text('Open File ...')),
          OutlinedButton(onPressed: onOpenDemoData, child: const Text('Use Demo Data'))
        ],
      ),
    ]));
  }

  void onSettingsChanged(final Settings settings) {
    settings.fireOnChanged();
  }
}
