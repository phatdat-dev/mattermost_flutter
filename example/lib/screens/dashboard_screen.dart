import 'package:flutter/material.dart';
import 'package:mattermost_example/screens/channels_screen.dart';
import 'package:mattermost_example/screens/direct_messages_screen.dart';
import 'package:mattermost_example/screens/login_screen.dart';
import 'package:mattermost_example/screens/profile_screen.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;

  const DashboardScreen({super.key, required this.client, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<MTeam> _teams = [];
  MTeam? _selectedTeam;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    widget.client.webSocket.events.listen((event) {
      // Handle WebSocket events
      if (event['event'] == 'hello') {
        debugPrint('WebSocket connected');
      } else if (event['event'] == 'posted') {
        // Refresh data when a new post is created
        if (mounted) {
          _loadTeams();
        }
      }
    });
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get teams for the current user
      _teams = await widget.client.teams.getTeamsForUser(widget.currentUser.id);

      if (_teams.isNotEmpty) {
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

  Future<void> _logout() async {
    try {
      await widget.client.logout();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTeam?.displayName ?? 'Mattermost'),
        actions: [IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout, tooltip: 'Logout')],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Channels'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Direct Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('${widget.currentUser.firstName} ${widget.currentUser.lastName}'),
            accountEmail: Text(widget.currentUser.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.currentUser.username.isNotEmpty ? widget.currentUser.username[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          const ListTile(
            title: Text('Teams', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ..._teams.map(
            (team) => ListTile(
              title: Text(team.displayName),
              selected: _selectedTeam?.id == team.id,
              onTap: () {
                setState(() {
                  _selectedTeam = team;
                });
                Navigator.pop(context);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _selectedTeam != null
            ? ChannelsScreen(client: widget.client, currentUser: widget.currentUser, team: _selectedTeam!)
            : const Center(child: Text('No team selected'));
      case 1:
        return DirectMessagesScreen(client: widget.client, currentUser: widget.currentUser);
      case 2:
        return ProfileScreen(client: widget.client, currentUser: widget.currentUser);
      default:
        return const Center(child: Text('Unknown screen'));
    }
  }
}
