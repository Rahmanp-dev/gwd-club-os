import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/shell/club_app_shell.dart';
import 'app/theme/gwd_theme.dart';
import 'core/services/club_workspace_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final workspace = ClubWorkspaceService();
  // Bring back the saved workspace before the first frame so the app never
  // flashes seed data over the user's real state.
  await workspace.restore();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(GwdClubApp(workspace: workspace));
}

class GwdClubApp extends StatefulWidget {
  const GwdClubApp({super.key, this.workspace});

  final ClubWorkspaceService? workspace;

  @override
  State<GwdClubApp> createState() => _GwdClubAppState();
}

class _GwdClubAppState extends State<GwdClubApp> {
  late final ClubWorkspaceService _workspace;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace ?? ClubWorkspaceService();
  }

  @override
  void dispose() {
    _workspace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GWD CLUB OS',
      debugShowCheckedModeBanner: false,
      theme: GwdTheme.light(),
      darkTheme: GwdTheme.dark(),
      // Locked to light until every feature screen is audited for dark surfaces.
      themeMode: ThemeMode.light,
      scrollBehavior: const _FluidScrollBehavior(),
      builder: (context, child) {
        // Cap text scaling so a large accessibility setting cannot break the
        // dense dashboard layouts, while still honouring user preference.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: ClubAppShell(workspaceService: _workspace),
    );
  }
}

/// Drag scrolling with a mouse (so the web build feels right), plus the iOS
/// bouncing physics on every platform for a consistent, fluid feel.
class _FluidScrollBehavior extends MaterialScrollBehavior {
  const _FluidScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
