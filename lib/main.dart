import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_cashflow.dart';
import 'package:money/views/view_rentals.dart';
import 'package:money/widgets/keyboard_widget.dart';

import 'package:money/appbar.dart';
import 'package:money/models/constants.dart';
import 'package:money/helpers.dart';
import 'package:money/menu.dart';
import 'package:money/models/data.dart';
import 'package:money/views/view_accounts.dart';
import 'package:money/views/view_categories.dart';
import 'package:money/views/view_payees.dart';
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
  }

  bool shouldShowOpenInstructions() {
    if (settings.prefLoaded && settings.pathToDatabase == null) {
      return true;
    }
    return false;
  }

  loadData() {
    data.init(settings.pathToDatabase, (final bool success) {
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
      pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.any,
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        // allowedExtensions: <String>['mmdb', 'sdf', 'qfx', 'ofx', 'pdf', 'json'],
      );
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
        } else {
          // todo: handle qfx, ofx, pdf, json, etc.
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
    setState(() {});
  }

  void handleUseDemoData() async {
    settings.pathToDatabase = Constants.demoData;
    settings.save();
    loadData();
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
        return const ViewTransactions();
      case 5:
        return const ViewRentals();
      case 0:
      default:
        return const ViewCashFlow();
    }
  }

  Widget welcomePanel(final BuildContext context) {
    return Scaffold(
      appBar: createAppBar(settings, handleFileOpen, handleFileClose, onSettingsChanged),
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
        children: <Widget>[OutlinedButton(onPressed: handleFileOpen, child: const Text('Open File ...')), OutlinedButton(onPressed: handleUseDemoData, child: const Text('Use Demo Data'))],
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
                      setState(() {
                        settings.textScale = max(0.5, settings.textScale * 0.90);
                        settings.save();
                      });
                    },
                    isMetaPressed: true,
                  ),
                  KeyAction(
                    LogicalKeyboardKey('0'.codeUnitAt(0)),
                    'Normal text suze',
                    () {
                      setState(() {
                        settings.textScale = 1;
                        settings.save();
                      });
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
      appBar: createAppBar(settings, handleFileOpen, handleFileClose, onSettingsChanged),
      body: Row(children: <Widget>[Expanded(child: getWidgetForMainContent(context, settings.screenIndex))]),
      bottomNavigationBar: MenuHorizontal(settings: settings, onSelectItem: handleScreenChanged, selectedIndex: settings.screenIndex),
    );
  }

  Widget getScaffoldingForLargeSurface(final BuildContext context) {
    return Scaffold(
      appBar: createAppBar(settings, handleFileOpen, handleFileClose, onSettingsChanged),
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
            Expanded(child: Column(children: <Widget>[getWidgetForMainContent(context, settings.screenIndex)]))
          ],
        ),
      ),
    );
  }

  void onSettingsChanged(final Settings settings) {
    setState(() {
      this.settings = settings;
    });
  }
}
