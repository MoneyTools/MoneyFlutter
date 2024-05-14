import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_header.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';
import 'package:money/widgets/widgets.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  State<ViewWidget> createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  @override
  void initState() {
    super.initState();

    final MyJson? viewSetting = Settings().views[getClassNameSingular()];
    if (viewSetting != null) {}
  }

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        return buildViewContent(const Center(child: Text('Content goes here')));
      },
    );
  }

  /// To be overridden by the derived view
  Widget buildViewContent(final Widget child) {
    return Container(
      color: getColorTheme(context).background,
      child: child,
    );
  }

  Widget buildHeader([final Widget? child]) {
    return ViewHeader(
      title: getClassNamePlural(),
      count: numValueOrDefault(0),
      description: getDescription(),
      onFilterChanged: null,
      child: child,
    );
  }

  String getClassNameSingular() {
    return 'Item';
  }

  String getClassNamePlural() {
    return 'Items';
  }

  String getDescription() {
    return 'Default list of items';
  }

  String getCurrency() {
    // default currency for this view
    return Constants.defaultCurrency;
  }

  List<MoneyObject> getList({bool includeDeleted = false, bool applyFilter = true}) {
    return <MoneyObject>[];
  }

  void clearSelection() {
    //_selectedItemsByUniqueId.value.clear();
  }

  void onDeleteRequestedByUser(final BuildContext context, final MoneyObject? myMoneyObjectInstance) {
    if (myMoneyObjectInstance != null) {
      showDialog(
        context: context,
        builder: (final BuildContext context) {
          return Center(
            child: DeleteConfirmationDialog(
              title: 'Delete ${getClassNameSingular()}',
              question: 'Are you sure you want to delete this ${getClassNameSingular()}?',
              content: Column(
                children: myMoneyObjectInstance.buildWidgets(onEdit: null, compact: true),
              ),
              onConfirm: () {
                onDeleteConfirmedByUser(myMoneyObjectInstance);
              },
            ),
          );
        },
      );
    }
  }

  void onDeleteConfirmedByUser(final MoneyObject instance) {
    // Derived view need to make the actual delete operation
  }

  void saveLastUserActionOnThisView() {
    // Persist users choice
    Settings().views[getClassNameSingular()] = <String, dynamic>{};

    Settings().store();
  }
}
