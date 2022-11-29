import 'package:flutter/material.dart';

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    label: 'Cash Flow',
    tooltip: "Cash Flow",
    icon: Icon(Icons.analytics_outlined),
    selectedIcon: Icon(Icons.analytics),
  ),
  NavigationDestination(
    label: 'Accounts',
    tooltip: "Accounts",
    icon: Icon(Icons.account_balance_outlined),
    selectedIcon: Icon(Icons.account_balance),
  ),
  NavigationDestination(
    label: 'Categories',
    tooltip: "Categories",
    icon: Icon(Icons.type_specimen_outlined),
    selectedIcon: Icon(Icons.type_specimen),
  ),
  NavigationDestination(
    label: 'Payees',
    tooltip: "Payees",
    icon: Icon(Icons.groups_outlined),
    selectedIcon: Icon(Icons.groups),
  ),
  NavigationDestination(
    label: 'Transactions',
    tooltip: "Transactions",
    icon: Icon(Icons.receipt_long_outlined),
    selectedIcon: Icon(Icons.receipt_long),
  ),
  // NavigationDestination(
  //   label: 'Test',
  //   tooltip: "Test",
  //   icon: Icon(Icons.assignment_turned_in_outlined),
  //   selectedIcon: Icon(Icons.assignment_turned_in),
  // )
];

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
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
    )
    .toList();

class NavigationBars extends StatefulWidget {
  final void Function(int) onSelectItem;
  final int selectedIndex;

  const NavigationBars({super.key, required this.onSelectItem, required this.selectedIndex});

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onSelectItem(index);
      },
      destinations: appBarDestinations,
    );
  }
}

class NavigationRailSection extends StatefulWidget {
  final void Function(int) onSelectItem;
  final int selectedIndex;

  const NavigationRailSection({super.key, required this.onSelectItem, required this.selectedIndex});

  @override
  State<NavigationRailSection> createState() => _NavigationRailSectionState();
}

class _NavigationRailSectionState extends State<NavigationRailSection> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      minWidth: 50,
      destinations: navRailDestinations,
      selectedIndex: _selectedIndex,
      useIndicator: false,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onSelectItem(index);
      },
    );
  }
}
