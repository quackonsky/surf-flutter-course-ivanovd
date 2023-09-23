import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:places/core/helpers/app_assets.dart';
import 'package:places/core/helpers/app_strings.dart';
import 'package:places/core/presentation/widgets/custom_buttons/custom_elevated_button.dart';

/// Кнопка "Построить маршрут".
class BuildRouteButton extends StatelessWidget {
  const BuildRouteButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSecondaryColor = colorScheme.onSecondary;

    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
      ),
      child: CustomElevatedButton(
        text: AppStrings.buildRouteText,
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: onSecondaryColor,
        ),
        backgroundColor: colorScheme.primary,
        height: 48,
        // Картинка кнопки - пока что это просто белый контейнер.
        buttonLabel: SvgPicture.asset(
          AppAssets.route,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            onSecondaryColor,
            BlendMode.srcIn,
          ),
        ),
        // TODO(daniiliv): Здесь будет вызов реальной функции.
        onPressed: () {
          if (kDebugMode) {
            print('"${AppStrings.buildRouteText}" button pressed.');
          }
        },
      ),
    );
  }
}
