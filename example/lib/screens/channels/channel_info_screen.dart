import 'package:flutter/material.dart';

class ChannelInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? channel;

  const ChannelInfoScreen({super.key, this.channel});

  @override
  State<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen> {
  bool _isLoading = false;
  bool _isMuted = false;
  bool _isFollowing = true;
  List<Map<String, dynamic>> _recentMembers = [];

  @override
  void initState() {
    super.initState();
    _loadChannelInfo();
  }

  void _loadChannelInfo() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load channel info from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _recentMembers = [
        {'id': '1', 'username': 'john.doe', 'first_name': 'John', 'last_name': 'Doe'},
        {'id': '2', 'username': 'jane.smith', 'first_name': 'Jane', 'last_name': 'Smith'},
        {'id': '3', 'username': 'bob.wilson', 'first_name': 'Bob', 'last_name': 'Wilson'},
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading channel info: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    // TODO: Update mute status via API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Channel muted' : 'Channel unmuted'),
      ),
    );
  }

  void _toggleFollow() async {
    setState(() => _isFollowing = !_isFollowing);
    // TODO: Update follow status via API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing ? 'Following channel' : 'Unfollowed channel'),
      ),
    );
  }

  void _leaveChannel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Channel'),
        content: Text(
          'Are you sure you want to leave ${widget.channel?['display_name'] ?? 'this channel'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Leave channel via API
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Left channel')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.channel;

    return Scaffold(
      appBar: AppBar(
        title: Text(channel?['display_name'] ?? 'Channel Info'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.pushNamed(context, '/edit-channel', arguments: channel);
                  break;
                case 'copy_link':
                  // TODO: Copy channel link
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Channel link copied')),
                  );
                  break;
                case 'leave':
                  _leaveChannel();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Channel'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_link',
                child: ListTile(
                  leading: Icon(Icons.link),
                  title: Text('Copy Link'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'leave',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Leave Channel', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Channel Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                (channel?['display_name'] ?? 'C')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    channel?['display_name'] ?? 'Unknown Channel',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (channel?['type'] == 'P')
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.lock,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Private Channel',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (channel?['purpose']?.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Purpose',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(channel!['purpose']),
                        ],
                        if (channel?['header']?.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Header',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(channel!['header']),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Channel Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(_isMuted ? Icons.notifications_off : Icons.notifications),
                        title: Text(_isMuted ? 'Unmute Channel' : 'Mute Channel'),
                        subtitle: Text(
                          _isMuted ? 'You will not receive notifications' : 'Mute all notifications from this channel',
                        ),
                        trailing: Switch(
                          value: _isMuted,
                          onChanged: (_) => _toggleMute(),
                        ),
                        onTap: _toggleMute,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(_isFollowing ? Icons.star : Icons.star_border),
                        title: Text(_isFollowing ? 'Unfollow Channel' : 'Follow Channel'),
                        subtitle: Text(
                          _isFollowing ? 'You are following this channel' : 'Get notified about new activity',
                        ),
                        trailing: Switch(
                          value: _isFollowing,
                          onChanged: (_) => _toggleFollow(),
                        ),
                        onTap: _toggleFollow,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.push_pin),
                        title: const Text('Pinned Messages'),
                        subtitle: const Text('View important messages'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/pinned-messages', arguments: channel);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.folder),
                        title: const Text('Files'),
                        subtitle: const Text('Browse shared files'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/channel-files', arguments: channel);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Members
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Members',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/manage-channel-members',
                                  arguments: channel,
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      ..._recentMembers.map(
                        (member) => ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (member['first_name']?[0] ?? member['username'][0]).toUpperCase(),
                            ),
                          ),
                          title: Text(
                            '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}'.trim().isEmpty
                                ? member['username']
                                : '${member['first_name']} ${member['last_name']}',
                          ),
                          subtitle: Text('@${member['username']}'),
                          onTap: () {
                            Navigator.pushNamed(context, '/user-profile', arguments: member);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
