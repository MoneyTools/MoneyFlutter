import 'package:flutter/material.dart';

import '../helpers.dart';
import '../models/categories.dart';
import '../widgets/columns.dart';
import '../widgets/header.dart';
import '../widgets/virtualTable.dart';

class ViewCategories extends MyView {
  const ViewCategories({super.key});

  @override
  State<MyView> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends MyViewState {
  @override
  Widget getTitle() {
    return Header("Categories", numValueOrDefault(list.length), "Classification of your money transactions.");
  }

  @override
  List<ColumnDefinition> getColumnDefinitions() {
    return [
      ColumnDefinition("Name", ColumnType.text, TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      }),
      ColumnDefinition("Type", ColumnType.text, TextAlign.center, (a, b, sortAscending) {
        return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
      }),
      ColumnDefinition("Balance", ColumnType.amount, TextAlign.right, (a, b, sortAscending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      }),
    ];
  }

  @override
  getDefaultSortColumn() {
    return 0; // Sort by name
  }

  @override
  getList() {
    return Categories.list;
  }

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        getCell(0, list[index].name),
        getCell(1, list[index].getTypeAsText()),
        getCell(2, list[index].balance),
      ],
    );
  }
}
