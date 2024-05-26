import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/views/view_policy.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/gaps.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onFileNew;
  final VoidCallback onFileOpen;
  final VoidCallback onOpenDemoData;

  const WelcomeScreen({
    super.key,
    required this.onFileNew,
    required this.onFileOpen,
    required this.onOpenDemoData,
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
          Text('Welcome to MyMoney', style: textTheme.headlineSmall!.copyWith(color: getColorTheme(context).onSurface)),
          gapLarge(),
          gapLarge(),
          Text('No data loaded', style: textTheme.bodySmall!.copyWith(color: getColorTheme(context).onSurface)),
          gapLarge(),
          gapLarge(),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 10,
            children: <Widget>[
              OutlinedButton(onPressed: onFileNew, child: const Text('New File ...')),
              OutlinedButton(onPressed: onFileOpen, child: const Text('Open File ...')),
              OutlinedButton(onPressed: onOpenDemoData, child: const Text('Use Demo Data'))
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
