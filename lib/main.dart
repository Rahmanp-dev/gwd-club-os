import 'package:flutter/material.dart';
import 'app/shell/club_app_shell.dart';
import 'app/theme/gwd_theme.dart';
import 'core/services/club_workspace_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GwdClubApp());
}

// Backwards compatibility alias
typedef MehnatFounderOs = GwdClubApp;

class GwdClubApp extends StatefulWidget {
  const GwdClubApp({super.key});

  @override
  State<GwdClubApp> createState() => _GwdClubAppState();
}

class _GwdClubAppState extends State<GwdClubApp> {
  late final ClubWorkspaceService _workspaceService;

  @override
  void initState() {
    super.initState();
    _workspaceService = ClubWorkspaceService();
  }

  @override
  void dispose() {
    _workspaceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GWD CLUB OS',
      debugShowCheckedModeBanner: false,
      theme: GwdTheme.light(),
      darkTheme: GwdTheme.dark(),
      themeMode: ThemeMode.light,
      home: ClubAppShell(workspaceService: _workspaceService),
    );
  }
}
