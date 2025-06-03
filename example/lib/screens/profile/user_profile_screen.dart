import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  final MUser? user;
  final MattermostClient? client;
  final MUser? currentUser;

  const UserProfileScreen({
    super.key,
    this.user,
    this.client,
    this.currentUser,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _userDetails;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    setState(() => _isLoading = true);

    try {
      if (widget.client != null && widget.user != null) {
        // Load full user details from API
        final user = await widget.client!.users.getUser(widget.user!.id);
        final userStatus = await widget.client!.status.getUserStatus(widget.user!.id);

        // Create a map of user details for display
        _userDetails = {
          'id': user.id,
          'username': user.username,
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'position': user.position,
          'status': userStatus.status,
          'last_activity_at': userStatus.lastActivityAt != null ? DateTime.fromMillisecondsSinceEpoch(userStatus.lastActivityAt!) : null,
          // Other details would be fetched from API in a full implementation
          'phone': '+1 (555) 123-4567', // Example mock data where API doesn't provide
          'timezone': user.timezone?.manualTimezone ?? 'America/New_York',
          'custom_status': {
            'emoji': '💻',
            'text': 'Working on a cool project',
            'expires_at': DateTime.now().add(const Duration(hours: 2)),
          },
          'roles': user.props?['roles']?.toString().split(',') ?? ['team_member'],
          // Example of fetching teams and channels that would be implemented with API calls
          'teams': [
            {'id': '1', 'name': 'Engineering', 'display_name': 'Engineering Team'},
            {'id': '2', 'name': 'Product', 'display_name': 'Product Team'},
          ],
          'channels_in_common': [
            {'id': '1', 'display_name': 'General', 'type': 'O'},
            {'id': '2', 'display_name': 'Development', 'type': 'P'},
            {'id': '3', 'display_name': 'Random', 'type': 'O'},
          ],
        };
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startDirectMessage() async {
    // TODO: Create direct message with this user
    Navigator.pushNamed(context, '/direct-messages', arguments: _userDetails);
  }

  void _sendEmail() async {
    // TODO: Open email app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email to ${_userDetails?['email']}')),
    );
  }

  void _callUser() async {
    // TODO: Initiate call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${_userDetails?['phone']}')),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'dnd':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'online':
        return 'Online';
      case 'away':
        return 'Away';
      case 'dnd':
        return 'Do Not Disturb';
      default:
        return 'Offline';
    }
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else {
      return 'Active ${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _userDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('@${_userDetails!['username']}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'copy_username':
                  // TODO: Copy username to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username copied')),
                  );
                  break;
                case 'view_teams':
                  // TODO: Show teams this user is part of
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_username',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy Username'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'view_teams',
                child: ListTile(
                  leading: Icon(Icons.group),
                  title: Text('View Teams'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Text(
                          (_userDetails!['first_name']?[0] ?? _userDetails!['username'][0]).toUpperCase(),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getStatusColor(_userDetails!['status']),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_userDetails!['first_name']} ${_userDetails!['last_name']}'.trim().isEmpty
                        ? '@${_userDetails!['username']}'
                        : '${_userDetails!['first_name']} ${_userDetails!['last_name']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${_userDetails!['username']}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_userDetails!['position']?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      _userDetails!['position'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getStatusColor(_userDetails!['status']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(_userDetails!['status']),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${_formatLastActivity(_userDetails!['last_activity_at'])}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Custom status
          if (_userDetails!['custom_status']?['text']?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Text(
                  _userDetails!['custom_status']['emoji'],
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(_userDetails!['custom_status']['text']),
                subtitle: Text(
                  'Status expires in ${_userDetails!['custom_status']['expires_at'].difference(DateTime.now()).inHours}h',
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('Send Message'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _startDirectMessage,
                ),
                if (_userDetails!['email']?.isNotEmpty == true) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Send Email'),
                    subtitle: Text(_userDetails!['email']),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _sendEmail,
                  ),
                ],
                if (_userDetails!['phone']?.isNotEmpty == true) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Call'),
                    subtitle: Text(_userDetails!['phone']),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _callUser,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // User info
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_userDetails!['timezone']?.isNotEmpty == true)
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Timezone'),
                    subtitle: Text(_userDetails!['timezone']),
                  ),
                if (_userDetails!['roles']?.isNotEmpty == true) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Roles'),
                    subtitle: Text((_userDetails!['roles'] as List).join(', ')),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Teams
          if (_userDetails!['teams']?.isNotEmpty == true) ...[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Teams',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...(_userDetails!['teams'] as List).map(
                    (team) => ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text(team['display_name'][0].toUpperCase()),
                      ),
                      title: Text(team['display_name']),
                      onTap: () {
                        // TODO: Navigate to team
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Channels in common
          if (_userDetails!['channels_in_common']?.isNotEmpty == true) ...[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Channels in Common',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...(_userDetails!['channels_in_common'] as List)
                      .take(5)
                      .map(
                        (channel) => ListTile(
                          leading: Icon(
                            channel['type'] == 'P' ? Icons.lock : Icons.tag,
                            color: Colors.grey[600],
                          ),
                          title: Text(channel['display_name']),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/channel',
                              arguments: {
                                'client': null,
                                'channel': channel,
                                'currentUser': null,
                              },
                            );
                          },
                        ),
                      ),
                  if ((_userDetails!['channels_in_common'] as List).length > 5)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'and ${(_userDetails!['channels_in_common'] as List).length - 5} more...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
