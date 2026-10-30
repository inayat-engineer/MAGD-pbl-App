import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/state/notice_buckets.dart';
import 'package:magd_pbl/state/notice_controller.dart';
import 'package:magd_pbl/state/theme_controller.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_gradients.dart';
import 'package:magd_pbl/theme/app_spacing.dart';
import 'package:magd_pbl/utils/strings.dart';
import 'package:magd_pbl/widgets/category_chip.dart';
import 'package:magd_pbl/widgets/notice_card.dart';
import 'package:magd_pbl/widgets/skeleton_notice.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({
    super.key,
    required this.controller,
    this.themeController,
  });

  final NoticeController controller;
  final ThemeController? themeController;

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _searchTimer;
  bool _loading = true;
  bool _expiredExpanded = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppDurations.load, () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.slash): _focusSearch,
          const SingleActivator(
            LogicalKeyboardKey.keyK,
            control: true,
          ): _focusSearch,
          const SingleActivator(
            LogicalKeyboardKey.keyK,
            meta: true,
          ): _focusSearch,
          const SingleActivator(LogicalKeyboardKey.escape): _clearSearch,
        },
        child: Focus(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _header(context),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ChipHeaderDelegate(child: _categoryFilters(context)),
            ),
            if (widget.controller.selectedDepartment != null ||
                widget.controller.selectedSemester != null)
              SliverToBoxAdapter(child: _activeFilter(context)),
            if (_loading)
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList.builder(
                  itemCount: 4,
                  itemBuilder: (_, _) => const SkeletonNotice(),
                ),
              )
            else
              ..._noticeSlivers(context),
          ],
        ),
          ),
        ),
      ),
    );
  }

  void _focusSearch() => _searchFocusNode.requestFocus();

  void _clearSearch() {
    _searchController.clear();
    widget.controller.setSearchQuery('');
    _searchFocusNode.unfocus();
  }

  SliverAppBar _header(BuildContext context) {
    final urgent = widget.controller.visibleUrgentCount;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 216,
      collapsedHeight: 64,
      toolbarHeight: 64,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.surfaceLight,
      scrolledUnderElevation: 0,
      title: const Text(AppStrings.appName),
      actions: [
        PopupMenuButton<ThemeMode>(
          tooltip: 'Theme',
          icon: const Icon(Icons.brightness_6_rounded),
          onSelected: (mode) {
            final themeController = widget.themeController;
            if (themeController != null) {
              themeController.setMode(mode);
            }
          },
          itemBuilder: (context) => [
            _themeMenuItem(ThemeMode.light, 'Light'),
            _themeMenuItem(ThemeMode.dark, 'Dark'),
            _themeMenuItem(ThemeMode.system, 'System'),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            gradient: AppGradients.forContext(
              'notices',
              widget.controller.selectedCategory,
              Theme.of(context).brightness,
            ),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _greeting(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppColors.surfaceLight),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              DateFormat('EEE, d MMM').format(DateTime.now()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.surfaceLight),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _SearchField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Semantics(
                          button: true,
                          label: '$urgent urgent notices',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            onTap: widget.controller.toggleUrgentOnly,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                            ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight.withAlpha(35),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.pill,
                                ),
                              ),
                              child: Text(
                                '$urgent urgent notices',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.surfaceLight),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<ThemeMode> _themeMenuItem(ThemeMode mode, String label) {
    final selected = widget.themeController?.mode == mode;
    return PopupMenuItem<ThemeMode>(
      value: mode,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: selected ? const Icon(Icons.check_rounded) : null,
          ),
          Text(label),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _categoryFilters(BuildContext context) {
    final categories = <NoticeCategory?>[null, ...NoticeCategory.values];
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return IconButton(
                tooltip: AppStrings.filters,
                onPressed: () => _showFilters(context),
                icon: const Icon(Icons.tune_rounded),
                constraints: const BoxConstraints.tightFor(
                  width: AppSpacing.xl + AppSpacing.md,
                  height: AppSpacing.xl + AppSpacing.md,
                ),
              );
            }
            final category = categories[index];
            final count = category == null
                ? widget.controller.notices.length
                : widget.controller.notices
                      .where((notice) => notice.category == category)
                      .length;
            return CategoryChip(
              category: category,
              count: count,
              selected: widget.controller.selectedCategory == category,
              onTap: () => widget.controller.setCategory(category),
            );
          },
        ),
      ),
    );
  }

  Widget _activeFilter(BuildContext context) {
    final values = [
      widget.controller.selectedDepartment,
      widget.controller.selectedSemester,
    ].whereType<String>().join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: InputChip(
        label: Text(values),
        onDeleted: widget.controller.clearFilters,
        deleteButtonTooltipMessage: AppStrings.clearFilters,
      ),
    );
  }

  List<Widget> _noticeSlivers(BuildContext context) {
    final buckets = NoticeBuckets.group(
      widget.controller.filteredNotices(),
      DateTime.now(),
    );
    if (buckets.today.isEmpty &&
        buckets.nextSevenDays.isEmpty &&
        buckets.later.isEmpty &&
        buckets.expired.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            hasFilters:
                widget.controller.searchQuery.isNotEmpty ||
                widget.controller.selectedCategory != null ||
                widget.controller.selectedDepartment != null ||
                widget.controller.selectedSemester != null ||
                widget.controller.urgentOnly,
          ),
        ),
      ];
    }
    return [
      _bucketSliver(context, AppStrings.dueToday, buckets.today),
      _bucketSliver(context, AppStrings.nextSevenDays, buckets.nextSevenDays),
      _bucketSliver(context, AppStrings.later, buckets.later),
      if (buckets.expired.isNotEmpty)
        SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: AppStrings.expired,
                collapsible: true,
                expanded: _expiredExpanded || buckets.expired.length <= 2,
                onTap: () =>
                    setState(() => _expiredExpanded = !_expiredExpanded),
              ),
            ),
            if (_expiredExpanded || buckets.expired.length <= 2)
              _cardSliver(context, buckets.expired),
          ],
        ),
    ];
  }

  SliverMainAxisGroup _bucketSliver(
    BuildContext context,
    String title,
    List<Notice> notices,
  ) {
    if (notices.isEmpty) return const SliverMainAxisGroup(slivers: []);
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionDelegate(title: title),
        ),
        _cardSliver(context, notices),
      ],
    );
  }

  SliverPadding _cardSliver(BuildContext context, List<Notice> notices) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) => NoticeCard(
          notice: notices[index],
          selected: widget.controller.selectedNoticeId == notices[index].id,
          onTap: () {
            widget.controller.markAsRead(notices[index].id);
            widget.controller.selectNotice(notices[index].id);
            context.push('/notices/${notices[index].id}');
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(AppDurations.load);
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      AppDurations.normal + const Duration(milliseconds: 50),
      () {
        widget.controller.setSearchQuery(value);
      },
    );
  }

  Future<void> _showFilters(BuildContext context) async {
    var department = widget.controller.selectedDepartment;
    var semester = widget.controller.selectedSemester;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final content = StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.xxs,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.filters,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                'Department',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Wrap(
                spacing: AppSpacing.xs,
                children: ['All departments', ...widget.controller.departments]
                    .map((item) {
                      final value = item == 'All departments' ? null : item;
                      return ChoiceChip(
                        label: Text(item),
                        selected: department == value,
                        onSelected: (_) =>
                            setSheetState(() => department = value),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Semester', style: Theme.of(context).textTheme.labelLarge),
              Wrap(
                spacing: AppSpacing.xs,
                children: ['All', ...widget.controller.semesters].map((item) {
                  final value = item == 'All' ? null : item;
                  return ChoiceChip(
                    label: Text(item),
                    selected: semester == value,
                    onSelected: (_) => setSheetState(() => semester = value),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      widget.controller.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text(AppStrings.clearFilters),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      widget.controller.setDepartment(department);
                      widget.controller.setSemester(semester);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Show ${widget.controller.filteredNoticesForFilters(
                        department: department,
                        semester: semester,
                      ).length} results',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
    if (wide) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          content: SizedBox(width: 520, child: content),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => content,
      );
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight),
      decoration: InputDecoration(
        hintText: 'Search notices',
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.surfaceLight),
        prefixIcon: const Icon(Icons.search_rounded),
        prefixIconColor: AppColors.surfaceLight,
        fillColor: AppColors.surfaceLight.withAlpha(31),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.surfaceLight.withAlpha(70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.goldLight, width: 2),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.collapsible = false,
    this.expanded = true,
    this.onTap,
  });

  final String title;
  final bool collapsible;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        height: 48,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (collapsible)
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_rounded, size: AppSpacing.xl),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters ? AppStrings.noNotice : AppStrings.noNoticesYet,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ChipHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;
  @override
  bool shouldRebuild(covariant _ChipHeaderDelegate oldDelegate) => false;
}

class _SectionDelegate extends SliverPersistentHeaderDelegate {
  const _SectionDelegate({required this.title});
  final String title;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => _SectionHeader(title: title);
  @override
  bool shouldRebuild(covariant _SectionDelegate oldDelegate) =>
      oldDelegate.title != title;
}
