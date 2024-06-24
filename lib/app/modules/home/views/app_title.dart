import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/money_model.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/views/view_pending_changes/badge_pending_changes.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/picker_panel.dart';
import 'package:money/app/core/widgets/reveal_content.dart';

import 'package:money/app/core/widgets/token_text.dart';
import 'package:money/app/routes/home_data_controller.dart';

class AppTitle extends StatelessWidget {
  AppTitle({
    super.key,
  }) {
    netWorth = Data().getNetWorth();
  }

  late final MoneyModel netWorth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: [
            IntrinsicWidth(child: _buildNetWorthToggle(context)),
            gapSmall(),
            SizedBox(
              height: 20,
              child: BadgePendingChanges(
                itemsAdded: Settings().trackMutations.added,
                itemsChanged: Settings().trackMutations.changed,
                itemsDeleted: Settings().trackMutations.deleted,
              ),
            ),
          ]),
          LoadedDataFileAndTime(
              filePath: Settings().fileManager.fullPathToLastOpenedFile,
              lastModifiedDateTime: Settings().fileManager.dataFileLastUpdateDateTime),
        ],
      );
    });
  }

  Widget _buildNetWorthToggle(
    final BuildContext context,
  ) {
    return RevealContent(
      textForClipboard: netWorth.toString(),
      widgets: [
        _buildRevealContentOption(context, 'MyMoney', true),
        _buildRevealContentOption(context, netWorth.toShortHand(), false),
        _buildRevealContentOption(context, netWorth.toString(), false),
      ],
    );
  }
}

Widget _buildRevealContentOption(
  final BuildContext context,
  String text,
  final bool hidden,
) {
  Color color = getColorTheme(context).onSurface;
  TextStyle textStyle = TextStyle(fontSize: SizeForText.normal, color: color);

  return Row(
    children: [
      Text(text, style: textStyle),
      gapSmall(),
      Opacity(
          opacity: 0.8,
          child: Icon(
            hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 16,
            color: color,
          )),
    ],
  );
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
    final TokenTextStyle tokenStyle = TokenTextStyle(
      separator: MyFileSystems.pathSeparator,
      separatorPaddingLeft: SizeForPadding.nano,
      separatorPaddingRight: SizeForPadding.nano,
    );
    final PreferenceController preferenceController = Get.find();

    return InkWell(
      onTap: () {
        showPopupSelection(
          context: context,
          title: 'Recent files',
          showLetterPicker: false,
          tokenTextStyle: tokenStyle,
          rightAligned: true,
          width: 600,
          items: preferenceController.mru,
          selectedItem: '',
          onSelected: (final String selectedTextReprentingFileNamePath) {
            DataSource dataSource = DataSource(selectedTextReprentingFileNamePath);
            Settings().loadFileFromPath(dataSource);
            Get.offAllNamed(Constants.routeHomePage);
          },
        );
      },
      child: SingleChildScrollView(
        reverse: true,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TokenText(filePath, style: tokenStyle),
            const Icon(Icons.expand_more),
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
      ),
    );
  }
}