import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/securities/security.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';

class ViewStocks extends ViewWidget {
  const ViewStocks({
    super.key,
  });

  @override
  State<ViewWidget> createState() => ViewStocksState();
}

class ViewStocksState extends ViewWidgetState {
  @override
  String getClassNamePlural() {
    return 'Stocks';
  }

  @override
  String getClassNameSingular() {
    return 'Stock';
  }

  @override
  String getDescription() {
    return 'Stocks tracking.';
  }

  @override
  Fields<Security> getFieldsForTable() {
    return Security.getFields();
  }

  @override
  List<Security> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Security> list = Data().securities.iterableList(includeDeleted).toList();
    return list;
  }
}
