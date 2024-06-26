import 'package:flutter/cupertino.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/box.dart';

class NoTransaction extends StatelessWidget {
  const NoTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Box(
        height: 80,
        child: Center(
          child: Text(
            'There are no transactions yet.',
            style: getTextTheme(context).bodyLarge,
          ),
        ),
      ),
    );
  }
}
