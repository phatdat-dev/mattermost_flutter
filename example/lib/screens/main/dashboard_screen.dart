import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';
import '../auth/login_screen.dart';
import '../direct_messages/direct_messages_screen.dart';
import '../messages/global_threads_screen.dart';
import '../messages/recent_mentions_screen.dart';
import '../messages/saved_messages_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'channels_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<MTeam> _teams = [];
  MTeam? _selectedTeam;
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadCount = 0;
  int _mentionCount = 0;
  late TabController _tabController;

  // WebSocket connection status
  bool _isConnected = false;
  String _connectionStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTeams();
    _setupWebSocket();
    _loadUnreadCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupWebSocket() {
    try {
      AppRoutes.client.webSocket.events.listen(
        (event) {
          if (!mounted) return;

          switch (event['event']) {
            case 'hello':
              setState(() {
                _isConnected = true;
                _connectionStatus = 'Connected';
              });
              debugPrint('WebSocket connected');
              break;

            case 'posted':
              // Refresh unread counts when new post is created
              _loadUnreadCounts();
              break;

            case 'user_updated':
              // Refresh user data if current user is updated
              if (event['data']?['user']?['id'] == AppRoutes.currentUser?.id) {
                _loadTeams();
              }
              break;

            case 'channel_updated':
            case 'channel_deleted':
            case 'channel_created':
              // Refresh teams/channels data
              _loadTeams();
              break;

            case 'status_change':
              // Handle user status changes
              debugPrint('User status changed: ${event['data']}');
              break;

            case 'typing':
              // Handle typing indicators
              debugPrint('User typing: ${event['data']}');
              break;

            default:
              debugPrint('Unhandled WebSocket event: ${event['event']}');
          }
        },
        onError: (error) {
          setState(() {
            _isConnected = false;
            _connectionStatus = 'Connection Error';
          });
          debugPrint('WebSocket error: $error');
        },
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Failed to Connect';
      });
      debugPrint('WebSocket setup error: $e');
    }
  }

  Future<void> _loadTeams() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get teams for the current user
      _teams = await AppRoutes.client.teams.getTeamsForUser(AppRoutes.currentUser!.id);

      if (_teams.isNotEmpty && _selectedTeam == null) {
        _selectedTeam = _teams.first;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load teams: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUnreadCounts() async {
    if (!mounted || _selectedTeam == null) return;

    try {
      // Get unread counts for current team
      final channels = await AppRoutes.client.channels.getChannelsForUser(
        AppRoutes.currentUser!.id,
        _selectedTeam!.id,
      );

      int totalUnread = 0;
      int totalMentions = 0;

      for (final channel in channels) {
        // Get unread count for each channel
        try {
          final unreadInfo = await AppRoutes.client.channels.getChannelUnread(
            AppRoutes.currentUser!.id,
            channel.id,
          );
          totalUnread += unreadInfo.msgCount;
          totalMentions += unreadInfo.mentionCount;
        } catch (e) {
          debugPrint('Error getting unread for channel ${channel.id}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _unreadCount = totalUnread;
          _mentionCount = totalMentions;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread counts: $e');
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await AppRoutes.client.logout();

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Load unread counts when switching to channels
    if (index == 0) {
      _loadUnreadCounts();
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadTeams(),
      _loadUnreadCounts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorWidget()
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildBody(),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(_selectedTeam?.displayName ?? 'Mattermost'),
          ),
          const SizedBox(width: 8),
          // Connection status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      actions: [
        // Notification badge
        if (_mentionCount > 0)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecentMentionsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_mentionCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Navigate to search screen
            showSearch(
              context: context,
              delegate: MessageSearchDelegate(),
            );
          },
        ),

        // More options
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'settings':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                break;
              case 'logout':
                _logout();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      bottom: _selectedIndex == 0 && _selectedTeam != null
          ? TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Channels'),
                Tab(text: 'Threads'),
                Tab(text: 'Saved'),
                Tab(text: 'Mentions'),
              ],
            )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              '${AppRoutes.currentUser!.firstName} ${AppRoutes.currentUser!.lastName}',
            ),
            accountEmail: Text(AppRoutes.currentUser!.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                AppRoutes.currentUser!.username.isNotEmpty ? AppRoutes.currentUser!.username[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Connection status
          ListTile(
            leading: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            title: Text(_connectionStatus),
            subtitle: Text(_isConnected ? 'Real-time updates enabled' : 'Offline mode'),
          ),

          const Divider(),

          const ListTile(
            title: Text(
              'Teams',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Teams list
          ..._teams.map(
            (team) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _selectedTeam?.id == team.id ? Theme.of(context).colorScheme.primary : Colors.grey,
                child: Text(
                  team.displayName.isNotEmpty ? team.displayName[0].toUpperCase() : 'T',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(team.displayName),
              subtitle: Text(team.description),
              selected: _selectedTeam?.id == team.id,
              onTap: () {
                setState(() {
                  _selectedTeam = team;
                });
                Navigator.pop(context);
                _loadUnreadCounts();
              },
            ),
          ),

          const Divider(),

          // Quick actions
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Join Team'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to join team screen
            },
          ),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTeams,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Channels
        return _selectedTeam != null
            ? TabBarView(
                controller: _tabController,
                children: [
                  ChannelsListScreen(team: _selectedTeam!),
                  const GlobalThreadsScreen(),
                  const SavedMessagesScreen(),
                  const RecentMentionsScreen(),
                ],
              )
            : const Center(child: Text('No team selected'));

      case 1: // Direct Messages
        return const DirectMessagesScreen();

      case 2: // Profile
        return const ProfileScreen();

      default:
        return const Center(child: Text('Unknown screen'));
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.chat),
              if (_unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Channels',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Direct Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onNavItemTapped,
    );
  }
}

// Search delegate for message search
class MessageSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return const Center(
      child: Text('Search results will appear here'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return const Center(
      child: Text('Search suggestions will appear here'),
    );
  }
}
