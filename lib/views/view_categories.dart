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
      ColumnDefinition("Name", TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.name, b.name, sortAscending);
      }),
      ColumnDefinition("Type", TextAlign.left, (a, b, sortAscending) {
        return sortByString(a.getTypeAsText(), b.getTypeAsText(), sortAscending);
      }),
      ColumnDefinition("Balance", TextAlign.right, (a, b, sortAscending) {
        return sortByValue(a.balance, b.balance, sortAscending);
      }),
    ];
  }

  @override
  getList() {
    return Categories.list;
  }

  @override
  Widget getRow(list, index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(list[index].name, textAlign: TextAlign.left),
        ),
        Expanded(
          child: Text(list[index].getTypeAsText(), textAlign: TextAlign.center),
        ),
        Expanded(
          child: Text(formatCurrency.format(list[index].balance), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
