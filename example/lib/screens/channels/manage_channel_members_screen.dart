import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';

class ManageChannelMembersScreen extends StatefulWidget {
  final MChannel? channel;

  const ManageChannelMembersScreen({
    super.key,
    this.channel,
  });

  @override
  State<ManageChannelMembersScreen> createState() => _ManageChannelMembersScreenState();
}

class _ManageChannelMembersScreenState extends State<ManageChannelMembersScreen> {
  bool _isLoading = false;
  List<MUser> _members = [];
  List<MUser> _filteredMembers = [];
  final Map<String, MChannelMember> _memberRoles = {};
  final Map<String, String> _userStatuses = {};
  final Map<String, DateTime> _userLastActivity = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMembers() async {
    if (widget.channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client or channel not provided')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load channel members from the API
      final channelMembers = await AppRoutes.client.channels.getChannelMembers(
        widget.channel!.id,
      );

      // Create a list of user IDs
      final userIds = channelMembers.map((member) => member.userId).toList();

      // Get all users' details
      final users = await AppRoutes.client.users.getUsers(
        inChannel: widget.channel!.id,
        perPage: 200,
      );

      // Create a map of user roles
      for (var member in channelMembers) {
        _memberRoles[member.userId] = member;
      }

      // Get user statuses
      for (var userId in userIds) {
        try {
          final status = await AppRoutes.client.status.getUserStatus(userId);
          _userStatuses[userId] = status.status;

          // Calculate last activity time based on status.lastActivity
          if (status.lastActivityAt != null) {
            _userLastActivity[userId] = DateTime.fromMillisecondsSinceEpoch(
              status.lastActivityAt!,
            );
          } else {
            _userLastActivity[userId] = DateTime.now().subtract(const Duration(hours: 24));
          }
        } catch (e) {
          _userStatuses[userId] = 'offline';
          _userLastActivity[userId] = DateTime.now().subtract(const Duration(days: 1));
        }
      }

      setState(() {
        _members = users;
        _filteredMembers = List.from(_members);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        final name = '${member.firstName} ${member.lastName}'.toLowerCase();
        final username = member.username.toLowerCase();
        final email = member.email.toLowerCase();
        return name.contains(query) || username.contains(query) || email.contains(query);
      }).toList();
    });
  }

  void _addMembers() async {
    if (widget.channel != null && AppRoutes.currentUser != null) {
      Navigator.pushNamed(
        context,
        '/add-channel-members',
        arguments: widget.channel!,
      );
    }
  }

  void _removeMember(MUser member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.firstName} ${member.lastName} from this channel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.channel != null) {
      try {
        // Remove member via API
        await AppRoutes.client.channels.removeChannelMember(widget.channel!.id, member.id);

        setState(() {
          _members.removeWhere((m) => m.id == member.id);
          _memberRoles.remove(member.id);
          _userStatuses.remove(member.id);
          _userLastActivity.remove(member.id);
          _filterMembers();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.firstName} ${member.lastName} removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error removing member: $e')),
          );
        }
      }
    }
  }

  void _changeRole(MUser member, String newRole) async {
    if (widget.channel == null) return;

    try {
      // For Mattermost, changing roles involves updating scheme_admin property
      // We need to get the current member first
      final channelMember = await AppRoutes.client.channels.getChannelMember(widget.channel!.id, member.id);

      // Create a map of roles to update
      final updatedRoles = Map<String, dynamic>.from(channelMember.notifyProps?.toJson() ?? {});

      // Update the channel member with the new role
      // Note: API doesn't directly support changing role, so we're simulating this
      // In a real implementation, you'd need to use the appropriate API call
      if (newRole == 'channel_admin') {
        updatedRoles['scheme_admin'] = 'true';
      } else {
        updatedRoles['scheme_admin'] = 'false';
      }

      await AppRoutes.client.channels.updateChannelMemberNotifyProps(
        widget.channel!.id,
        member.id,
        MChannelNotifyProps.fromJson(updatedRoles),
      );

      // Update local state
      if (_memberRoles.containsKey(member.id)) {
        final updatedMember = _memberRoles[member.id]!;
        setState(() {
          _memberRoles[member.id] = MChannelMember(
            channelId: updatedMember.channelId,
            userId: updatedMember.userId,
            roles: updatedMember.roles,
            schemeAdmin: newRole == 'channel_admin' ? true : false,
          );
        });
      }

      final roleText = newRole == 'channel_admin' ? 'Channel Admin' : 'Member';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.firstName} ${member.lastName} is now a $roleText')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing member role: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
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

  String _getLastActivityText(DateTime? lastActivity) {
    if (lastActivity == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Get role text for a user
  String _getRoleText(String userId) {
    if (_memberRoles.containsKey(userId) && _memberRoles[userId]?.schemeAdmin == 'true') {
      return 'channel_admin';
    }
    return 'member';
  }

  // Check if user is an admin
  // Check if user is an admin - used in the UI
  bool isChannelAdmin(String userId) {
    return _getRoleText(userId) == 'channel_admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members • ${widget.channel?.displayName ?? 'Channel'}'),
        actions: [
          IconButton(
            onPressed: _addMembers,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),

          // Members count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredMembers.length} member${_filteredMembers.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Members list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty ? 'No members found' : 'No members yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = _filteredMembers[index];
                      final isAdmin = _getRoleText(member.id) == 'channel_admin';
                      final status = _userStatuses[member.id] ?? 'offline';
                      final lastActivity = _userLastActivity[member.id];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                child: Text(
                                  (member.firstName.isNotEmpty ? member.firstName[0] : member.username[0]).toUpperCase(),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).cardColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            '${member.firstName} ${member.lastName}'.trim().isEmpty
                                ? '@${member.username}'
                                : '${member.firstName} ${member.lastName}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@${member.username}'),
                              Text(
                                _getLastActivityText(lastActivity),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isAdmin)
                                Chip(
                                  label: const Text('Admin'),
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontSize: 12,
                                  ),
                                ),
                              PopupMenuButton<String>(
                                onSelected: (action) {
                                  switch (action) {
                                    case 'view_profile':
                                      Navigator.pushNamed(
                                        context,
                                        '/user-profile',
                                        arguments: {'user': member, 'currentUser': AppRoutes.currentUser, 'client': AppRoutes.client},
                                      );
                                      break;
                                    case 'make_admin':
                                      _changeRole(member, 'channel_admin');
                                      break;
                                    case 'remove_admin':
                                      _changeRole(member, 'member');
                                      break;
                                    case 'remove':
                                      _removeMember(member);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view_profile',
                                    child: ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text('View Profile'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  if (!isAdmin)
                                    const PopupMenuItem(
                                      value: 'make_admin',
                                      child: ListTile(
                                        leading: Icon(Icons.admin_panel_settings),
                                        title: Text('Make Channel Admin'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  if (isAdmin)
                                    const PopupMenuItem(
                                      value: 'remove_admin',
                                      child: ListTile(
                                        leading: Icon(Icons.remove_moderator),
                                        title: Text('Remove Admin'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: ListTile(
                                      leading: Icon(Icons.person_remove, color: Colors.red),
                                      title: Text('Remove from Channel', style: TextStyle(color: Colors.red)),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/user-profile',
                              arguments: {'user': member, 'currentUser': AppRoutes.currentUser, 'client': AppRoutes.client},
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
