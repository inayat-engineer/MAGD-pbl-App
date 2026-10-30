import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:magd_pbl/data/dummy_notices.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/screens/notice_detail_screen.dart';
import 'package:magd_pbl/screens/notice_list_screen.dart';
import 'package:magd_pbl/screens/summary_screen.dart';
import 'package:magd_pbl/state/notice_controller.dart';
import 'package:magd_pbl/state/theme_controller.dart';
import 'package:magd_pbl/theme/app_theme.dart';
import 'package:magd_pbl/utils/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  usePathUrlStrategy();
  final themeController = await ThemeController.load();
  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.themeController});

  final ThemeController? themeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final NoticeController _controller;
  late final GoRouter _router;
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? ThemeController.initial();
    _controller = NoticeController(dummyNotices);
    _router = GoRouter(
      initialLocation: '/notices',
      errorBuilder: (context, state) => const _NotFoundPage(),
      routes: [
        ShellRoute(
          builder: (context, state, child) => _AdaptiveShell(
            controller: _controller,
            themeController: _themeController,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/notices',
              builder: (context, state) =>
                  NoticeListScreen(
                    controller: _controller,
                    themeController: _themeController,
                  ),
            ),
            GoRoute(
              path: '/summary',
              builder: (context, state) =>
                  SummaryScreen(controller: _controller),
            ),
            GoRoute(
              path: '/notices/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final notice = _findNotice(id);
                _controller.selectNotice(id);
                return notice == null
                    ? const _NotFoundPage()
                    : NoticeDetailScreen(
                        notice: notice,
                        controller: _controller,
                      );
              },
            ),
          ],
        ),
      ],
    );
  }

  Notice? _findNotice(String? id) {
    for (final notice in dummyNotices) {
      if (notice.id == id) return notice;
    }
    return null;
  }

  @override
  void dispose() {
    _router.dispose();
    _controller.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) => MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeController.mode,
        routerConfig: _router,
        builder: (context, child) => ScrollConfiguration(
          behavior: const AppScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _AdaptiveShell extends StatelessWidget {
  const _AdaptiveShell({
    required this.controller,
    required this.themeController,
    required this.child,
  });

  final NoticeController controller;
  final ThemeController themeController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isRail = width >= 600;
        final isMasterDetail = width >= 840;
        final extended = width >= 1200;
        final index = GoRouterState.of(context).uri.path == '/summary' ? 1 : 0;
        final isDetail = GoRouterState.of(
          context,
        ).uri.path.startsWith('/notices/');
        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: child,
          ),
        );
        if (isMasterDetail && (isDetail || index == 0)) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 460,
                  child: NoticeListScreen(
                    controller: controller,
                    themeController: themeController,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: isDetail ? child : const _EmptyDetailPane(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (isDetail) return child;
        return Scaffold(
          body: isRail
              ? Row(
                  children: [
                    NavigationRail(
                      extended: extended,
                      selectedIndex: index,
                      onDestinationSelected: (value) =>
                          context.go(value == 0 ? '/notices' : '/summary'),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.notifications_none_rounded),
                          selectedIcon: Icon(Icons.notifications_rounded),
                          label: Text(AppStrings.notices),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.insights_outlined),
                          selectedIcon: Icon(Icons.insights_rounded),
                          label: Text(AppStrings.summary),
                        ),
                      ],
                    ),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: isRail
              ? null
              : NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: (value) =>
                      context.go(value == 0 ? '/notices' : '/summary'),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.notifications_none_rounded),
                      selectedIcon: Icon(Icons.notifications_rounded),
                      label: AppStrings.notices,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights_rounded),
                      label: AppStrings.summary,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/notices'),
          child: const Text('Return to notices'),
        ),
      ),
    );
  }

}

class _EmptyDetailPane extends StatelessWidget {
  const _EmptyDetailPane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Select a notice to view details',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final platform = Theme.of(context).platform;
    final desktop =
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux;
    return desktop ? super.buildScrollbar(context, child, details) : child;
  }
}
