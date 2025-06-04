import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';
import 'channel_screen.dart';

class ChannelsListScreen extends StatefulWidget {
  final MTeam team;

  const ChannelsListScreen({super.key, required this.team});

  @override
  State<ChannelsListScreen> createState() => _ChannelsListScreenState();
}

class _ChannelsListScreenState extends State<ChannelsListScreen> {
  List<MChannel> _channels = [];
  List<MChannel> _filteredChannels = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _websocketSubscription;

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _setupWebSocket();
    _searchController.addListener(_filterChannels);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _websocketSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChannelsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team.id != widget.team.id) {
      _loadChannels();
    }
  }

  void _setupWebSocket() {
    _websocketSubscription = AppRoutes.client.webSocket.events.listen((event) {
      if (!mounted) return;

      switch (event['event']) {
        case 'channel_created':
        case 'channel_updated':
        case 'channel_deleted':
        case 'user_added_to_channel':
        case 'user_removed_from_channel':
          if (event['data']?['team_id'] == widget.team.id) {
            _loadChannels();
          }
          break;
      }
    });
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get channels for the selected team
      _channels = await AppRoutes.client.channels.getChannelsForUser(
        AppRoutes.currentUser!.id,
        widget.team.id,
      );

      // Sort channels by type and name
      _channels.sort((a, b) {
        // Public channels first, then private
        if (a.type != b.type) {
          if (a.type == 'O') return -1;
          if (b.type == 'O') return 1;
        }
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });

      _filterChannels();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load channels: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterChannels() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChannels = _channels.where((channel) {
        return channel.displayName.toLowerCase().contains(query) ||
            channel.name.toLowerCase().contains(query) ||
            (channel.purpose.toLowerCase().contains(query));
      }).toList();
    });
  }

  Future<void> _createChannel() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CreateChannelDialog(),
    );

    if (result != null) {
      try {
        await AppRoutes.client.channels.createChannel(
          teamId: widget.team.id,
          name: result['name']!.toLowerCase().replaceAll(' ', '-'),
          displayName: result['displayName']!,
          type: result['type']!,
          purpose: result['purpose'] ?? '',
          header: result['header'] ?? '',
        );

        // Reload channels after creating a new one
        _loadChannels();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Channel created successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create channel: $e')),
        );
      }
    }
  }

  Future<void> _joinChannel(MChannel channel) async {
    try {
      await AppRoutes.client.channels.addChannelMember(
        channel.id,
        userId: AppRoutes.currentUser!.id,
      );

      _loadChannels();

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
    // Show confirmation dialog
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave ${channel.displayName}'),
        content: const Text('Are you sure you want to leave this channel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    try {
      await AppRoutes.client.channels.removeChannelMember(
        channel.id,
        AppRoutes.currentUser!.id,
      );

      _loadChannels();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left ${channel.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave channel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChannels,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search channels...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        // Channels list
        Expanded(
          child: _filteredChannels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty ? 'No channels found' : 'No channels available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _createChannel,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Channel'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChannels,
                  child: ListView.builder(
                    itemCount: _filteredChannels.length,
                    itemBuilder: (context, index) {
                      final channel = _filteredChannels[index];
                      return _buildChannelTile(channel);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildChannelTile(MChannel channel) {
    final isPublic = channel.type == 'O';
    final isPrivate = channel.type == 'P';
    final isDirect = channel.type == 'D';
    // final isGroup = channel.type == 'G';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPublic
              ? Colors.blue
              : isPrivate
              ? Colors.orange
              : isDirect
              ? Colors.green
              : Colors.purple,
          child: Icon(
            isPublic
                ? Icons.tag
                : isPrivate
                ? Icons.lock
                : isDirect
                ? Icons.person
                : Icons.group,
            color: Colors.white,
          ),
        ),
        title: Text(
          channel.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (channel.purpose.isNotEmpty == true)
              Text(
                channel.purpose,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPublic ? Icons.public : Icons.lock,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  isPublic
                      ? 'Public'
                      : isPrivate
                      ? 'Private'
                      : isDirect
                      ? 'Direct'
                      : 'Group',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'join':
                _joinChannel(channel);
                break;
              case 'leave':
                _leaveChannel(channel);
                break;
              case 'info':
                _showChannelInfo(channel);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'join',
              child: ListTile(
                leading: Icon(Icons.add),
                title: Text('Join'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'leave',
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Leave', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Info'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChannelScreen(channel: channel),
            ),
          );
        },
      ),
    );
  }

  void _showChannelInfo(MChannel channel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(channel.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID', channel.id),
            _buildInfoRow('Name', channel.name),
            _buildInfoRow('Type', _getChannelTypeText(channel.type)),
            if (channel.purpose.isNotEmpty == true) _buildInfoRow('Purpose', channel.purpose),
            if (channel.header.isNotEmpty == true) _buildInfoRow('Header', channel.header),
            _buildInfoRow('Created', _formatDate(channel.createAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getChannelTypeText(String type) {
    switch (type) {
      case 'O':
        return 'Public Channel';
      case 'P':
        return 'Private Channel';
      case 'D':
        return 'Direct Message';
      case 'G':
        return 'Group Message';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Create Channel Dialog
class CreateChannelDialog extends StatefulWidget {
  const CreateChannelDialog({super.key});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _headerController = TextEditingController();
  String _channelType = 'O'; // Default to public channel

  @override
  void dispose() {
    _displayNameController.dispose();
    _purposeController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Channel'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name *',
                  hintText: 'Enter channel name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  if (value.length < 2) {
                    return 'Display name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose (Optional)',
                  hintText: 'What is this channel about?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _headerController,
                decoration: const InputDecoration(
                  labelText: 'Header (Optional)',
                  hintText: 'Channel header text',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _channelType,
                decoration: const InputDecoration(labelText: 'Channel Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'O',
                    child: Row(
                      children: [
                        Icon(Icons.public, size: 20),
                        SizedBox(width: 8),
                        Text('Public - Anyone can join'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'P',
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 20),
                        SizedBox(width: 8),
                        Text('Private - Invite only'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _channelType = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'displayName': _displayNameController.text,
                'name': _displayNameController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9-_]'), '-'),
                'purpose': _purposeController.text,
                'header': _headerController.text,
                'type': _channelType,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
