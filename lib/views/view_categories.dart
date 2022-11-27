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
  final List<ColumnDefinition> columns = [
    ColumnDefinition("Name", TextAlign.left, () {}),
    ColumnDefinition("Type", TextAlign.left, () {}),
    ColumnDefinition("Balance", TextAlign.right, () {}),
  ];
  @override
  var list = Categories.list;

  @override
  onSort() {
    switch (sortBy) {
      case 0:
        list.sort((a, b) {
          if (sortAscending) {
            return a.name.toUpperCase().compareTo(b.name.toUpperCase());
          } else {
            return b.name.toUpperCase().compareTo(a.name.toUpperCase());
          }
        });
        break;
      case 1:
        list.sort((a, b) {
          if (sortAscending) {
            return a.getTypeAsText().compareTo(b.getTypeAsText());
          } else {
            return b.getTypeAsText().compareTo(a.getTypeAsText());
          }
        });
        break;
      case 2:
        list.sort((a, b) {
          if (sortAscending) {
            return (a.balance - b.balance).toInt();
          } else {
            return (b.balance - a.balance).toInt();
          }
        });
        break;
    }
  }

  @override
  Widget getTitle() {
    return Header("Categories", numValueOrDefault(list.length), "Classification of your money transactions.");
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
