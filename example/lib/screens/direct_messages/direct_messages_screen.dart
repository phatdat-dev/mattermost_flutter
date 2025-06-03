import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';
import '../main/channels_screen.dart';
import 'group_chat_screen.dart';

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({super.key});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final _searchController = TextEditingController();
  List<MChannel> _directChannels = [];
  List<MUser> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadDirectChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadDirectChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get all channels for the current user
      final allChannels = await Future.wait(
        (await AppRoutes.client.teams.getTeamsForUser(
          AppRoutes.currentUser!.id,
        )).map((team) => AppRoutes.client.channels.getChannelsForUser(AppRoutes.currentUser!.id, team.id)),
      );

      // Flatten the list and filter direct message channels (type 'D')
      final directChannels = allChannels.expand((channels) => channels).where((channel) => channel.type == 'D').toList();

      setState(() {
        _directChannels = directChannels;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load direct messages: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      final users = await AppRoutes.client.users.searchUsers(
        term: term,
        limit: 20,
      );

      // Filter out the current user
      setState(() {
        _searchResults = users.where((user) => user.id != AppRoutes.currentUser!.id).toList();
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

  Future<void> _startDirectChat(MUser user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a direct message channel
      final channel = await AppRoutes.client.channels.createDirectChannel(AppRoutes.currentUser!.id, user.id);

      if (!mounted) return;

      // Navigate to the chat screen
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) =>
                  DirectChatScreen(client: AppRoutes.client, currentUser: AppRoutes.currentUser!, otherUser: user, channel: channel),
            ),
          )
          .then((_) {
            // Refresh the list when returning from chat
            _loadDirectChannels();
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create direct message: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openExistingChat(MChannel channel) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the other user's ID from the channel name
      // Direct message channel names are in the format [user_id]__[other_user_id]
      final userIds = channel.name.split('__');
      final otherUserId = userIds[0] == AppRoutes.currentUser!.id ? userIds[1] : userIds[0];

      // Get the other user's details
      final otherUser = await AppRoutes.client.users.getUser(otherUserId);

      if (!mounted) return;

      // Navigate to the chat screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              DirectChatScreen(client: AppRoutes.client, currentUser: AppRoutes.currentUser!, otherUser: otherUser, channel: channel),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open chat: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
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

          // Search results or direct message list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _searchResults.isNotEmpty
                ? _buildSearchResults()
                : _searchController.text.isNotEmpty && _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isNotEmpty && _searchResults.isEmpty
                ? const Center(child: Text('No users found'))
                : _buildDirectChannelsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _createGroupChat, tooltip: 'Create Group Chat', child: const Icon(Icons.group_add)),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
          ),
          title: Text(user.username),
          subtitle: Text('${user.firstName} ${user.lastName}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chat),
          onTap: () => _startDirectChat(user),
        );
      },
    );
  }

  Widget _buildDirectChannelsList() {
    if (_directChannels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No direct messages yet'),
            const SizedBox(height: 16),
            const Text('Search for users to start a conversation'),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _createGroupChat, icon: const Icon(Icons.group_add), label: const Text('Create Group Chat')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDirectChannels,
      child: ListView.builder(
        itemCount: _directChannels.length,
        itemBuilder: (context, index) {
          final channel = _directChannels[index];
          return FutureBuilder<Widget>(
            future: _buildDirectChannelTile(channel),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
                  title: Text('Loading...'),
                );
              }
              return snapshot.data ?? const SizedBox();
            },
          );
        },
      ),
    );
  }

  Future<void> _createGroupChat() async {
    final selectedUsers = await Navigator.of(context).push<List<MUser>>(
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(client: AppRoutes.client, currentUser: AppRoutes.currentUser!, existingMembers: []),
      ),
    );

    if (selectedUsers != null && selectedUsers.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Add current user to the list
        final allMembers = [AppRoutes.currentUser!, ...selectedUsers];
        final userIds = allMembers.map((user) => user.id).toList();

        // Create group message channel
        final channel = await AppRoutes.client.channels.createGroupChannel(userIds);

        if (!mounted) return;

        // Navigate to the group chat screen
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) =>
                    GroupChatScreen(client: AppRoutes.client, currentUser: AppRoutes.currentUser!, channel: channel, members: allMembers),
              ),
            )
            .then((_) {
              // Refresh the list when returning from chat
              _loadDirectChannels();
            });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create group chat: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<Widget> _buildDirectChannelTile(MChannel channel) async {
    try {
      // Get the other user's ID from the channel name
      final userIds = channel.name.split('__');
      final otherUserId = userIds[0] == AppRoutes.currentUser!.id ? userIds[1] : userIds[0];

      // Get the other user's details
      final otherUser = await AppRoutes.client.users.getUser(otherUserId);

      // Get the last message in the channel
      final postList = await AppRoutes.client.posts.getPostsForChannel(channel.id, perPage: 1);
      final lastPost = postList.posts.isNotEmpty ? postList.posts.values.first : null;

      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(otherUser.username.isNotEmpty ? otherUser.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(otherUser.username),
        subtitle: lastPost != null ? Text(lastPost.message, maxLines: 1, overflow: TextOverflow.ellipsis) : const Text('No messages yet'),
        trailing: lastPost != null
            ? Text(_formatTimestamp(lastPost.createAt ?? 0), style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color))
            : null,
        onTap: () => _openExistingChat(channel),
      );
    } catch (e) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.error,
          child: const Icon(Icons.error, color: Colors.white),
        ),
        title: const Text('Error loading chat'),
        subtitle: Text(e.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
      );
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

class DirectChatScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MUser otherUser;
  final MChannel channel;

  const DirectChatScreen({super.key, required this.client, required this.currentUser, required this.otherUser, required this.channel});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<MPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _websocketSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
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
    _websocketSubscription = AppRoutes.client.webSocket.events.listen((event) {
      if (event['event'] == 'posted' && event['data'] != null && event['data']['channel_id'] == widget.channel.id) {
        // Reload posts when a new message is posted in this channel
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
      // Get posts for the channel
      final postList = await AppRoutes.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);

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
      // Get posts for the channel
      final postList = await AppRoutes.client.posts.getPostsForChannel(widget.channel.id, perPage: 50);

      if (mounted) {
        setState(() {
          _posts = postList.posts.values.toList()..sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));
        });
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await AppRoutes.client.posts.createPost(channelId: widget.channel.id, message: message);

      // Reload posts after sending a message
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _addReaction(MPost post, String emoji) async {
    try {
      await AppRoutes.client.posts.addReaction(userId: AppRoutes.currentUser!.id, postId: post.id, emojiName: emoji);

      // Reload posts after adding a reaction
      _loadPosts();
    } catch (e) {
      debugPrint('Failed to add reaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add reaction: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: Text(
                widget.otherUser.username.isNotEmpty ? widget.otherUser.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUser.username),
                  if (widget.otherUser.firstName.isNotEmpty || widget.otherUser.lastName.isNotEmpty)
                    Text('${widget.otherUser.firstName} ${widget.otherUser.lastName}'.trim(), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show user info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.otherUser.username),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${widget.otherUser.id}'),
                      const SizedBox(height: 8),
                      Text('Name: ${widget.otherUser.firstName} ${widget.otherUser.lastName}'),
                      const SizedBox(height: 8),
                      Text('Email: ${widget.otherUser.email}'),
                      const SizedBox(height: 8),
                      Text('Position: ${widget.otherUser.position}'),
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
                        return DirectMessageTile(
                          post: post,
                          currentUser: AppRoutes.currentUser!,
                          otherUser: widget.otherUser,
                          onReactionTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => ReactionPicker(
                                onEmojiSelected: (emoji) {
                                  Navigator.pop(context);
                                  _addReaction(post, emoji);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // File attachment functionality
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24.0))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DirectMessageTile extends StatelessWidget {
  final MPost post;
  final MUser currentUser;
  final MUser otherUser;
  final VoidCallback onReactionTap;

  const DirectMessageTile({super.key, required this.post, required this.currentUser, required this.otherUser, required this.onReactionTap});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = post.userId == currentUser.id;
    final user = isCurrentUser ? currentUser : otherUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
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
                  Text(post.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        post.createAt != null ? _formatTimestamp(post.createAt!) : 'Unknown time',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      const SizedBox(width: 8),
                      InkWell(onTap: onReactionTap, child: const Icon(Icons.emoji_emotions_outlined, size: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
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
