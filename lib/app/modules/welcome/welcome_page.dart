import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/text_title.dart';
import 'package:money/app/modules/home/sub_views/app_scaffold.dart';
import 'package:money/app/modules/welcome/view_welcome.dart';

import 'welcome_controller.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugLog('WelcomeScreen');
    return myScaffold(
      context,
      AppBar(
        title: const TextTitle('Welcome to MyMoney'),
        centerTitle: true,
      ),
      const WelcomeScreen(),
    );
  }
}
