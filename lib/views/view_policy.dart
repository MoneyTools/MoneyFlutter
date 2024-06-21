import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        child: SelectableText(
          style: getTextTheme(context).bodySmall,
          '''
      Privacy Policy for MyMoney App
      
      1. No Information Collected:
      MyMoney does not collect any personal information from its users. We do not require users to provide any personal data such as name, email address, or any other identifying information.
      
      2. Information Usage:
      Since we do not collect any personal information, we do not use or share any information about our users.
      
      3. No Data Logged:
      MyMoney does not log any data from its users.
      
      4. Contact Us:
      If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at questions@vteam.com.
      
      By using MyMoney, you signify your acceptance of this Privacy Policy. If you do not agree to this policy, please do not use our application. Your continued use of the application following the posting of changes to this policy will be deemed your acceptance of those changes.</p>
      ''',
        ),
      ),
    );
  }
}
