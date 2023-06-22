import 'package:flutter/material.dart';
import 'package:places/UI/screens/components/label_field_text.dart';
import 'package:places/domain/model/place.dart';
import 'package:places/features/place_search/presentation/widgets/search_history_list/components/search_history_items.dart';
import 'package:places/helpers/app_strings.dart';

/// Список истории поиска.
///
/// Содержит элементы истории поиска, кнопку очистки истории поиска.
class SearchHistoryList extends StatelessWidget {
  final Set<Place> searchHistory;
  final VoidCallback? onClearHistoryPressed;
  final ValueSetter<Place>? onHistorySearchItemPressed;
  final ValueSetter<Place>? onDeleteHistorySearchItemPressed;

  const SearchHistoryList({
    Key? key,
    required this.searchHistory,
    this.onClearHistoryPressed,
    this.onHistorySearchItemPressed,
    this.onDeleteHistorySearchItemPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SearchedByYouLabel(),
          SearchHistoryItems(
            searchHistory: searchHistory,
            onClearHistoryPressed: onClearHistoryPressed,
            onHistorySearchItemPressed: onHistorySearchItemPressed,
            onDeleteHistorySearchItemPressed: onDeleteHistorySearchItemPressed,
          ),
        ],
      ),
    );
  }
}

/// Заголовок "вы искали".
class _SearchedByYouLabel extends StatelessWidget {
  const _SearchedByYouLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LabelFieldText(
      AppStrings.searchedByYou,
      padding: EdgeInsets.only(
        left: 16,
        top: 32,
        bottom: 19,
      ),
    );
  }
}
