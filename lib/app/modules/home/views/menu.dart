import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/controller/general_controller.dart';

List<NavigationDestination> getAppBarDestinations(final Settings settings) {
  final List<NavigationDestination> appBarDestinations = <NavigationDestination>[
    const NavigationDestination(
      label: 'Cash Flow',
      tooltip: 'Cash Flow',
      icon: Icon(Icons.analytics),
      selectedIcon: Icon(Icons.analytics),
    ),
    NavigationDestination(
      label: 'Accounts',
      tooltip: 'Accounts',
      icon: ViewId.viewAccounts.getIcon(),
      selectedIcon: ViewId.viewAccounts.getIcon(),
    ),
    NavigationDestination(
      label: 'Categories',
      tooltip: 'Categories',
      icon: ViewId.viewCategories.getIcon(),
      selectedIcon: ViewId.viewCategories.getIcon(),
    ),
    NavigationDestination(
      label: 'Payees',
      tooltip: 'Payees',
      icon: ViewId.viewPayees.getIcon(),
      selectedIcon: ViewId.viewPayees.getIcon(),
    ),
    NavigationDestination(
      label: 'Aliases',
      tooltip: 'Aliases',
      icon: ViewId.viewAliases.getIcon(),
      selectedIcon: ViewId.viewAliases.getIcon(),
    ),
    NavigationDestination(
      label: 'Transactions',
      tooltip: 'Transactions',
      icon: ViewId.viewTransactions.getIcon(),
      selectedIcon: ViewId.viewTransactions.getIcon(),
    ),
    NavigationDestination(
      label: 'Transfers',
      tooltip: 'View transfers between accounts',
      icon: ViewId.viewTransfers.getIcon(),
      selectedIcon: ViewId.viewTransfers.getIcon(),
    ),
    NavigationDestination(
      label: 'Investments',
      tooltip: 'Investment transactions',
      icon: ViewId.viewInvestments.getIcon(),
      selectedIcon: ViewId.viewInvestments.getIcon(),
    ),
    NavigationDestination(
      label: 'Stocks',
      tooltip: 'Stocks tracking',
      icon: ViewId.viewStocks.getIcon(),
      selectedIcon: ViewId.viewStocks.getIcon(),
    )
  ];
  if (settings.getPref().includeRentalManagement) {
    appBarDestinations.add(
      NavigationDestination(
        label: 'Rentals',
        tooltip: 'Rentals',
        icon: ViewId.viewRentals.getIcon(),
        selectedIcon: ViewId.viewRentals.getIcon(),
      ),
    );
  }

  return appBarDestinations;
}

List<NavigationRailDestination> getNavRailDestination(final Settings settings) {
  final List<NavigationDestination> list = getAppBarDestinations(settings);

  final Iterable<NavigationRailDestination> navRailDestinations = list.map(
    (final NavigationDestination destination) => NavigationRailDestination(
      icon: Tooltip(
        message: destination.label,
        child: destination.icon,
      ),
      selectedIcon: Tooltip(
        message: destination.label,
        child: destination.selectedIcon,
      ),
      label: Text(destination.label),
    ),
  );
  return navRailDestinations.toList();
}

class MenuHorizontal extends StatefulWidget {
  final void Function(ViewId) onSelected;
  final ViewId selectedView;
  final Settings settings;

  const MenuHorizontal({
    super.key,
    required this.settings,
    required this.onSelected,
    required this.selectedView,
  });

  @override
  State<MenuHorizontal> createState() => MenuHorizontalState();
}

class MenuHorizontalState extends State<MenuHorizontal> {
  ViewId _selectedView = ViewId.viewCashFlow;

  @override
  Widget build(final BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedView.index,
      onDestinationSelected: (final int index) {
        final view = ViewId.values[index];
        setState(() {
          _selectedView = view;
        });
        widget.onSelected(view);
      },
      destinations: getAppBarDestinations(widget.settings),
      height: 52,
      indicatorColor: getColorTheme(context).onSecondary,
      backgroundColor: getColorTheme(context).secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedView = widget.selectedView;
  }
}

class MenuVertical extends StatefulWidget {
  final void Function(ViewId) onSelectItem;
  final ViewId selectedView;
  final bool useIndicator;
  final Settings settings;

  const MenuVertical({
    super.key,
    required this.settings,
    required this.onSelectItem,
    required this.selectedView,
    this.useIndicator = false,
  });

  @override
  State<MenuVertical> createState() => MenuVerticalState();
}

class MenuVerticalState extends State<MenuVertical> {
  ViewId _selectedView = ViewId.viewCashFlow;

  @override
  Widget build(final BuildContext context) {
    bool isVeryLargeDevice = MediaQuery.of(context).size.width > 1000;
    final List<NavigationRailDestination> destinations = getNavRailDestination(widget.settings);
    return Container(
      color: getColorTheme(context).secondaryContainer,
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: NavigationRail(
            minWidth: 50,
            destinations: destinations,
            selectedIndex: _selectedView.index,
            useIndicator: widget.useIndicator,
            labelType: isVeryLargeDevice ? NavigationRailLabelType.all : NavigationRailLabelType.none,
            indicatorColor: getColorTheme(context).onSecondary,
            backgroundColor: getColorTheme(context).secondaryContainer,
            onDestinationSelected: (final int index) {
              final view = ViewId.values[index];
              setState(() {
                _selectedView = view;
              });
              widget.onSelectItem(view);
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedView = widget.selectedView;
  }
}
