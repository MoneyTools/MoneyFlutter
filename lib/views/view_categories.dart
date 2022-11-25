import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';
import '../models/categories.dart';
import '../models/data.dart';
import '../widgets/header.dart';

class ViewCategories extends StatefulWidget {
  final Data data;

  const ViewCategories({super.key, required this.data});

  @override
  State<ViewCategories> createState() => ViewCategoriesState();
}

class ViewCategoriesState extends State<ViewCategories> {
  final formatCurrency = NumberFormat("#,##0.00", "en_US");

  ViewCategoriesState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = getTextTheme(context).apply(displayColor: getColorTheme(context).onSurface);

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(children: <Widget>[
              Header("Categories", numValueOrDefault(Categories.list.length), "Classification of your money transactions."),
              Row(children: <Widget>[
                Expanded(child: Container(color: getColorTheme(context).secondaryContainer, child: Text("Name", textAlign: TextAlign.left, style: textTheme.titleMedium))),
                Expanded(child: Container(color: getColorTheme(context).secondaryContainer, child: Text("Type", textAlign: TextAlign.center, style: textTheme.titleMedium))),
                Expanded(child: Container(color: getColorTheme(context).secondaryContainer, child: Text("Balance", textAlign: TextAlign.right, style: textTheme.titleMedium))),
              ]),
              Expanded(
                  child: ListView.builder(
                      itemCount: Categories.list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(Categories.list[index].name, textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(Categories.list[index].getTypeAsText(), textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text(getCurrencyText(Categories.list[index].balance), textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }
}
