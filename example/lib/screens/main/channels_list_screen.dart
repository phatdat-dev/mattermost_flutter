import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../constants/screens.dart';
import '../../routes/app_routes.dart';
import '../../services/navigation_service.dart';

class ChannelsListScreen extends StatefulWidget {
  const ChannelsListScreen({super.key});

  @override
  State<ChannelsListScreen> createState() => _ChannelsListScreenState();
}

class _ChannelsListScreenState extends State<ChannelsListScreen> {
  List<MTeam> _teams = [];
  MTeam? _selectedTeam;
  List<MChannel> _channels = [];
  final List<MChannel> _directMessages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load teams
      final teams = await AppRoutes.client.teams.getTeams();
      if (teams.isNotEmpty) {
        _selectedTeam = teams.first;

        // Load channels for the selected team
        final channels = await AppRoutes.client.channels.getChannelsForTeam(_selectedTeam!.id);
        // final directMessages = await AppRoutes.client!.channels.getDirectChannels();

        setState(() {
          _teams = teams;
          _channels = channels.where((c) => c.type != 'D' && c.type != 'G').toList();
          // _directMessages = channels.where((c) => c.type == 'D' || c.type == 'G').toList()..addAll(directMessages);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load channels: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _openChannel(MChannel channel) {
    NavigationService.pushNamed(
      Screens.channel,
      arguments: channel,
    );
  }

  void _createChannel() {
    NavigationService.pushNamed(Screens.createChannel);
  }

  void _browseChannels() {
    NavigationService.pushNamed(Screens.browseChannels);
  }

  void _createDirectMessage() {
    NavigationService.pushNamed(Screens.createDirectMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTeam?.displayName ?? 'Mattermost'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => NavigationService.pushNamed(Screens.searchMessages),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  NavigationService.pushNamed(Screens.settings);
                  break;
                case 'about':
                  NavigationService.pushNamed(Screens.about);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  // Public Channels Section
                  _buildSectionHeader(
                    'PUBLIC CHANNELS',
                    Icons.forum,
                    onAdd: _createChannel,
                    onMore: _browseChannels,
                  ),
                  ..._channels.map((channel) => _buildChannelTile(channel)),

                  const Divider(),

                  // Direct Messages Section
                  _buildSectionHeader(
                    'DIRECT MESSAGES',
                    Icons.person,
                    onAdd: _createDirectMessage,
                  ),
                  ..._directMessages.map((channel) => _buildChannelTile(channel)),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    VoidCallback? onAdd,
    VoidCallback? onMore,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (onMore != null)
            IconButton(
              icon: const Icon(Icons.explore, size: 20),
              onPressed: onMore,
              tooltip: 'Browse channels',
            ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: onAdd,
              tooltip: 'Create new',
            ),
        ],
      ),
    );
  }

  Widget _buildChannelTile(MChannel channel) {
    IconData icon;
    switch (channel.type) {
      case 'O': // Open channel
        icon = Icons.tag;
        break;
      case 'P': // Private channel
        icon = Icons.lock;
        break;
      case 'D': // Direct message
        icon = Icons.person;
        break;
      case 'G': // Group message
        icon = Icons.group;
        break;
      default:
        icon = Icons.tag;
    }

    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        channel.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: channel.purpose.isNotEmpty
          ? Text(
              channel.purpose,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: channel.totalMsgCount! > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${channel.totalMsgCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () => _openChannel(channel),
    );
  }
}
