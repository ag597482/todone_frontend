import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todone_frontend/core/constants/index.dart';
import 'package:todone_frontend/features/auth/screens/auth_gate_screen.dart';
import 'package:todone_frontend/routes/index.dart';
import 'package:todone_frontend/core/theme/theme_mode_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await ThemeModeNotifier.loadThemeMode();
  runApp(MainApp(themeModeNotifier: ThemeModeNotifier(savedThemeMode)));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.themeModeNotifier});

  final ThemeModeNotifier themeModeNotifier;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeModeNotifier>.value(
      value: themeModeNotifier,
      child: Consumer<ThemeModeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            title: 'Todone',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthGateScreen(),
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
