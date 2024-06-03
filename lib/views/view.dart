import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_header.dart';

class ViewWidget extends StatefulWidget {
  const ViewWidget({super.key});

  @override
  State<ViewWidget> createState() => ViewWidgetState();
}

class ViewWidgetState extends State<ViewWidget> {
  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        return buildViewContent(const Center(child: Text('Content goes here')));
      },
    );
  }

  Widget buildHeader([final Widget? child]) {
    return ViewHeader(
      title: getClassNamePlural(),
      itemCount: 0,
      selectedItems: ValueNotifier<List<int>>([]),
      description: getDescription(),
      onFilterChanged: null,
      child: child,
    );
  }

  /// To be overridden by the derived view
  Widget buildViewContent(final Widget child) {
    return Container(
      color: getColorTheme(context).surface,
      child: child,
    );
  }

  String getClassNamePlural() {
    return 'Items';
  }

  String getClassNameSingular() {
    return 'Item';
  }

  String getDescription() {
    return 'Default list of items';
  }

  @override
  void initState() {
    super.initState();

    final MyJson? viewSetting = Settings().views[getClassNameSingular()];
    if (viewSetting != null) {}
  }

  void saveLastUserActionOnThisView() {
    // Persist users choice
    Settings().views[getClassNameSingular()] = <String, dynamic>{};

    Settings().preferrenceSave();
  }
}
