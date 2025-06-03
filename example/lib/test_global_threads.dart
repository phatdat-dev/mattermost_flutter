import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import 'screens/messages/global_threads_screen.dart';

class TestGlobalThreadsNavigation extends StatelessWidget {
  const TestGlobalThreadsNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Global Threads'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _navigateToGlobalThreads(context);
          },
          child: const Text('Open Global Threads'),
        ),
      ),
    );
  }

  void _navigateToGlobalThreads(BuildContext context) async {
    // Create a mock client and user for testing
    // In a real app, these would come from your authentication system

    try {
      // Mock client - replace with real client in production
      final client = MattermostClient(
        config: MattermostConfig(
          baseUrl: 'https://your-mattermost-server.com',
          enableDebugLogs: true,
        ),
      );

      // Mock user - replace with real authenticated user
      final currentUser = MUser(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        nickname: 'tester',
        position: '',
        locale: 'en',
        deleteAt: 0,
        createAt: DateTime.now().millisecondsSinceEpoch,
        updateAt: DateTime.now().millisecondsSinceEpoch,
        isBot: false,
        botDescription: '',
        timezone: null,
        notifyProps: null,
        props: null,
      );

      // Navigate to GlobalThreadsScreen with required parameters
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GlobalThreadsScreen(),
        ),
      );
    } catch (e) {
      // Handle navigation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening threads: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
