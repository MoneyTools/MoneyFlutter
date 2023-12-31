import 'package:flutter/material.dart';

import 'package:money/models/settings.dart';

class MenuHorizontal extends StatefulWidget {
  final void Function(int) onSelectItem;
  final int selectedIndex;
  final Settings settings;

  const MenuHorizontal({super.key, required this.settings, required this.onSelectItem, required this.selectedIndex});

  @override
  State<MenuHorizontal> createState() => _MenuHorizontalState();
}

class _MenuHorizontalState extends State<MenuHorizontal> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(final BuildContext context) {
    return NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (final int index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onSelectItem(index);
        },
        destinations: getAppBarDestinations(widget.settings),
        height: 52,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide);
  }
}

class MenuVertical extends StatefulWidget {
  final void Function(int) onSelectItem;
  final int selectedIndex;
  final bool useIndicator;
  final Settings settings;

  const MenuVertical(
      {super.key,
      required this.settings,
      required this.onSelectItem,
      required this.selectedIndex,
      this.useIndicator = false});

  @override
  State<MenuVertical> createState() => _MenuVerticalState();
}

class _MenuVerticalState extends State<MenuVertical> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(final BuildContext context) {
    final List<NavigationRailDestination> destinations = getNavRailDestination(widget.settings);
    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: NavigationRail(
          minWidth: 50,
          destinations: destinations,
          selectedIndex: _selectedIndex,
          useIndicator: widget.useIndicator,
          onDestinationSelected: (final int index) {
            setState(() {
              _selectedIndex = index;
            });
            widget.onSelectItem(index);
          },
        ),
      ),
    );
  }
}

List<NavigationDestination> getAppBarDestinations(final Settings settings) {
  final List<NavigationDestination> appBarDestinations = <NavigationDestination>[
    const NavigationDestination(
      label: 'Cash Flow',
      tooltip: 'Cash Flow',
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
    ),
    const NavigationDestination(
      label: 'Accounts',
      tooltip: 'Accounts',
      icon: Icon(Icons.account_balance_outlined),
      selectedIcon: Icon(Icons.account_balance),
    ),
    const NavigationDestination(
      label: 'Categories',
      tooltip: 'Categories',
      icon: Icon(Icons.type_specimen_outlined),
      selectedIcon: Icon(Icons.type_specimen),
    ),
    const NavigationDestination(
      label: 'Payees',
      tooltip: 'Payees',
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
    ),
    const NavigationDestination(
      label: 'Transactions',
      tooltip: 'Transactions',
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
    )
  ];
  if (settings.rentals) {
    appBarDestinations.add(const NavigationDestination(
      label: 'Rentals',
      tooltip: 'Rentals',
      icon: Icon(Icons.location_city_outlined),
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
