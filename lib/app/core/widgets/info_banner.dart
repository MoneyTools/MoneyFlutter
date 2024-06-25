import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';

class InfoBanner extends StatelessWidget {

  const InfoBanner({
    super.key,
    required this.type,
    required this.message,
    required this.icon,
  });

  factory InfoBanner.success(String message) {
    return InfoBanner(
      type: ColorState.success,
      message: message,
      icon: Icons.check_circle,
    );
  }

  factory InfoBanner.warning(String message) {
    return InfoBanner(
      type: ColorState.warning,
      message: message,
      icon: Icons.warning,
    );
  }

  factory InfoBanner.error(String message) {
    return InfoBanner(
      type: ColorState.error,
      message: message,
      icon: Icons.error,
    );
  }
  final ColorState type;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Color color = getColorFromState(type);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
