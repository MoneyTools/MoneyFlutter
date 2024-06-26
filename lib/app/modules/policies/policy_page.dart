import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/text_title.dart';
import 'package:money/app/modules/policies/view_policy.dart';

class PolicyPage extends GetView<GetxController> {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextTitle('Policy'),
        centerTitle: true,
      ),
      body: Container(
        color: getColorTheme(context).surface,
        child: const SafeArea(
          child: PolicyScreen(),
        ),
      ),
    );
  }
}
