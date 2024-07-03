import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/text_title.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              const TextTitle('MyMoney'),
              gapHuge(),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
