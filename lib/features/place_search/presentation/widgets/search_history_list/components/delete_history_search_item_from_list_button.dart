import 'package:flutter/material.dart';
import 'package:places/UI/screens/components/custom_icon_button.dart';
import 'package:places/domain/model/place.dart';

/// Кнопка удаления элемента истории поиска из списка.
class DeleteHistorySearchItemFromListButton extends StatelessWidget {
  final Place place;
  final ValueSetter<Place>? onDeleteHistorySearchItemPressed;

  const DeleteHistorySearchItemFromListButton({
    Key? key,
    required this.place,
    this.onDeleteHistorySearchItemPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;

    return CustomIconButton(
      onPressed: () => onDeleteHistorySearchItemPressed?.call(place),
      icon: Icons.close,
      color: secondaryColor.withOpacity(0.56),
    );
  }
}