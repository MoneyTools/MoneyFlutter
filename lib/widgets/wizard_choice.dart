import 'package:flutter/material.dart';

class WizardChoice extends StatelessWidget {
  final String title;
  final String description;
  final Function onPressed;

  const WizardChoice({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Adjust the value to change the radius
        ),
      ),
      onPressed: () {
        onPressed();
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ListTile(
          title: Text(title),
          titleTextStyle: const TextStyle(fontSize: 20),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(description),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
