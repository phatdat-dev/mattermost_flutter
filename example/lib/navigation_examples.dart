import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import 'screens/messages/global_threads_screen.dart';

/// Example of how to integrate GlobalThreadsScreen into your app's navigation
class AppWithGlobalThreads extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;

  const AppWithGlobalThreads({
    super.key,
    required this.client,
    required this.currentUser,
  });

  @override
  State<AppWithGlobalThreads> createState() => _AppWithGlobalThreadsState();
}

class _AppWithGlobalThreadsState extends State<AppWithGlobalThreads> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home/Dashboard screen
          _buildHomeScreen(),

          // Channels screen
          _buildChannelsScreen(),

          // Global Threads screen
          const GlobalThreadsScreen(),

          // Profile screen
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Threads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64),
            SizedBox(height: 16),
            Text('Home Screen'),
            SizedBox(height: 8),
            Text('Navigate to Threads tab to view Global Threads'),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tag, size: 64),
            SizedBox(height: 16),
            Text('Channels Screen'),
            SizedBox(height: 8),
            Text('Your channels would be listed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                widget.currentUser.username.isNotEmpty ? widget.currentUser.username[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '@${widget.currentUser.username}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.currentUser.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to navigate to GlobalThreadsScreen from within another screen
class NavigationExample extends StatelessWidget {
  final MattermostClient client;
  final MUser currentUser;

  const NavigationExample({
    super.key,
    required this.client,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Navigation Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Direct navigation
            ElevatedButton.icon(
              onPressed: () => _navigateToGlobalThreads(context),
              icon: const Icon(Icons.forum),
              label: const Text('Open Global Threads (Direct)'),
            ),

            const SizedBox(height: 12),

            // Modal navigation
            ElevatedButton.icon(
              onPressed: () => _showGlobalThreadsModal(context),
              icon: const Icon(Icons.fullscreen),
              label: const Text('Open Global Threads (Modal)'),
            ),

            const SizedBox(height: 12),

            // Replace current screen
            ElevatedButton.icon(
              onPressed: () => _replaceWithGlobalThreads(context),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Replace with Global Threads'),
            ),

            const SizedBox(height: 20),

            const Text(
              'Integration Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // App with bottom navigation
            ElevatedButton.icon(
              onPressed: () => _showAppWithBottomNav(context),
              icon: const Icon(Icons.apps),
              label: const Text('Show App with Bottom Navigation'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGlobalThreads(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GlobalThreadsScreen(),
      ),
    );
  }

  void _showGlobalThreadsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const GlobalThreadsScreen(),
      ),
    );
  }

  void _replaceWithGlobalThreads(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GlobalThreadsScreen(),
      ),
    );
  }

  void _showAppWithBottomNav(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppWithGlobalThreads(
          client: client,
          currentUser: currentUser,
        ),
      ),
    );
  }
}
