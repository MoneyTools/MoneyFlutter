import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/widgets/text_title.dart';
import 'package:money/app/modules/home/views/view_welcome.dart';

import 'welcome_controller.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextTitle('Welcome to MyMoney'),
        centerTitle: true,
      ),
      body: const WelcomeScreen(),
    );
  }
}
