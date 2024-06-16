import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_pending_changes/badge_pending_changes.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/reveal_content.dart';

class AppCaption extends StatelessWidget {
  final Widget child;
  final MoneyModel netWorth;

  const AppCaption({
    super.key,
    required this.netWorth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: [
          const Text('MyMoney', textAlign: TextAlign.left),
          gapMedium(),
          BadgePendingChanges(
            itemsAdded: Settings().trackMutations.added,
            itemsChanged: Settings().trackMutations.changed,
            itemsDeleted: Settings().trackMutations.deleted,
          ),
          _buildNetWorth(),
        ]),
        child,
      ],
    );
  }

  Widget _buildNetWorth() {
    return RevealContent(
      textForClipboard: netWorth.toString(),
      widgets: [
        const Text('**NetWorth**'),
        Text(netWorth.toShortHand()),
        Text(netWorth.toString()),
      ],
    );
  }
}

class LoadedDataFileAndTime extends StatelessWidget {
  final String filePath;
  final DateTime? lastModifiedDateTime;

  const LoadedDataFileAndTime({
    super.key,
    required this.filePath,
    required this.lastModifiedDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            filePath,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
          gapMedium(),
          Text(
            dateToDateTimeString(lastModifiedDateTime),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          gapMedium(),
        ],
      ),
    );
  }
}
