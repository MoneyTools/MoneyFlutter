import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/picker_panel.dart';
import 'package:money/app/core/widgets/token_text.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/modules/home/home_data_controller.dart';

class Mru extends StatelessWidget {
  const Mru({super.key});

  @override
  Widget build(BuildContext context) {
    final TokenTextStyle tokenStyle = TokenTextStyle(
      separator: MyFileSystems.pathSeparator,
      separatorPaddingLeft: SizeForPadding.nano,
      separatorPaddingRight: SizeForPadding.nano,
    );
    final PreferenceController preferenceController = Get.find();
    final DataController dataController = Get.find();

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
            TokenText(dataController.currentLoadedFileName.value, style: tokenStyle),
            const Icon(Icons.expand_more),
            // gapMedium(),
            // Text(
            //   dateToDateTimeString(lastModifiedDateTime),
            //   textAlign: TextAlign.left,
            //   overflow: TextOverflow.ellipsis,
            //   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            // ),
            gapMedium(),
          ],
        ),
      ),
    );
  }
}
