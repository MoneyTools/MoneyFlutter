import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/date_helper.dart';
import 'package:money/core/helpers/file_systems.dart';
import 'package:money/core/widgets/picker_panel.dart';
import 'package:money/core/widgets/token_text.dart';
import 'package:money/data/models/constants.dart';

class MruDropdown extends StatelessWidget {
  const MruDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final TokenTextStyle tokenStyle = TokenTextStyle(
      separator: MyFileSystems.pathSeparator,
      separatorPaddingLeft: SizeForPadding.nano,
      separatorPaddingRight: SizeForPadding.nano,
    );
    final PreferenceController preferenceController = Get.find();
    final DataController dataController = Get.find();

    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            InkWell(
              key: Constants.keyMruButton,
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
                  onSelected:
                      (
                        final String selectedTextRepresentingFileNamePath,
                      ) async {
                        final DataSource dataSource = DataSource(
                          filePath: selectedTextRepresentingFileNamePath,
                        );
                        await DataController.to.loadFileFromPath(dataSource);
                        Get.offAllNamed<dynamic>(Constants.routeHomePage);
                      },
                );
              },
              child: Row(
                children: <Widget>[
                  TokenText(
                    dataController.currentLoadedFileName.value,
                    style: tokenStyle,
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
            _buildTimeStampOfFile(
              dataController.currentLoadedFileDateTime.value,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTimeStampOfFile(final DateTime? dataSourceTimeStamp) {
    if (dataSourceTimeStamp == null) {
      return const SizedBox();
    } else {
      return Tooltip(
        message: dateToDateTimeString(dataSourceTimeStamp),
        child: Opacity(
          opacity: 0.5,
          child: Text(
            getElapsedTime(dataSourceTimeStamp),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
