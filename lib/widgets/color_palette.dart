import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/widgets/gaps.dart';

/*
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? background,
    Color? onBackground,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? shadow,
    Color? scrim,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? surfaceTint,
 */
class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildColorBar(
          context,
          Colors.black,
          Colors.white,
          'white',
          'black',
        ),
        _buildColorBar(
          context,
          Colors.white,
          Colors.black,
          'black',
          'white',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).surface,
          getColorTheme(context).onSurface,
          'onSurface',
          'surface',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).inverseSurface,
          getColorTheme(context).onInverseSurface,
          'onInverseSurface',
          'inverseSurface',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).surfaceVariant,
          getColorTheme(context).onSurfaceVariant,
          'onSurfaceVariant',
          'surfaceVariant',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).primary,
          getColorTheme(context).onPrimary,
          'onPrimary',
          'primary',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).primaryContainer,
          getColorTheme(context).onPrimaryContainer,
          'onPrimaryContainer',
          'primaryContainer',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).secondary,
          getColorTheme(context).onSecondary,
          'onSecondaryContainer',
          'secondaryContainer',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).secondaryContainer,
          getColorTheme(context).onSecondaryContainer,
          'onSecondaryContainer',
          'secondaryContainer',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).tertiary,
          getColorTheme(context).onTertiary,
          'onTertiary',
          'tertiary',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).tertiaryContainer,
          getColorTheme(context).onTertiaryContainer,
          'onTertiaryContainer',
          'tertiaryContainer',
        ),
        _buildColorBar(
          context,
          getColorTheme(context).errorContainer,
          getColorTheme(context).onErrorContainer,
          'onErrorContainer',
          'errorContainer',
        ),
      ],
    );
  }

  Widget _buildColorBar(
    final BuildContext context,
    final Color background,
    final Color foreground,
    final String colorNameForeground,
    final String colorNameBackground,
  ) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: DottedBorder(
        radius: const Radius.circular(3),
        color: Colors.grey.withOpacity(0.5),
        child: SizedBox(
          width: 300,
          height: 70,
          child: Container(
            margin: const EdgeInsets.all(4),
            color: background,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(colorNameBackground, style: getTextTheme(context).bodyMedium!.copyWith(color: foreground)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          height: 10,
                          color: foreground,
                        ),
                      ),
                      gapSmall(),
                      Text(colorNameForeground, style: getTextTheme(context).bodyMedium!.copyWith(color: foreground)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
