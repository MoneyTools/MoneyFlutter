import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_cashflow.dart';
import 'package:money/views/view_rentals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar.dart';
import 'models/constants.dart';
import 'helpers.dart';
import 'menu.dart';
import 'models/data.dart';
import 'views/view_accounts.dart';
import 'views/view_categories.dart';
import 'views/view_payees.dart';
import 'views/view_transactions.dart';
import 'widgets/bottom.dart';

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
  bool isBottomPanelExpanded = false;
  Widget? detailPanelContent;

  @override
  initState() {
    super.initState();
    settings.load(loadData);
  }

  shouldShowOpenInstructions() {
    if (settings.pathToDatabase == null) {
      return true;
    }
    return false;
  }

  loadData() {
    data.init(settings.pathToDatabase, (success) {
      _isLoading = success ? false : true;
      setState(() {
        _isLoading;
        data;
      });
    });
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      settings.screenIndex = selectedScreen;
    });
  }

  void handleFileOpen() async {
    FilePickerResult? fileSelected = await FilePicker.platform.pickFiles();
    if (fileSelected != null) {
      settings.pathToDatabase = fileSelected.paths[0];
      if (settings.pathToDatabase != null) {
        SharedPreferences.getInstance().then((preferences) {
          preferences.setString(prefLastLoadedPathToDatabase, settings.pathToDatabase.toString());
          loadData();
        });
      }
    }
  }

  void handleUseDemoData() async {
    settings.pathToDatabase = Constants.demoData;
    loadData();
  }

  showLoading() {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  onSetDetailContent(Widget? content) {
    setState(() {
      detailPanelContent = content;
    });
  }

  Widget getWidgetForMainContent(BuildContext context, int screenIndex) {
    if (_isLoading) {
      return showLoading();
    }

    switch (screenIndex) {
      case 1:
        return ViewAccounts(setDetailsPanelContent: onSetDetailContent);
      case 2:
        return ViewCategories(setDetailsPanelContent: onSetDetailContent);
      case 3:
        return ViewPayees(setDetailsPanelContent: onSetDetailContent);
      case 4:
        return ViewTransactions(setDetailsPanelContent: onSetDetailContent);
      case 5:
        return ViewRentals(setDetailsPanelContent: onSetDetailContent);
      case 0:
      default:
        return const ViewCashFlow();
    }
  }

  welcomePanel(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(settings, handleFileOpen, onSettingsChanged),
      body: Row(children: <Widget>[
        renderWelcomeAndOpen(context),
      ]),
    );
  }

  renderWelcomeAndOpen(BuildContext context) {
    var textTheme = getTextTheme(context);
    return Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Welcome to MyMoney", textAlign: TextAlign.left, style: textTheme.headline5),
      const SizedBox(height: 40),
      Text("No data loaded", textAlign: TextAlign.left, style: textTheme.caption),
      const SizedBox(height: 40),
      Wrap(
        spacing: 10,
        children: [OutlinedButton(onPressed: handleFileOpen, child: const Text("Open File ...")), OutlinedButton(onPressed: handleUseDemoData, child: const Text("Use Demo Data"))],
      ),
    ]));
  }

  Future<ThemeData> getThemeDataFromPreference() async {
    var preferences = await SharedPreferences.getInstance();
    var materialVersion = intValueOrDefault(preferences.getInt(prefMaterialVersion), defaultValueIfNull: 2);
    var colorSelected = intValueOrDefault(preferences.getInt(prefColor));
    var useDarkMode = boolValueOrDefault(preferences.getBool(prefDarkMode), defaultValueIfNull: false);

    settings.themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      useMaterial3: materialVersion == 3,
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
    return settings.themeData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
        future: getThemeDataFromPreference(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MyMoney',
                theme: snapshot.data,
                home: LayoutBuilder(builder: (context, constraints) {
                  if (shouldShowOpenInstructions()) {
                    return welcomePanel(context);
                  }
                  if (isSmallWidth(constraints)) {
                    return getScaffoldingForSmallSurface(context);
                  } else {
                    return getScaffoldingForLargeSurface(context);
                  }
                }));
          } else {
            // Return loading screen while reading preferences
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  getScaffoldingForSmallSurface(context) {
    return Scaffold(
      appBar: createAppBar(settings, handleFileOpen, onSettingsChanged),
      body: Row(children: <Widget>[
        getWidgetForMainContent(context, settings.screenIndex),
      ]),
      bottomNavigationBar: MenuHorizontal(settings: settings, onSelectItem: handleScreenChanged, selectedIndex: settings.screenIndex),
    );
  }

  getScaffoldingForLargeSurface(context) {
    return Scaffold(
      appBar: createAppBar(settings, handleFileOpen, onSettingsChanged),
      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: MenuVertical(
                settings: settings,
                onSelectItem: handleScreenChanged,
                selectedIndex: settings.screenIndex,
                useIndicator: settings.themeData.useMaterial3,
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
                child: Column(
              children: [
                getWidgetForMainContent(context, settings.screenIndex),
                BottomPanel(
                    details: detailPanelContent,
                    isExpanded: isBottomPanelExpanded,
                    onExpanded: (isExpanded) {
                      setState(() {
                        isBottomPanelExpanded = isExpanded;
                      });
                    })
              ],
            ))
          ],
        ),
      ),
    );
  }

  onSettingsChanged(settings) {
    setState(() {
      this.settings = settings;
    });
  }
}
