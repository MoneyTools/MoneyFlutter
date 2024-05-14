import 'package:flutter/material.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/dialog/dialog.dart';

class PendingChanges extends StatefulWidget {
  const PendingChanges({super.key});

  @override
  State<PendingChanges> createState() => _PendingChangesState();

  static show(final BuildContext context) {
    myShowDialog(
      context: context,
      title: 'Pending Changes',
      child: const SizedBox(width: 600, child: PendingChanges()),
      actionButtons: [],
    );
  }
}

class _PendingChangesState extends State<PendingChanges> {
  final List<Mutations> _data = [
    Mutations(
      typeOfMutation: MutationType.inserted,
      title: 'Added',
      titleColor: Colors.green,
      isExpanded: false,
    ),
    Mutations(
      typeOfMutation: MutationType.changed,
      title: 'Modified',
      titleColor: Colors.orange,
      isExpanded: false,
    ),
    Mutations(
      typeOfMutation: MutationType.deleted,
      title: 'Deleted',
      titleColor: Colors.red,
      isExpanded: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _data[index].isExpanded = isExpanded;
          });
        },
        children: _data.map<ExpansionPanel>((Mutations item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return item.getHeader();
            },
            body: item.getContent(),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }
}

class Mutations {
  MutationType typeOfMutation;
  String title;
  Color titleColor;
  bool isExpanded;
  int count = 0;
  late Widget content;

  Mutations({
    required this.typeOfMutation,
    required this.title, // [Added | Modified | Deleted]
    required this.titleColor,
    required this.isExpanded,
  }) {
    content = getMutatedObject(typeOfMutation);
  }

  Widget getHeader() {
    return ListTile(
      title: Text('$title ($count)'),
      textColor: titleColor,
    );
  }

  Widget getContent() {
    return content;
  }

  Widget getMutatedObject(final MutationType typeOfMutation) {
    List<Widget> widgets = [];
    count = 0;
    for (final MutationGroup mutationGroup in Data().getMutationGroups(typeOfMutation)) {
      count += mutationGroup.whatWasMutated.length;

      widgets.add(ListTile(title: Text('"${mutationGroup.title}"')));

      widgets.add(
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
                width: 3000,
                // height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: mutationGroup.whatWasMutated,
                  ),
                ))),
      );
    }

    if (widgets.isEmpty) {
      return const Center(child: Text('- none -'));
    }

    return Column(children: widgets);
  }
}
