import 'package:flutter/cupertino.dart';

class WorkingIndicator extends StatelessWidget {
  const WorkingIndicator({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CupertinoActivityIndicator(radius: size),
      ),
    );
  }
}
