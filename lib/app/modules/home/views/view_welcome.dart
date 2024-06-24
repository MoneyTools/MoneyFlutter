import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/modules/home/views/app_title.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/modules/home/home_data_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 10,
            children: <Widget>[
              OutlinedButton(
                  onPressed: () {
                    Settings().closeFile();
                    Get.offAllNamed(Constants.routeHomePage);
                  },
                  child: const Text('New File ...')),
              OutlinedButton(
                  onPressed: () {
                    Settings().onFileOpen().then((bool succeeded) {
                      if (succeeded) {
                        Get.offAllNamed(Constants.routeHomePage);
                      }
                    });
                  },
                  child: const Text('Open File ...')),
              OutlinedButton(
                  onPressed: () async {
                    Settings().closeFile();
                    final DataController dataController = Get.find();
                    dataController.loadDemoData().then((_) {
                      Get.offAllNamed(Constants.routeHomePage);
                    });
                  },
                  child: const Text('Use Demo Data'))
            ],
          ),
          gapLarge(),
          const LoadedDataFileAndTime(),
          const Spacer(),
          IntrinsicWidth(
            child: Opacity(
              opacity: 0.5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Constants.routePolicyPage);
                    },
                    child: const Text('Privacy Policy'),
                  ),
                  gapLarge(),
                  TextButton(
                    onPressed: () {
                      showLicensePage(context: context);
                    },
                    child: const Text('Licenses'),
                  ),
                ],
              ),
            ),
          ),
          gapLarge(),
        ],
      ),
    );
  }
}
