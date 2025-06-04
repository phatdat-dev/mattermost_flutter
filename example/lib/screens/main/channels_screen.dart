import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../constants/screens.dart';
import '../../routes/app_routes.dart';
import '../../services/navigation_service.dart';
import '../../widgets/message_composer.dart';

class ChannelsScreen extends StatefulWidget {
  final MChannel channel;

  const ChannelsScreen({
    super.key,
    required this.channel,
  });

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
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

  Future<void> _sendMessage(String message, List<File>? attachments) async {
    if (message.trim().isEmpty && (attachments == null || attachments.isEmpty)) return;

    try {
      List<String>? fileIds;

      // Upload files first if there are attachments
      if (attachments != null && attachments.isNotEmpty) {
        fileIds = [];
        for (final file in attachments) {
          try {
            final uploadResponse = await AppRoutes.client.files.uploadFile(
              channelId: widget.channel.id,
              file: file,
            );
            // Extract file ID from upload response
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

      // Create post with message and file attachments
      final post = await AppRoutes.client.posts.createPost(
        channelId: widget.channel.id,
        message: message.trim(),
        fileIds: fileIds,
      );

      // Add post to local state for immediate UI update
      setState(() {
        _posts.posts[post.id] = post;
        _posts.order.insert(0, post.id);
      });

      // Scroll to bottom to show new message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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

            // Message content
            if (post.message.isNotEmpty) Text(post.message),

            // File attachments
            if (post.fileIds != null && post.fileIds!.isNotEmpty) _buildFileAttachments(post.fileIds!),

            const SizedBox(height: 8),

            // Thread reply indicator
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
                    '00 replies',
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

  Widget _buildFileAttachments(List<String> fileIds) {
    return FutureBuilder<List<MFileInfo>>(
      future: _loadFileInfos(fileIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final files = snapshot.data!;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: files.map((file) => _buildFileAttachment(file)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFileAttachment(MFileInfo file) {
    final isImage = file.mimeType.startsWith('image/');

    if (isImage) {
      return GestureDetector(
        onTap: () => _openImageViewer(file),
        child: Container(
          width: 150,
          height: 150,
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
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _openFileViewer(file),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getFileIcon(file.extension), color: Colors.blue),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _formatFileSize(file.size),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMessageInput() {
    return MessageComposer(
      onSendMessage: _sendMessage,
      onEmojiSelected: _handleEmojiSelection,
      onFileAttachment: _handleFileAttachment,
      channelId: widget.channel.id,
      placeholder: 'Message ${widget.channel.displayName}',
    );
  }

  Future<void> _handleFileAttachment() async {
    // This is handled by MessageComposer internally
  }

  void _handleEmojiSelection(String emoji) {
    // Handle emoji selection if needed
    debugPrint('Emoji selected: $emoji');
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
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _openImageViewer(MFileInfo file) {
    NavigationService.pushNamed(
      Screens.imageViewer,
      arguments: {
        'fileInfo': file,
        'imageUrl': '${AppRoutes.client.config.baseUrl}/api/v4/files/${file.id}',
      },
    );
  }

  void _openFileViewer(MFileInfo file) {
    NavigationService.pushNamed(
      Screens.fileViewer,
      arguments: file,
    );
  }
}
