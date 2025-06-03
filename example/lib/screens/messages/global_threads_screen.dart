import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';

class GlobalThreadsScreen extends StatefulWidget {
  const GlobalThreadsScreen({
    super.key,
  });

  @override
  State<GlobalThreadsScreen> createState() => _GlobalThreadsScreenState();
}

class _GlobalThreadsScreenState extends State<GlobalThreadsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _threads = [];
  String _selectedFilter = 'unread';
  List<MTeam> _teams = [];
  StreamSubscription? _websocketSubscription;

  @override
  void initState() {
    super.initState();
    _loadThreads();
    _setupWebSocket();
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    super.dispose();
  }

  void _setupWebSocket() {
    _websocketSubscription = AppRoutes.client.webSocket.events.listen((event) {
      if (event['event'] == 'posted' || event['event'] == 'thread_updated' || event['event'] == 'post_updated') {
        // Reload threads when posts are updated
        _loadThreads();
      }
    });
  }

  void _loadThreads() async {
    setState(() => _isLoading = true);

    try {
      // Get teams for the current user
      _teams = await AppRoutes.client.teams.getTeamsForUser(AppRoutes.currentUser!.id);

      List<Map<String, dynamic>> allThreads = [];

      // For each team, get channels and then find threaded posts
      for (final team in _teams) {
        try {
          final channels = await AppRoutes.client.channels.getChannelsForUser(
            AppRoutes.currentUser!.id,
            team.id,
          );

          for (final channel in channels) {
            try {
              // Get posts for this channel
              final postList = await AppRoutes.client.posts.getPostsForChannel(
                channel.id,
                perPage: 50,
              );

              // Find posts that have replies (threads)
              final threadPosts = postList.posts.values
                  .where((post) => post.rootId == null) // Only root posts
                  .toList();

              for (final rootPost in threadPosts) {
                try {
                  // Get the thread for this post
                  final threadList = await AppRoutes.client.posts.getPostThread(rootPost.id);
                  final replies = threadList.posts.values.where((post) => post.rootId == rootPost.id).toList();

                  if (replies.isNotEmpty) {
                    // Get users for participants
                    final participantIds = replies
                        .map((post) => post.userId)
                        .toSet()
                        .take(10) // Limit for performance
                        .toList();

                    List<MUser> participants = [];
                    for (final userId in participantIds) {
                      try {
                        final user = await AppRoutes.client.users.getUser(userId);
                        participants.add(user);
                      } catch (e) {
                        // Skip if user not found
                      }
                    }

                    // Get original post author
                    MUser? originalAuthor;
                    try {
                      originalAuthor = await AppRoutes.client.users.getUser(rootPost.userId);
                    } catch (e) {
                      // Skip if user not found
                    }

                    if (originalAuthor != null) {
                      // Check if user is following this thread
                      bool isFollowing = await _isFollowingThread(rootPost.id);

                      // Calculate unread counts (simplified - in real app you'd track read state)
                      final unreadReplies = replies.length; // Simplified
                      final unreadMentions = _countMentions(replies, AppRoutes.currentUser!.username);

                      final lastReply = replies.isNotEmpty ? replies.reduce((a, b) => (a.createAt ?? 0) > (b.createAt ?? 0) ? a : b) : rootPost;

                      allThreads.add({
                        'id': rootPost.id,
                        'original_post': {
                          'id': rootPost.id,
                          'message': rootPost.message,
                          'user': {
                            'username': originalAuthor.username,
                            'first_name': originalAuthor.firstName,
                            'last_name': originalAuthor.lastName,
                          },
                          'created_at': DateTime.fromMillisecondsSinceEpoch(rootPost.createAt ?? 0),
                        },
                        'channel': {
                          'id': channel.id,
                          'display_name': channel.displayName,
                          'type': channel.type,
                        },
                        'reply_count': replies.length,
                        'participants': participants
                            .map(
                              (user) => {
                                'username': user.username,
                                'first_name': user.firstName,
                              },
                            )
                            .toList(),
                        'last_reply_at': DateTime.fromMillisecondsSinceEpoch(lastReply.createAt ?? 0),
                        'unread_replies': unreadReplies,
                        'unread_mentions': unreadMentions,
                        'is_following': isFollowing,
                      });
                    }
                  }
                } catch (e) {
                  // Skip if thread loading fails
                  debugPrint('Error loading thread for post ${rootPost.id}: $e');
                }
              }
            } catch (e) {
              // Skip if channel posts loading fails
              debugPrint('Error loading posts for channel ${channel.id}: $e');
            }
          }
        } catch (e) {
          // Skip if channels loading fails
          debugPrint('Error loading channels for team ${team.id}: $e');
        }
      }

      // Sort threads by last reply time (most recent first)
      allThreads.sort((a, b) {
        final aTime = a['last_reply_at'] as DateTime;
        final bTime = b['last_reply_at'] as DateTime;
        return bTime.compareTo(aTime);
      });

      setState(() {
        _threads = allThreads;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading threads: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _isFollowingThread(String postId) async {
    try {
      // Check if user has a preference for following this thread
      final preferences = await AppRoutes.client.preferences.getUserPreferencesByCategory(
        AppRoutes.currentUser!.id,
        'thread_follow',
      );

      return preferences.any((pref) => pref.name == postId && pref.value == 'true');
    } catch (e) {
      // Default to not following if we can't check
      return false;
    }
  }

  int _countMentions(List<MPost> posts, String username) {
    int mentionCount = 0;
    for (final post in posts) {
      if (post.message.contains('@$username')) {
        mentionCount++;
      }
    }
    return mentionCount;
  }

  List<Map<String, dynamic>> get _filteredThreads {
    switch (_selectedFilter) {
      case 'unread':
        return _threads.where((thread) => thread['unread_replies'] > 0 || thread['unread_mentions'] > 0).toList();
      case 'following':
        return _threads.where((thread) => thread['is_following'] == true).toList();
      default:
        return _threads;
    }
  }

  void _toggleFollowThread(Map<String, dynamic> thread) async {
    final postId = thread['id'] as String;
    final currentlyFollowing = thread['is_following'] as bool;

    try {
      // Update preference via API
      final preference = MPreference(
        userId: AppRoutes.currentUser!.id,
        category: 'thread_follow',
        name: postId,
        value: (!currentlyFollowing).toString(),
      );

      if (!currentlyFollowing) {
        // Start following
        await AppRoutes.client.preferences.saveUserPreferences(
          AppRoutes.currentUser!.id,
          [preference],
        );
      } else {
        // Stop following
        await AppRoutes.client.preferences.deleteUserPreferences(
          AppRoutes.currentUser!.id,
          [preference],
        );
      }

      setState(() {
        thread['is_following'] = !currentlyFollowing;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentlyFollowing ? 'Following thread' : 'Unfollowed thread',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update thread follow status: $e')),
      );
    }
  }

  void _markAsRead(Map<String, dynamic> thread) async {
    try {
      // In a real implementation, you would track read state via preferences or a separate API
      // For now, we'll use preferences to store the last read timestamp
      final postId = thread['id'] as String;
      final lastReplyTime = (thread['last_reply_at'] as DateTime).millisecondsSinceEpoch;

      final preference = MPreference(
        userId: AppRoutes.currentUser!.id,
        category: 'thread_read',
        name: postId,
        value: lastReplyTime.toString(),
      );

      await AppRoutes.client.preferences.saveUserPreferences(
        AppRoutes.currentUser!.id,
        [preference],
      );

      setState(() {
        thread['unread_replies'] = 0;
        thread['unread_mentions'] = 0;
      });
    } catch (e) {
      debugPrint('Failed to mark thread as read: $e');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildParticipantAvatars(List<dynamic> participants) {
    const maxVisible = 3;
    final visibleParticipants = participants.take(maxVisible).toList();
    final remainingCount = participants.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleParticipants.map(
          (participant) => Container(
            margin: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 10,
              child: Text(
                (participant['first_name']?[0] ?? participant['username'][0]).toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        if (remainingCount > 0)
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.grey[300],
              child: Text(
                '+$remainingCount',
                style: const TextStyle(fontSize: 8, color: Colors.black54),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threads'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'mark_all_read':
                  try {
                    // Mark all threads as read via API
                    final preferences = <MPreference>[];
                    final currentTime = DateTime.now().millisecondsSinceEpoch;

                    for (final thread in _threads) {
                      final postId = thread['id'] as String;
                      preferences.add(
                        MPreference(
                          userId: AppRoutes.currentUser!.id,
                          category: 'thread_read',
                          name: postId,
                          value: currentTime.toString(),
                        ),
                      );
                    }

                    if (preferences.isNotEmpty) {
                      await AppRoutes.client.preferences.saveUserPreferences(
                        AppRoutes.currentUser!.id,
                        preferences,
                      );
                    }

                    setState(() {
                      for (var thread in _threads) {
                        thread['unread_replies'] = 0;
                        thread['unread_mentions'] = 0;
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All threads marked as read')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to mark all as read: $e')),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Mark all as read'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Unread',
                  isSelected: _selectedFilter == 'unread',
                  count: _threads.where((t) => t['unread_replies'] > 0 || t['unread_mentions'] > 0).length,
                  onTap: () => setState(() => _selectedFilter = 'unread'),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Following',
                  isSelected: _selectedFilter == 'following',
                  count: _threads.where((t) => t['is_following'] == true).length,
                  onTap: () => setState(() => _selectedFilter = 'following'),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  count: _threads.length,
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
              ],
            ),
          ),

          // Threads list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredThreads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'unread'
                              ? 'No unread threads'
                              : _selectedFilter == 'following'
                              ? 'No threads you\'re following'
                              : 'No threads yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Threads help organize discussions\naround specific topics',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredThreads.length,
                    itemBuilder: (context, index) {
                      final thread = _filteredThreads[index];
                      final post = thread['original_post'];
                      final hasUnread = thread['unread_replies'] > 0 || thread['unread_mentions'] > 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to thread view - you can implement a ThreadScreen
                            // or navigate to the channel with the thread focused
                            final channel = thread['channel'];
                            final originalPost = thread['original_post'];

                            // For now, show a simple dialog with thread info
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Thread in ${channel['display_name']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Original message:'),
                                    const SizedBox(height: 8),
                                    Text(
                                      originalPost['message'],
                                      style: const TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 16),
                                    Text('${thread['reply_count']} replies'),
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

                            if (hasUnread) {
                              _markAsRead(thread);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thread header
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(
                                        (post['user']['first_name']?[0] ?? post['user']['username'][0]).toUpperCase(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${post['user']['first_name']} ${post['user']['last_name']}'.trim().isEmpty
                                                    ? '@${post['user']['username']}'
                                                    : '${post['user']['first_name']} ${post['user']['last_name']}',
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatDate(post['created_at']),
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              if (thread['channel']['type'] == 'P')
                                                Icon(
                                                  Icons.lock,
                                                  size: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              if (thread['channel']['type'] == 'P') const SizedBox(width: 4),
                                              Text(
                                                thread['channel']['display_name'],
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _toggleFollowThread(thread),
                                      icon: Icon(
                                        thread['is_following'] ? Icons.notifications : Icons.notifications_off,
                                        color: thread['is_following'] ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Original message
                                Text(
                                  post['message'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Thread stats
                                Row(
                                  children: [
                                    _buildParticipantAvatars(thread['participants']),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${thread['reply_count']} ${thread['reply_count'] == 1 ? 'reply' : 'replies'}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Last reply ${_formatDate(thread['last_reply_at'])}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const Spacer(),
                                    if (thread['unread_mentions'] > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${thread['unread_mentions']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (thread['unread_replies'] > 0 && thread['unread_mentions'] == 0)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}
