import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../constants/screens.dart';
import '../../services/navigation_service.dart';

class BrowseChannelsScreen extends StatefulWidget {
  const BrowseChannelsScreen({super.key});

  @override
  State<BrowseChannelsScreen> createState() => _BrowseChannelsScreenState();
}

class _BrowseChannelsScreenState extends State<BrowseChannelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MChannel> _allChannels = [];
  List<MChannel> _filteredChannels = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _joinedChannels = {};

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // In a real implementation, load public channels from the server
      await Future.delayed(const Duration(seconds: 1));

      // Mock channel data
      final channels = [
        MChannel(
          id: '1',
          displayName: 'General',
          name: 'general',
          type: 'O',
          teamId: 'team1',
          header: 'General discussion for the team',
          purpose: 'Team-wide communication',
          createAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          updateAt: DateTime.now().millisecondsSinceEpoch,
          deleteAt: 0,
          creatorId: 'user1',
          totalMsgCount: 245,
          extraUpdateAt: 0,
          lastPostAt: DateTime.now().millisecondsSinceEpoch - 3600000,
        ),
        MChannel(
          id: '2',
          displayName: 'Random',
          name: 'random',
          type: 'O',
          teamId: 'team1',
          header: 'Random conversations',
          purpose: 'Non-work related discussions',
          createAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          updateAt: DateTime.now().millisecondsSinceEpoch,
          deleteAt: 0,
          creatorId: 'user1',
          totalMsgCount: 89,
          extraUpdateAt: 0,
          lastPostAt: DateTime.now().millisecondsSinceEpoch - 7200000,
        ),
        MChannel(
          id: '3',
          displayName: 'Development',
          name: 'development',
          type: 'O',
          teamId: 'team1',
          header: 'Development discussions',
          purpose: 'Technical discussions and code reviews',
          createAt: DateTime.now().millisecondsSinceEpoch - 86400000,
          updateAt: DateTime.now().millisecondsSinceEpoch,
          deleteAt: 0,
          creatorId: 'user1',
          totalMsgCount: 167,
          extraUpdateAt: 0,
          lastPostAt: DateTime.now().millisecondsSinceEpoch - 1800000,
        ),
      ];

      setState(() {
        _allChannels = channels;
        _filteredChannels = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load channels: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterChannels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChannels = _allChannels;
      } else {
        _filteredChannels = _allChannels
            .where(
              (channel) =>
                  channel.displayName.toLowerCase().contains(query.toLowerCase()) ||
                  channel.purpose.toLowerCase().contains(query.toLowerCase()) ||
                  channel.header.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _joinChannel(MChannel channel) async {
    try {
      // In a real implementation, join the channel via API
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _joinedChannels.add(channel.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${channel.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join channel: $e')),
      );
    }
  }

  Future<void> _leaveChannel(MChannel channel) async {
    try {
      // In a real implementation, leave the channel via API
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _joinedChannels.remove(channel.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left ${channel.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave channel: $e')),
      );
    }
  }

  void _createNewChannel() {
    NavigationService.pushNamed(Screens.createChannel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Channels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewChannel,
            tooltip: 'Create Channel',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search channels...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterChannels,
            ),
          ),

          // Channel list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadChannels,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredChannels.isEmpty
                ? const Center(
                    child: Text(
                      'No channels found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredChannels.length,
                    itemBuilder: (context, index) {
                      final channel = _filteredChannels[index];
                      final isJoined = _joinedChannels.contains(channel.id);

                      return _buildChannelTile(channel, isJoined);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelTile(MChannel channel, bool isJoined) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            channel.type == 'P' ? Icons.lock : Icons.tag,
            color: Colors.white,
          ),
        ),
        title: Text(
          channel.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (channel.purpose.isNotEmpty)
              Text(
                channel.purpose,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '${channel.totalMsgCount} messages',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: isJoined
            ? OutlinedButton(
                onPressed: () => _leaveChannel(channel),
                child: const Text('Leave'),
              )
            : ElevatedButton(
                onPressed: () => _joinChannel(channel),
                child: const Text('Join'),
              ),
        onTap: isJoined
            ? () {
                // Navigate to channel if already joined
                NavigationService.pop();
              }
            : null,
      ),
    );
  }
}
