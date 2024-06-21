import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/views/view_policy.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/gaps.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = getTextTheme(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Text('No data loaded', style: textTheme.bodySmall!.copyWith(color: getColorTheme(context).onSurface)),
          gapLarge(),
          gapLarge(),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 10,
            children: <Widget>[
              OutlinedButton(
                  onPressed: () {
                    // todo
                    Get.toNamed('/home');
                  },
                  child: const Text('New File ...')),
              OutlinedButton(
                  onPressed: () {
                    Settings().onFileOpen().then((bool succeeded) {
                      if (succeeded) {
                        Get.toNamed('/home');
                      }
                    });
                  },
                  child: const Text('Open File ...')),
              OutlinedButton(
                  onPressed: () {
                    Settings().onOpenDemoData().then((_) {
                      Get.toNamed('/home');
                    });
                  },
                  child: const Text('Use Demo Data'))
            ],
          ),
          const Spacer(),
          IntrinsicWidth(
            child: Opacity(
              opacity: 0.5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      adaptiveScreenSizeDialog(
                        context: context,
                        title: 'Privacy Policy',
                        child: const PolicyScreen(),
                      );
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
