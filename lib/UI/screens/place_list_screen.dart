import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:places/UI/screens/components/custom_app_bar.dart';
import 'package:places/UI/screens/components/custom_bottom_navigation_bar.dart';
import 'package:places/UI/screens/components/custom_elevated_button.dart';
import 'package:places/UI/screens/components/search_bar.dart';
import 'package:places/UI/screens/components/place_card/place_card.dart';
import 'package:places/UI/screens/place_filters_screen.dart';
import 'package:places/data/model/place.dart';
import 'package:places/helpers/app_assets.dart';
import 'package:places/helpers/app_colors.dart';
import 'package:places/helpers/app_router.dart';
import 'package:places/helpers/app_strings.dart';
import 'package:places/mocks.dart' as mocked;
import 'package:places/utils/work_with_places_mixin.dart';

/// Экран списка мест.
class PlaceListScreen extends StatefulWidget {
  const PlaceListScreen({Key? key}) : super(key: key);

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

/// Состояние экрана списка мест.
///
/// Обновляет список при добавлении нового места.
/// Хранит в себе значения фильтров.
class _PlaceListScreenState extends State<PlaceListScreen> with WorkWithPlaces {
  late List<Place> places;
  late List<Map<String, Object>> placeTypeFilters;
  late double distanceFrom;
  late double distanceTo;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      // Скрываем боттом бар при горизонтальной ориентации.
      bottomNavigationBar: orientation == Orientation.landscape
          ? null
          : const CustomBottomNavigationBar(),
      body: _InheritedPlaceListScreenState(
        data: this,
        child: const _PlaceListBody(),
      ),
      floatingActionButton: _AddNewPlaceButton(
        onPressed: () => openAddPlaceScreen(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    super.initState();

    // Установим фильтры по умолчанию.
    distanceFrom = minRangeValue;
    distanceTo = maxRangeValue;

    // Категории по умолчанию.
    placeTypeFilters = PlaceTypes.values.map((placeType) {
      return <String, Object>{
        'name': placeType.name,
        'imagePath': placeType.imagePath,
        'selected': true,
      };
    }).toList();

    final range = {
      'distanceFrom': distanceFrom,
      'distanceTo': distanceTo,
    };
    // Фильтрация мест на основании инициализированных фильтров.
    // TODO(daniiliv): Пока в качестве источника данных - моковые данные.
    places = getFilteredByTypeAndRadiusPlaces(
      mocked.places,
      placeTypeFilters,
      mocked.userCoordinates,
      range,
    );
  }

  /// Открывает экран добавления места.
  ///
  /// Если было создана новое место, добавляет его в список моковых мест и обновляет экран.
  Future<void> openAddPlaceScreen(BuildContext context) async {
    final newPlace = await Navigator.pushNamed<Place?>(
      context,
      AppRouter.addPlace,
    );

    if (newPlace != null) {
      mocked.places.add(newPlace);

      final range = {
        'distanceFrom': distanceFrom,
        'distanceTo': distanceTo,
      };

      // Обновить новый список мест в сооветствии с фильтрами.
      // TODO(daniiliv): В качестве источника фильтрации используем моковые данные.
      places = getFilteredByTypeAndRadiusPlaces(
        mocked.places,
        placeTypeFilters,
        mocked.userCoordinates,
        range,
      );

      setState(() {});
    }
  }

  /// Применяет переданные фильтры к списку мест.
  void applyFilters(
    List<Map<String, Object>> selectedPlaceTypes,
    double distanceFrom,
    double distanceTo,
  ) {
    final range = {
      'distanceFrom': distanceFrom,
      'distanceTo': distanceTo,
    };
    // TODO(daniiliv): В качестве списка, к которому применяются фильтры, пока что устанавливаем моковые данные.
    places = getFilteredByTypeAndRadiusPlaces(
      mocked.places,
      selectedPlaceTypes,
      mocked.userCoordinates,
      range,
    );

    setState(() {});
  }

  /// Сохраняет переданные фильтры в виджете-состоянии.
  void saveFilters(
    List<Map<String, Object>> placeTypeFilters,
    double distanceFrom,
    double distanceTo,
  ) {
    this.placeTypeFilters = placeTypeFilters;
    this.distanceFrom = distanceFrom;
    this.distanceTo = distanceTo;
  }
}

/// Прокидывает данные [data] вниз по дереву.
/// Оповещает дочерние виджеты о перерисовке при изменении списка мест.
class _InheritedPlaceListScreenState extends InheritedWidget {
  final _PlaceListScreenState data;

  const _InheritedPlaceListScreenState({
    Key? key,
    required Widget child,
    required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedPlaceListScreenState old) {
    // Перерисовка экрана, если список мест обновился.
    return listEquals(old.data.places, data.places);
  }

  static _PlaceListScreenState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<
            _InheritedPlaceListScreenState>() as _InheritedPlaceListScreenState)
        .data;
  }
}

/// Отображает список мест.
class _PlaceListBody extends StatelessWidget {
  const _PlaceListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataStorage = _InheritedPlaceListScreenState.of(context);
    final places = dataStorage.places;

    return CustomScrollView(
      slivers: [
        const _SliverAppBar(),
        _SliverPlaceList(places: places),
      ],
    );
  }
}

