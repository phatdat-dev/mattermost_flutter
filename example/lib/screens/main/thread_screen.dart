import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../../routes/app_routes.dart';
import '../../widgets/message_composer.dart';

class ThreadScreen extends StatefulWidget {
  final MPost post;

  const ThreadScreen({
    super.key,
    required this.post,
  });

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  final List<MPost> _replies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadThread();
    _setupWebSocket();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadThread() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final replies = await AppRoutes.client.posts.getPostThread(widget.post.id);
      debugPrint('Loaded ${replies.posts.length} replies for thread ${widget.post.id}');

      setState(() {
        _replies.clear();
        _replies.addAll(replies.posts.values);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load thread: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _setupWebSocket() {
    // _wsConnection = AppRoutes.client.connectWebSocket();
    // _wsConnection?.onMessage = (event) {
    //   if (event['event'] == 'posted') {
    //     final post = MPost.fromJson(event['data']['post']);
    //     if (post.rootId == widget.post.id) {
    //       setState(() {
    //         _replies.add(post);
    //       });
    //     }
    //   }
    // };
  }

  Future<void> _sendReply(String message, List<File>? attachments) async {
    if (message.trim().isEmpty && (attachments == null || attachments.isEmpty)) return;

    try {
      List<String>? fileIds;

      // Upload files first if there are attachments
      if (attachments != null && attachments.isNotEmpty) {
        fileIds = [];
        for (final file in attachments) {
          try {
            final uploadResponse = await AppRoutes.client.files.uploadFile(
              channelId: widget.post.channelId,
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

      // Create reply post
      await AppRoutes.client.posts.createPost(
        channelId: widget.post.channelId,
        message: message.trim(),
        rootId: widget.post.id,
        fileIds: fileIds,
      );

      // Reload thread to show new reply
      _loadThread();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reply: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show thread options
            },
          ),
        ],
      ),
      body: Column(
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
                          onPressed: _loadThread,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      // Original post
                      _buildOriginalPost(),
                      const Divider(),

                      // Thread replies
                      if (_replies.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '${_replies.length} replies',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ..._replies.map((reply) => _buildReplyItem(reply)),
                      ] else
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No replies yet. Be the first to reply!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildOriginalPost() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.post.userId.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
                      widget.post.userId, // In a real app, resolve to username
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatTimestamp(widget.post.createAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.post.message,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(MPost reply) {
    return Container(
      margin: const EdgeInsets.only(left: 32, right: 16, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[400],
                child: Text(
                  reply.userId.substring(0, 2).toUpperCase(),
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
                      reply.userId, // In a real app, resolve to username
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatTimestamp(reply.createAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (reply.message.isNotEmpty) Text(reply.message),

          // File attachments for replies
          if (reply.fileIds != null && reply.fileIds!.isNotEmpty) _buildFileAttachments(reply.fileIds!),
        ],
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

  Widget _buildFileAttachment(MFileInfo file) {
    final isImage = file.mimeType.startsWith('image/');

    if (isImage) {
      return Container(
        width: 100,
        height: 100,
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

  Widget _buildReplyInput() {
    return MessageComposer(
      onSendMessage: _sendReply,
      channelId: widget.post.channelId,
      placeholder: 'Reply to thread...',
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
