import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:money/views/view_cashflow.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'helpers.dart';
import 'menu.dart';
import 'models/data.dart';
import 'views/view_accounts.dart';
import 'views/view_categories.dart';
import 'views/view_payees.dart';
import 'views/view_transactions.dart';

void main() {
  runApp(const MyMoney());
}

class MyMoney extends StatefulWidget {
  const MyMoney({super.key});

  @override
  State<MyMoney> createState() => _MyMoneyState();
}

class _MyMoneyState extends State<MyMoney> {
  /* Default theme */
  int colorSelected = indexOfDefaultColor;
  ThemeData themeData = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: colorOptions[indexOfDefaultColor]);
  bool _isLoading = true;
  int screenIndex = 0;
  final Data data = Data();
  String? pathToDatabase;

  @override
  initState() {
    super.initState();
    loadLastPreference();
  }

  loadLastPreference() async {
    SharedPreferences.getInstance().then((preferences) {
      pathToDatabase = preferences.getString(prefLastLoadedPathToDatabase);
      loadData();
    });
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

  isDarkMode() {
    return themeData.brightness == Brightness.dark;
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  void handleFileOpen() async {
    FilePickerResult? fileSelected = await FilePicker.platform.pickFiles();
    if (fileSelected != null) {
      pathToDatabase = fileSelected.paths[0];
      if (pathToDatabase != null) {
        SharedPreferences.getInstance().then((preferences) {
          preferences.setString(prefLastLoadedPathToDatabase, pathToDatabase.toString());
          loadData();
        });
      }
    }
  }

  void handleUseDemoData() async {
    pathToDatabase = Constants.demoData;
    loadData();
  }

  void handleMaterialVersionChange(useVersion3) {
    SharedPreferences.getInstance().then((preferences) {
      setState(() {
        var version = themeData.useMaterial3 ? 2 : 3;
        preferences.setInt(prefMaterialVersion, version);
      });
    });
  }

  void handleBrightnessChange() {
    SharedPreferences.getInstance().then((preferences) {
      setState(() {
        var useDarkMode = !isDarkMode();
        preferences.setBool(prefDarkMode, useDarkMode);
      });
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

    SharedPreferences.getInstance().then((preferences) {
      setState(() {
        preferences.setInt(prefColor, value);
        colorSelected = value;
      });
    });
  }

  showLoading() {
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  Widget getWidgetForMainContent(BuildContext context, int screenIndex) {
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
      case 0:
      default:
        return const ViewCashFlow();
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
          icon: isDarkMode() ? const Icon(Icons.wb_sunny) : const Icon(Icons.mode_night),
          onPressed: handleBrightnessChange,
          tooltip: "Toggle brightness",
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) {
            var l = List.generate(colorOptions.length, (index) {
              return PopupMenuItem(value: index, child: renderIconAndText(Icon(index == colorSelected ? Icons.color_lens : Icons.color_lens_outlined, color: colorOptions[index]), colorText[index]));
            });
            l.add(
              PopupMenuItem(
                value: 1002,
                child: renderIconAndText(Icon(themeData.useMaterial3 ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Material V2"),
              ),
            );
            l.add(
              PopupMenuItem(
                value: 1003,
                child: renderIconAndText(Icon(!themeData.useMaterial3 ? Icons.check_box_outline_blank_outlined : Icons.check_box_outlined, color: Colors.grey), "Material V3"),
              ),
            );
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
      Text(getTitle(), textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
    ]);
  }

  Future<ThemeData> getThemeDataFromPreference() async {
    var preferences = await SharedPreferences.getInstance();
    var materialVersion = intValueOrDefault(preferences.getInt(prefMaterialVersion), defaultValueIfNull: 2);
    var colorSelected = intValueOrDefault(preferences.getInt(prefColor));
    var useDarkMode = boolValueOrDefault(preferences.getBool(prefDarkMode), defaultValueIfNull: false);

    themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      useMaterial3: materialVersion == 3,
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
    return themeData;
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
      appBar: createAppBar(),
      body: Row(children: <Widget>[
        getWidgetForMainContent(context, screenIndex),
      ]),
      bottomNavigationBar: NavigationBars(onSelectItem: handleScreenChanged, selectedIndex: screenIndex),
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
                selectedIndex: screenIndex,
                useIndicator: themeData.useMaterial3,
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            getWidgetForMainContent(context, screenIndex),
          ],
        ),
      ),
    );
  }
}
