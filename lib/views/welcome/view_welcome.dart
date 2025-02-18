import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/data/models/constants.dart';
import 'package:money/views/home/sub_views/mru_dropdown.dart';

/// The `WelcomeScreen` is a `StatelessWidget` that represents the welcome screen of the application.
/// It provides the user with options to create a new file, open an existing file, or use demo data.
class WelcomeScreen extends StatelessWidget {
  /// Constructs a new instance of the `WelcomeScreen` widget.
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
                  Get.offAllNamed<dynamic>(Constants.routeHomePage);
                  DataController.to.onFileNew();
                },
                child: const Text('New File ...'),
              ),
              OutlinedButton(
                onPressed: () {
                  DataController.to.onFileOpen().then((final bool succeeded) {
                    if (succeeded) {
                      Get.offAllNamed<dynamic>(Constants.routeHomePage);
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
                    Get.offAllNamed<dynamic>(Constants.routeHomePage);
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
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.toNamed<dynamic>(Constants.routePolicyPage);
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
