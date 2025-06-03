import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import 'screens/messages/global_threads_screen.dart';

void main() {
  runApp(const GlobalThreadsDemo());
}

class GlobalThreadsDemo extends StatelessWidget {
  const GlobalThreadsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Threads Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const GlobalThreadsDemoHome(),
    );
  }
}

class GlobalThreadsDemoHome extends StatelessWidget {
  const GlobalThreadsDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mattermost Global Threads Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.forum,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Global Threads',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'View and manage all your thread conversations in one place',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _openGlobalThreads(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Global Threads'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Real API integration')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Follow/unfollow threads')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Mark threads as read')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Real-time WebSocket updates')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text('Filter by unread/following/all')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGlobalThreads(BuildContext context) {
    try {
      // Create mock client and user for demo
      // In production, these would come from your authentication system
      final client = MattermostClient(
        config: MattermostConfig(
          baseUrl: 'https://your-mattermost-server.com',
          enableDebugLogs: true,
        ),
      );

      final currentUser = MUser(
        id: 'demo_user_123',
        username: 'demouser',
        email: 'demo@example.com',
        firstName: 'Demo',
        lastName: 'User',
        nickname: 'demo',
        position: 'Developer',
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

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GlobalThreadsScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
