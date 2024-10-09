import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/data/models/constants.dart';
import 'package:money/views/home/sub_views/mru_dropdown.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Get.offAllNamed(Constants.routeHomePage);
                  DataController.to.onFileNew();
                },
                child: const Text('New File ...'),
              ),
              OutlinedButton(
                onPressed: () {
                  DataController.to.onFileOpen().then((final bool succeeded) {
                    if (succeeded) {
                      Get.offAllNamed(Constants.routeHomePage);
                    }
                  });
                },
                child: const Text('Open File ...'),
              ),
              OutlinedButton(
                onPressed: () async {
                  DataController.to.closeFile();
                  final DataController dataController = Get.find();
                  dataController.loadDemoData().then((final _) {
                    Get.offAllNamed(Constants.routeHomePage);
                  });
                },
                child: const Text('Use Demo Data'),
              ),
            ],
          ),
          gapLarge(),
          const MruDropdown(),
          const Spacer(),
          IntrinsicWidth(
            child: Opacity(
              opacity: 0.5,
              child: Row(
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
