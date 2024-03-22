import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
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
        children: <Widget>[
          Text('Welcome to MyMoney',
              style: textTheme.headlineSmall!.copyWith(color: getColorTheme(context).onBackground)),
          gapLarge(),
          gapLarge(),
          Text('No data loaded', style: textTheme.bodySmall!.copyWith(color: getColorTheme(context).onBackground)),
          gapLarge(),
          gapLarge(),
          Wrap(
            spacing: 10,
            children: <Widget>[
              OutlinedButton(onPressed: onFileNew, child: const Text('New File ...')),
              OutlinedButton(onPressed: onFileOpen, child: const Text('Open File ...')),
              OutlinedButton(onPressed: onOpenDemoData, child: const Text('Use Demo Data'))
            ],
          ),
        ],
      ),
    );
  }
}
