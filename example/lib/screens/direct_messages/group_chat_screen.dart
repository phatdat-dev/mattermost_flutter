import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';
import '../../widgets/message_composer.dart';

class GroupChatScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MChannel channel;
  final List<MUser> members;

  const GroupChatScreen({super.key, required this.client, required this.currentUser, required this.channel, required this.members});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<MPost> _posts = [];
  List<MUser> _members = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _websocketSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members);
    _loadPosts();
    _setupWebSocket();

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshPosts();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _websocketSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupWebSocket() {
    _websocketSubscription = widget.client.webSocket.events.listen((event) {
      if (event['event'] == 'posted' && event['data'] != null && event['data']['channel_id'] == widget.channel.id) {
        _loadPosts();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);
      setState(() {
        _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    if (_isLoading) return;

    try {
      final postList = await widget.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);
      if (mounted) {
        setState(() {
          _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
        });
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
    }
  }

  Future<void> _sendMessage(String message, List<File>? attachments) async {
    if (message.trim().isEmpty && (attachments == null || attachments.isEmpty)) return;

    try {
      List<String>? fileIds;

      // Upload files first if there are attachments
      if (attachments != null && attachments.isNotEmpty) {
        fileIds = [];
        for (final file in attachments) {
          try {
            final uploadResponse = await widget.client.files.uploadFile(
              channelId: widget.channel.id,
              file: file,
            );
            if (uploadResponse.fileInfos.isNotEmpty) {
              fileIds.add(uploadResponse.fileInfos.first.id);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload file: ${file.path.split('/').last}')),
            );
          }
        }
      }

      // Create post
      await widget.client.posts.createPost(
        channelId: widget.channel.id,
        message: message.trim(),
        fileIds: fileIds,
      );

      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  Future<void> _addMembers() async {
    final result = await Navigator.of(context).push<List<MUser>>(
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(client: widget.client, currentUser: widget.currentUser, existingMembers: _members),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _members.addAll(result);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${result.length} member(s) to the group')));
    }
  }

  Future<void> _showMembersList() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => MembersListSheet(
        members: _members,
        currentUser: widget.currentUser,
        onRemoveMember: (user) {
          setState(() {
            _members.removeWhere((member) => member.id == user.id);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed ${user.username} from the group')));
        },
      ),
    );
  }

  String _getGroupName() {
    if (_members.length <= 3) {
      return _members.map((m) => m.username).join(', ');
    } else {
      return '${_members.take(2).map((m) => m.username).join(', ')} and ${_members.length - 2} others';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGroupName(), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${_members.length} members', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: _addMembers, tooltip: 'Add Members'),
          IconButton(icon: const Icon(Icons.people), onPressed: _showMembersList, tooltip: 'View Members'),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Group Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Channel ID: ${widget.channel.id}'),
                      const SizedBox(height: 8),
                      Text('Members: ${_members.length}'),
                      const SizedBox(height: 8),
                      const Text('Type: Group Chat'),
                    ],
                  ),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _posts.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        final sender = _members.firstWhere((member) => member.id == post.userId, orElse: () => widget.currentUser);
                        return GroupMessageTile(post: post, sender: sender, currentUser: widget.currentUser);
                      },
                    ),
            ),
            MessageComposer(
              onSendMessage: _sendMessage,
              channelId: widget.channel.id,
              placeholder: 'Type a message...',
            ),
          ],
        ),
      ),
    );
  }
}

class AddMembersScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final List<MUser> existingMembers;

  const AddMembersScreen({super.key, required this.client, required this.currentUser, required this.existingMembers});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final _searchController = TextEditingController();
  List<MUser> _searchResults = [];
  final List<MUser> _selectedUsers = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchUsers(String term) async {
    if (term.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final users = await widget.client.users.searchUsers(term: term, limit: 20);

      // Filter out current user and existing members
      final existingIds = widget.existingMembers.map((u) => u.id).toSet();
      existingIds.add(widget.currentUser.id);

      setState(() {
        _searchResults = users.where((user) => !existingIds.contains(user.id)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(value);
    });
  }

  void _toggleUserSelection(MUser user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedUsers);
              },
              child: Text('Add (${_selectedUsers.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_selectedUsers.isNotEmpty)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedUsers[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            label: Text(user.username),
                            onDeleted: () => _toggleUserSelection(user),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text('No users found'))
                : _searchController.text.isEmpty
                ? const Center(child: Text('Search for users to add to the group'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      final isSelected = _selectedUsers.contains(user);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(user.username),
                        subtitle: Text('${user.firstName} ${user.lastName}'.trim()),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.add_circle_outline),
                        onTap: () => _toggleUserSelection(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MembersListSheet extends StatelessWidget {
  final List<MUser> members;
  final MUser currentUser;
  final Function(MUser) onRemoveMember;

  const MembersListSheet({super.key, required this.members, required this.currentUser, required this.onRemoveMember});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group Members (${members.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isCurrentUser = member.id == currentUser.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(member.username.isNotEmpty ? member.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(member.username),
                  subtitle: Text('${member.firstName} ${member.lastName}'.trim()),
                  trailing: isCurrentUser
                      ? const Chip(label: Text('You'))
                      : IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove Member'),
                                content: Text('Are you sure you want to remove ${member.username} from the group?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onRemoveMember(member);
                                    },
                                    child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
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

class GroupMessageTile extends StatelessWidget {
  final MPost post;
  final MUser sender;
  final MUser currentUser;

  const GroupMessageTile({super.key, required this.post, required this.sender, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = post.userId == currentUser.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: Text(
                sender.username.isNotEmpty ? sender.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      sender.username,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  if (post.message.isNotEmpty) Text(post.message, style: const TextStyle(fontSize: 16)),
                  // File attachments
                  if (post.fileIds != null && post.fileIds!.isNotEmpty) _buildFileAttachments(context, post.fileIds!),
                  const SizedBox(height: 4),
                  Text(
                    post.createAt != null ? _formatTimestamp(post.createAt!) : 'Unknown time',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: Text(
                sender.username.isNotEmpty ? sender.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileAttachments(BuildContext context, List<String> fileIds) {
    return FutureBuilder<List<MFileInfo>>(
      future: _loadFileInfos(fileIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final files = snapshot.data!;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: files.map((file) => _buildFileAttachment(context, file)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFileAttachment(BuildContext context, MFileInfo file) {
    final isImage = file.mimeType.startsWith('image/');

    if (isImage) {
      return Container(
        width: 150,
        height: 150,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            '${AppRoutes.client.config.baseUrl}/api/v4/files/${file.id}',
            headers: {
              'Authorization': 'Bearer ${AppRoutes.client.config.token}',
            },
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getFileIcon(file.extension), color: Colors.blue, size: 16),
            const SizedBox(width: 4),
            Text(
              file.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  Future<List<MFileInfo>> _loadFileInfos(List<String> fileIds) async {
    try {
      final List<MFileInfo> files = [];
      for (final fileId in fileIds) {
        final fileInfo = await AppRoutes.client.files.getFileInfo(fileId);
        files.add(fileInfo);
      }
      return files;
    } catch (e) {
      debugPrint('Error loading file infos: $e');
      return [];
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
