import 'package:flutter/material.dart';
import 'package:places/features/add_place/presentation/widgets/photo_carousel/components/action_item.dart';

/// Возможные действия для добавления фото.
class AddPhotoActions extends StatelessWidget {
  final List<Map<String, String>> actions;

  const AddPhotoActions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBackgroundColor = theme.colorScheme.onBackground;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: onBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map((action) => ActionItem(
          text: action['text']!,
          iconAsset: action['icon']!,
          isLastItem: action['text'] == actions.last['text'],
        ))
            .toList(),
      ),
    );
  }
}