/// Кастомный аппбар на сливере.
class _SliverAppBar extends StatelessWidget {
  const _SliverAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SliverPersistentHeader(
      pinned: true,
      delegate: _CustomAppBarDelegate(expandedHeight: 245),
    );
  }
}

/// Делегат кастомного аппбара.
///
/// По умолчанию аппбар состоит из крупного заголовка и строки поиска мест.
/// При сужении аппбара строка поиска мест становится невидимой, заголовок аппбара уменьшается.
class _CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 150;

  const _CustomAppBarDelegate({
    required this.expandedHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Вычисление значений параметров аппбара в зависимости от того, начал ли аппбар сужаться.
    final isScrollStarted = shrinkOffset > 0;
    final theme = Theme.of(context);
    final title = isScrollStarted
        ? AppStrings.placeListAppBarTitle
        : AppStrings.placeListAppBarTitleWithLineBreak;
    final titleTextStyle =
        isScrollStarted ? theme.textTheme.subtitle1 : theme.textTheme.headline4;
    final centerTitle = isScrollStarted;

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: CustomAppBar(
            title: title,
            titleTextStyle: titleTextStyle,
            centerTitle: centerTitle,
            toolbarHeight: 128,
            padding: EdgeInsets.only(
              // При сужении аппбара убираются отступы у аппбара.
              top: isScrollStarted ? 0 : 40,
              bottom: isScrollStarted ? 0 : 16,
            ),
          ),
        ),
        Expanded(
          child: Opacity(
            // При сужении аппбара строка поиска становится невидимой.
            opacity: 1 - shrinkOffset / expandedHeight,
            child: SearchBar(
              readOnly: true,
              // Не обрабатывать нажатия, когда строка поиска уже скрыта.
              onTap: isScrollStarted
                  ? null
                  : () => navigateToPlaceSearchScreen(context),
              suffixIcon: _FilterButton(
                isButtonDisabled: isScrollStarted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  /// Открывает экран поиска мест.
  void navigateToPlaceSearchScreen(BuildContext context) {
    final dataStorage = _InheritedPlaceListScreenState.of(context);

    Navigator.pushNamed(
      context,
      AppRouter.placeSearch,
      arguments: {
        'placeTypeFilters': dataStorage.placeTypeFilters,
        'distanceFrom': dataStorage.distanceFrom,
        'distanceTo': dataStorage.distanceTo,
      },
    );
  }
}

/// Список достопримечательностей на сливере.
class _SliverPlaceList extends StatelessWidget {
  final List<Place> places;

  const _SliverPlaceList({
    Key? key,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final screenHeight = mediaQuery.size.height;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        childCount: places.length,
        (_, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PlaceCard(places[index]),
          );
        },
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Для горизонтальной ориентации отображаем 2 ряда карточек.
        crossAxisCount: orientation == Orientation.portrait ? 1 : 2,
        mainAxisExtent: orientation == Orientation.portrait
            ? screenHeight * 0.3
            : screenHeight * 0.65,
      ),
    );
  }
}

/// Кнопка фильтрации достопримечательностей.
///
/// Открывает экран фильтрации, после закрытия которого применяются выбранные фильтры и обновляется текущий экран.
class _FilterButton extends StatelessWidget {
  final bool isButtonDisabled;

  const _FilterButton({
    Key? key,
    this.isButtonDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: SvgPicture.asset(
        AppAssets.filter,
        fit: BoxFit.none,
        color: theme.colorScheme.primary,
      ),
      color: theme.primaryColorDark,
      onPressed:
          isButtonDisabled ? null : () => navigateToFiltersScreen(context),
    );
  }

  /// Открывает экран фильтрации мест.
  ///
  /// После выбора фильтров сохраняет их в стейте текущего экрана и затем применяет их.
  Future<void> navigateToFiltersScreen(BuildContext context) async {
    final dataStorage = _InheritedPlaceListScreenState.of(context);

    final selectedFilters = await Navigator.pushNamed<Map<String, Object>>(
      context,
      AppRouter.placeFilters,
      arguments: {
        'placeTypeFilters': dataStorage.placeTypeFilters,
        'distanceFrom': dataStorage.distanceFrom,
        'distanceTo': dataStorage.distanceTo,
      },
    );

    if (selectedFilters != null) {
      final placeTypeFilters =
          selectedFilters['placeTypeFilters'] as List<Map<String, Object>>;
      final distanceFrom = selectedFilters['distanceFrom'] as double;
      final distanceTo = selectedFilters['distanceTo'] as double;

      dataStorage
        ..saveFilters(placeTypeFilters, distanceFrom, distanceTo)
        ..applyFilters(placeTypeFilters, distanceFrom, distanceTo);
    }
  }
}

/// Кнопка добавления нового места.
class _AddNewPlaceButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _AddNewPlaceButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorSchemeOnBackgroundColor = theme.colorScheme.onBackground;

    return CustomElevatedButton(
      AppStrings.newPlace,
      width: 177,
      height: 48,
      buttonLabel: Icon(
        Icons.add,
        size: 20,
        color: colorSchemeOnBackgroundColor,
      ),
      borderRadius: BorderRadius.circular(24),
      textStyle: theme.textTheme.bodyText2?.copyWith(
        color: colorSchemeOnBackgroundColor,
        fontWeight: FontWeight.w700,
      ),
      gradient: const LinearGradient(
        colors: [AppColors.brightSun, AppColors.fruitSalad],
      ),
      onPressed: onPressed,
    );
  }
}