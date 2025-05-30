import 'package:flutter/material.dart';

import 'constants/screens.dart';
import 'routes/app_routes.dart';
import 'services/navigation_service.dart';

void main() {
  runApp(const MattermostApp());
}

class MattermostApp extends StatelessWidget {
  const MattermostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mattermost Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E325C),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E325C),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: Screens.login,
    );
  }
}
