import 'package:flutter/cupertino.dart';

class WorkingIndicator extends StatelessWidget {
  const WorkingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CupertinoActivityIndicator(radius: 30),
      ),
    );
  }
}
