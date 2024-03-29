import 'package:flutter/cupertino.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_pending_changes/bage_pending_changes.dart';

class AppCaption extends StatelessWidget {
  final String subCaption;

  const AppCaption({super.key, required this.subCaption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: [
          const Text('MyMoney', textAlign: TextAlign.left),
          const SizedBox(width: 8),
          BadgePendingChanges(
            itemsAdded: Settings().trackMutations.added,
            itemsChanged: Settings().trackMutations.changed,
            itemsDeleted: Settings().trackMutations.deleted,
          )
        ]),
        Text(
          subCaption,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
