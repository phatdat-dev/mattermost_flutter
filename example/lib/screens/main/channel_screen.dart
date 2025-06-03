import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../constants/screens.dart';
import '../../routes/app_routes.dart';
import '../../services/navigation_service.dart';

class ChannelScreen extends StatefulWidget {
  final MChannel channel;

  const ChannelScreen({
    super.key,
    required this.channel,
  });

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  StreamSubscription? _websocketSubscription;

  late MPostList _posts;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  String? _errorMessage;

  static const int _postsPerPage = 60;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _setupWebSocket();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _websocketSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final posts = await AppRoutes.client.posts.getPostsForChannel(
        widget.channel.id,
        page: 0,
        perPage: _postsPerPage,
      );

      setState(() {
        _posts = posts;
        _isLoading = false;
        _hasMorePosts = posts.posts.length >= _postsPerPage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final page = (_posts.posts.length / _postsPerPage).floor();
      final morePosts = await AppRoutes.client.posts.getPostsForChannel(
        widget.channel.id,
        page: page,
        perPage: _postsPerPage,
      );

      setState(() {
        _posts = MPostList(
          posts: {..._posts.posts, ...morePosts.posts},
          order: [..._posts.order, ...morePosts.order],
          nextPostId: morePosts.nextPostId,
          prevPostId: morePosts.prevPostId,
        );
        _hasMorePosts = morePosts.posts.length >= _postsPerPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _setupWebSocket() {
    _websocketSubscription = AppRoutes.client.webSocket.events.listen((event) {
      // event typing
      if (event['event'] == 'typing' && event['data'] != null) {
        final typingData = event['data'];
        if (typingData['channel_id'] == widget.channel.id) {
          debugPrint('User ${typingData['user_id']} is typing in channel ${widget.channel.displayName}');
        }
      }

      // event posted
      if (event['event'] == 'posted' && event['data'] != null) {
        final post = MPost.fromJson(jsonDecode(event['data']['post']));
        if (post.channelId == widget.channel.id) {
          setState(() {
            _posts.posts[post.id] = post;
            _posts.order.insert(0, post.id);
          });
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      _messageController.clear();

      await AppRoutes.client.posts.createPost(
        channelId: widget.channel.id,
        message: message,
      );
      _messageFocusNode.requestFocus();
      setState(() {
        _posts.posts[DateTime.now().millisecondsSinceEpoch.toString()] = MPost(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          channelId: widget.channel.id,
          message: message,
          createAt: DateTime.now().millisecondsSinceEpoch,
          userId: AppRoutes.currentUser!.id,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  void _openThread(MPost post) {
    NavigationService.pushNamed(
      Screens.thread,
      arguments: post,
    );
  }

  void _showChannelInfo() {
    NavigationService.pushNamed(Screens.channelInfo);
  }

  void _showPostOptions(MPost post) {
    NavigationService.pushNamed(
      Screens.postOptions,
      arguments: {'post': post, 'client': AppRoutes.client},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _getChannelIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (widget.channel.header.isNotEmpty)
                    Text(
                      widget.channel.header,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => NavigationService.pushNamed(Screens.searchMessages),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showChannelInfo,
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPosts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: _posts.posts.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.posts.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final post = _posts.posts.entries.elementAt(_posts.posts.length - 1 - index).value;
                        return _buildPostItem(post);
                      },
                    ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _getChannelIcon() {
    switch (widget.channel.type) {
      case 'O':
        return const Icon(Icons.tag, size: 20);
      case 'P':
        return const Icon(Icons.lock, size: 20);
      case 'D':
        return const Icon(Icons.person, size: 20);
      case 'G':
        return const Icon(Icons.group, size: 20);
      default:
        return const Icon(Icons.tag, size: 20);
    }
  }

  Widget _buildPostItem(MPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    post.userId.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   post.id, // In a real app, you'd resolve this to username
                      //   style: const TextStyle(fontWeight: FontWeight.w600),
                      // ),
                      Text(
                        _formatTimestamp(post.createAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'reply':
                        _openThread(post);
                        break;
                      case 'options':
                        _showPostOptions(post);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'reply',
                      child: Text('Reply in thread'),
                    ),
                    const PopupMenuItem(
                      value: 'options',
                      child: Text('More options'),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.message),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => _openThread(post),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    '{00} replies',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
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
