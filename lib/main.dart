import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'helpers.dart';
import 'menu.dart';
import 'models/data.dart';
import 'views/view_accounts.dart';
import 'views/view_categories.dart';
import 'views/view_payees.dart';
import 'views/view_transactions.dart';

const prefLastLoadedPathToDatabase = 'lastLoadedPathToDatabase';
const prefColor = 'color';
const prefDarkMode = 'darkMode';

void main() {
  runApp(const MyMoney());
}

class MyMoney extends StatefulWidget {
  const MyMoney({super.key});

  @override
  State<MyMoney> createState() => _MyMoneyState();
}

class _MyMoneyState extends State<MyMoney> {
  bool _isLoading = true;
  bool useMaterial3 = true;
  bool useLightMode = true;
  int colorSelected = 0;
  int screenIndex = 0;
  final Data data = Data();
  String? pathToDatabase;
  SharedPreferences? preferences;

  late ThemeData themeData;

  @override
  initState() {
    super.initState();
    themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    loadLastPreference();
  }

  loadLastPreference() async {
    // Obtain shared preferences.
    preferences = await SharedPreferences.getInstance();
    if (preferences != null) {
      colorSelected = intValueOrDefault(preferences?.getInt(prefColor));
      useLightMode = intValueOrDefault(preferences?.getInt(prefDarkMode)) == 1;

      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
      pathToDatabase = preferences?.getString(prefLastLoadedPathToDatabase);
      await Future.delayed(const Duration(seconds: 1), loadData());

      setState(() {
        pathToDatabase;
        themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
      });
    }
  }

  shouldShowOpenInstructions() {
    if (pathToDatabase == null) {
      return true;
    }
    return false;
  }

  loadData() {
    data.init(pathToDatabase, (success) {
      _isLoading = success ? false : true;
      setState(() {
        _isLoading;
        data;
      });
    });
  }

  ThemeData updateThemes(int colorIndex, bool useMaterial3, bool useLightMode) {
    return ThemeData(
        colorSchemeSeed: colorOptions[colorSelected],
        useMaterial3: useMaterial3,
        brightness: useLightMode ? Brightness.light : Brightness.dark);
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void handleBrightnessChange() {
    preferences?.setInt(prefDarkMode, useLightMode ? 0 : 1);

    setState(() {
      useLightMode = !useLightMode;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  void handleFileOpen() async {
    FilePickerResult? fileSelected = await FilePicker.platform.pickFiles();
    if (fileSelected != null) {
      pathToDatabase = fileSelected.paths[0];
      if (pathToDatabase != null) {
        preferences?.setString(
            prefLastLoadedPathToDatabase, pathToDatabase.toString());
        loadData();
      }
    }
  }

  void handleUseDemoData() async {
    pathToDatabase = Constants.demoData;
    loadData();
  }

  void handleMaterialVersionChange(useVersion3) {
    setState(() {
      useMaterial3 = useVersion3;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  void handleColorSelect(int value) {
    if (value == 1002) {
      handleMaterialVersionChange(false);
      return;
    }
    if (value == 1003) {
      handleMaterialVersionChange(true);
      return;
    }

    preferences?.setInt(prefColor, value);

    setState(() {
      colorSelected = value;
      themeData = updateThemes(colorSelected, useMaterial3, useLightMode);
    });
  }

  showLoading() {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  Widget getWidgetForMainContent(
      BuildContext context, int screenIndex, bool showNavBarExample) {
    if (_isLoading) {
      return showLoading();
    }

    switch (screenIndex) {
      // Accounts
      case 0:
        return ViewAccounts(data: data);
      // Categories
      case 1:
        return ViewCategories(data: data);
      // Payees
      case 2:
        return ViewPayees(data: data);
      case 3:
      default:
        return ViewTransactions(data: data);
    }
  }

  welcomePanel(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(),
      body: Row(children: <Widget>[
        renderWelcomeAndOpen(context),
      ]),
    );
  }

  renderWelcomeAndOpen(BuildContext context) {
    var textTheme = getTextTheme(context);
    return Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Welcome to MyMoney",
          textAlign: TextAlign.left, style: textTheme.headline5),
      const SizedBox(height: 40),
      Text("No data loaded",
          textAlign: TextAlign.left, style: textTheme.caption),
      const SizedBox(height: 40),
      Wrap(
        spacing: 10,
        children: [
          OutlinedButton(
              onPressed: handleFileOpen, child: const Text("Open File ...")),
          OutlinedButton(
              onPressed: handleUseDemoData, child: const Text("Use Demo Data"))
        ],
      ),
    ]));
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: widgetMainTitle(),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_open),
          onPressed: handleFileOpen,
          tooltip: "Open mmdb file",
        ),
        IconButton(
          icon: useLightMode
              ? const Icon(Icons.wb_sunny_outlined)
              : const Icon(Icons.wb_sunny),
          onPressed: handleBrightnessChange,
          tooltip: "Toggle brightness",
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) {
            var l = List.generate(colorOptions.length, (index) {
              return PopupMenuItem(
                  value: index,
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          index == colorSelected
                              ? Icons.color_lens
                              : Icons.color_lens_outlined,
                          color: colorOptions[index],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(colorText[index]))
                    ],
                  ));
            });
            l.add(PopupMenuItem(
                value: 1002,
                child: Text(!useMaterial3
                    ? "Using Material2"
                    : "Switch to Material2")));
            l.add(PopupMenuItem(
                value: 1003,
                child: Text(
                    useMaterial3 ? "Using Material3" : "Switch to Material3")));
            return l;
          },
          onSelected: handleColorSelect,
        ),
      ],
    );
  }

  String getTitle() {
    if (pathToDatabase == null) {
      return "No file loaded";
    } else {
      return pathToDatabase.toString();
    }
  }

  widgetMainTitle() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("MyMoney", textAlign: TextAlign.left),
      Text(getTitle(),
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyMoney',
      themeMode: useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: themeData,
      home: LayoutBuilder(builder: (context, constraints) {
        if (shouldShowOpenInstructions()) {
          return welcomePanel(context);
        }

        if (isSmallWidth(constraints)) {
          return getScaffoldingForSmallSurface(context);
        } else {
          return getScaffoldingForLargeSurface(context);
        }
      }),
    );
  }

  getScaffoldingForSmallSurface(context) {
    return Scaffold(
      appBar: createAppBar(),
      body: Row(children: <Widget>[
        getWidgetForMainContent(context, screenIndex, false),
      ]),
      bottomNavigationBar: NavigationBars(
          onSelectItem: handleScreenChanged, selectedIndex: screenIndex),
    );
  }

  getScaffoldingForLargeSurface(context) {
    return Scaffold(
      appBar: createAppBar(),
      body: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: NavigationRailSection(
                    onSelectItem: handleScreenChanged,
                    selectedIndex: screenIndex)),
            const VerticalDivider(thickness: 1, width: 1),
            getWidgetForMainContent(context, screenIndex, true),
          ],
        ),
      ),
    );
  }
}
