import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers.dart';
import '../models/data.dart';
import '../widgets/header.dart';

class ViewCategories extends StatefulWidget {

  final Data data;

  const ViewCategories({super.key, required this.data});

  @override
  State<ViewCategories> createState() => _ViewCategoriesState(data);
}

class _ViewCategoriesState extends State<ViewCategories> {
  final Data data;
  final formatCurrency = NumberFormat("#,##0.00", "en_US");

  _ViewCategoriesState(this.data);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(children: <Widget>[
              Header("Categories", numValueOrDefault(data.categories.list.length), "Classification of your money transactions."),
              Row(children: <Widget>[
                Expanded(child: Container(color: Theme
                    .of(context)
                    .colorScheme
                    .secondaryContainer, child: Text("Name", textAlign: TextAlign.left, style: textTheme.titleMedium))),
                Expanded(child: Container(color: Theme
                    .of(context)
                    .colorScheme
                    .secondaryContainer, child: Text("Balance", textAlign: TextAlign.right, style: textTheme.titleMedium))),
              ]),
              Expanded(
                  child: ListView.builder(
                      itemCount: data.categories.list.length,
                      itemExtent: 30,
                      // cacheExtent: 30*10000,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(data.categories.list[index].name, textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(formatCurrency.format(0.00), textAlign: TextAlign.right),
                            ),
                          ],
                        );
                      })),
            ])));
  }
}
