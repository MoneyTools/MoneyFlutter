import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/models/data_io/import_qfx.dart';
import 'package:money/models/data_io/import_qif.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_aliases.dart';
import 'package:money/views/view_cashflow.dart';
import 'package:money/views/view_rentals.dart';
import 'package:money/widgets/keyboard_widget.dart';

import 'package:money/appbar.dart';
import 'package:money/models/constants.dart';
import 'package:money/helpers/helpers.dart';
import 'package:money/menu.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/views/view_accounts/view_accounts.dart';
import 'package:money/views/view_categories.dart';
import 'package:money/views/view_payees/view_payees.dart';
import 'package:money/views/view_transactions.dart';

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
  initState() {
    super.initState();
    settings.load(onLoaded: () {
      loadData();
    });

    settings.onChanged = () {
      // Brute force refresh the app UI
      setState(() {
        _isLoading = true;
      });
      Timer(
        const Duration(milliseconds: 1),
        () {
          setState(() {
            _isLoading = false;
          });
        },
      );
    };
  }

  bool shouldShowOpenInstructions() {
    if (settings.prefLoaded && settings.pathToDatabase == null) {
      return true;
    }
    return false;
  }

  loadData() {
    data.init(
        filePathToLoad: settings.pathToDatabase,
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

  void handleFileOpen() async {
    FilePickerResult? pickerResult;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Special case for Android
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
      } else {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: <String>['mmdb', 'sdf', 'qfx', 'ofx', 'pdf', 'json'],
        );
      }
    } catch (e) {
      debugLog(e.toString());
    }

    if (pickerResult != null) {
      try {
        if (pickerResult.files.single.extension == "mmdb") {
          if (kIsWeb) {
            settings.pathToDatabase = pickerResult.files.single.path;

            final Uint8List? file = pickerResult.files.single.bytes;
            if (file != null) {
              // String s = String.fromCharCodes(file);
              // var outputAsUint8List = new Uint8List.fromList(s.codeUnits);
              // debugLog("--------$s");
            }
          } else {
            settings.pathToDatabase = pickerResult.files.single.path;
          }
          if (settings.pathToDatabase != null) {
            settings.save();
            loadData();
          }
        }
      } catch (e) {
        debugLog(e.toString());
      }
    }
  }

  void handleFileClose() async {
    settings.pathToDatabase = null;
    settings.save();
    data.close();
    settings.fireOnChanged();
  }

  void handleUseDemoData() async {
    settings.pathToDatabase = Constants.demoData;
    settings.save();
    loadData();
  }

  void handleImport() async {
    final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
    if (pickerResult != null) {
      switch (pickerResult.files.single.extension?.toLowerCase()) {
        case "qif":
          importQIF(pickerResult.files.single.path.toString());
        case "qfx":
          importQFX(pickerResult.files.single.path.toString(), data);
      }
      settings.fireOnChanged();
    }
  }

  Widget showLoading() {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  Widget getWidgetForMainContent(final BuildContext context, final int screenIndex) {
    if (_isLoading) {
      return showLoading();
    }

    switch (screenIndex) {
      case 1:
        return const ViewAccounts();
      case 2:
        return const ViewCategories();
      case 3:
        return const ViewPayees();
      case 4:
        return const ViewAliases();
      case 5:
        return const ViewTransactions();
      case 6:
        return const ViewRentals();
      case 0:
      default:
        return const ViewCashFlow();
    }
  }

  Widget welcomePanel(final BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        handleFileOpen,
        handleFileClose,
        handleImport,
      ),
      body: Row(children: <Widget>[
        renderWelcomeAndOpen(context),
      ]),
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
          OutlinedButton(onPressed: handleFileOpen, child: const Text('Open File ...')),
          OutlinedButton(onPressed: handleUseDemoData, child: const Text('Use Demo Data'))
        ],
      ),
    ]));
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
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
                        settings.textScale = min(5, settings.textScale * 1.10);
                        settings.save();
                      });
                    },
                    isMetaPressed: true,
                  ),
                  KeyAction(
                    LogicalKeyboardKey.minus,
                    'Decrease text size',
                    () {
                      settings.textScale = max(0.5, settings.textScale * 0.90);
                      settings.save();
                      settings.fireOnChanged();
                    },
                    isMetaPressed: true,
                  ),
                  KeyAction(
                    LogicalKeyboardKey('0'.codeUnitAt(0)),
                    'Normal text suze',
                    () {
                      settings.textScale = 1;
                      settings.save();
                      settings.fireOnChanged();
                    },
                    isMetaPressed: true,
                  ),
                ],
                child: getContent(context, constraints),
              ));
        }));
  }

  Widget getContent(final BuildContext context, final BoxConstraints constraints) {
    if (shouldShowOpenInstructions()) {
      return welcomePanel(context);
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (isSmallWidth(constraints)) {
        return getScaffoldingForSmallSurface(context);
      } else {
        return getScaffoldingForLargeSurface(context);
      }
    }
  }

  Widget getScaffoldingForSmallSurface(final BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        handleFileOpen,
        handleFileClose,
        handleImport,
      ),
      body: Row(children: <Widget>[Expanded(child: getWidgetForMainContent(context, settings.screenIndex))]),
      bottomNavigationBar:
          MenuHorizontal(settings: settings, onSelectItem: handleScreenChanged, selectedIndex: settings.screenIndex),
    );
  }

  Widget getScaffoldingForLargeSurface(final BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        handleFileOpen,
        handleFileClose,
        handleImport,
      ),
      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: <Widget>[
            MenuVertical(
              settings: settings,
              onSelectItem: handleScreenChanged,
              selectedIndex: settings.screenIndex,
              useIndicator: true,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Column(
                children: <Widget>[getWidgetForMainContent(context, settings.screenIndex)],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onSettingsChanged(final Settings settings) {
    settings.fireOnChanged();
  }
}
