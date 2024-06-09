import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';

List<NavigationDestination> getAppBarDestinations(final Settings settings) {
  final List<NavigationDestination> appBarDestinations = <NavigationDestination>[
    const NavigationDestination(
      label: 'Cash Flow',
      tooltip: 'Cash Flow',
      icon: Icon(Icons.analytics),
      selectedIcon: Icon(Icons.analytics),
    ),
    const NavigationDestination(
      label: 'Accounts',
      tooltip: 'Accounts',
      icon: Icon(Icons.account_balance),
      selectedIcon: Icon(Icons.account_balance),
    ),
    const NavigationDestination(
      label: 'Categories',
      tooltip: 'Categories',
      icon: Icon(Icons.type_specimen),
      selectedIcon: Icon(Icons.type_specimen),
    ),
    const NavigationDestination(
      label: 'Payees',
      tooltip: 'Payees',
      icon: Icon(Icons.groups),
      selectedIcon: Icon(Icons.groups),
    ),
    const NavigationDestination(
      label: 'Aliases',
      tooltip: 'Aliases',
      icon: Icon(Icons.how_to_reg),
      selectedIcon: Icon(Icons.how_to_reg),
    ),
    const NavigationDestination(
      label: 'Transactions',
      tooltip: 'Transactions',
      icon: Icon(Icons.receipt_long),
      selectedIcon: Icon(Icons.receipt_long),
    ),
    const NavigationDestination(
      label: 'Transfers',
      tooltip: 'View transfers between accounts',
      icon: Icon(Icons.swap_horiz),
      selectedIcon: Icon(Icons.swap_horiz),
    ),
    const NavigationDestination(
      label: 'Investments',
      tooltip: 'Investment transactions',
      icon: Icon(Icons.stacked_line_chart),
      selectedIcon: Icon(Icons.stacked_line_chart),
    ),
    const NavigationDestination(
      label: 'Stocks',
      tooltip: 'Stocks tracking',
      icon: Icon(Icons.candlestick_chart_outlined),
      selectedIcon: Icon(Icons.candlestick_chart_outlined),
    )
  ];
  if (settings.includeRentalManagement) {
    appBarDestinations.add(const NavigationDestination(
      label: 'Rentals',
      tooltip: 'Rentals',
      icon: Icon(Icons.location_city),
      selectedIcon: Icon(Icons.location_city),
    ));
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
