import 'package:flutter/material.dart';
import 'package:mattermost_example/screens/login_screen.dart';

void main() {
  runApp(const MattermostApp());
}

class MattermostApp extends StatelessWidget {
  const MattermostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mattermost Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark, useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}
