import 'package:flutter/material.dart';

class PostOptionsScreen extends StatelessWidget {
  final String? postId;
  final bool isOwnPost;
  final bool isPinned;
  final bool isBookmarked;

  const PostOptionsScreen({
    super.key,
    this.postId,
    this.isOwnPost = false,
    this.isPinned = false,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Message Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options list
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildOption(
                  context,
                  icon: Icons.reply,
                  title: 'Reply in Thread',
                  onTap: () {
                    Navigator.of(context).pop();
                    _replyInThread(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  title: isBookmarked ? 'Remove from Saved' : 'Save Message',
                  onTap: () {
                    Navigator.of(context).pop();
                    _toggleBookmark(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.copy,
                  title: 'Copy Text',
                  onTap: () {
                    Navigator.of(context).pop();
                    _copyText(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.link,
                  title: 'Copy Link',
                  onTap: () {
                    Navigator.of(context).pop();
                    _copyLink(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  title: isPinned ? 'Unpin from Channel' : 'Pin to Channel',
                  onTap: () {
                    Navigator.of(context).pop();
                    _togglePin(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.add_reaction_outlined,
                  title: 'Add Reaction',
                  onTap: () {
                    Navigator.of(context).pop();
                    _addReaction(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.share,
                  title: 'Share',
                  onTap: () {
                    Navigator.of(context).pop();
                    _shareMessage(context);
                  },
                ),

                if (isOwnPost) ...[
                  const Divider(height: 1),
                  _buildOption(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Message',
                    onTap: () {
                      Navigator.of(context).pop();
                      _editMessage(context);
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.delete_outline,
                    title: 'Delete Message',
                    titleColor: Theme.of(context).colorScheme.error,
                    iconColor: Theme.of(context).colorScheme.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      _deleteMessage(context);
                    },
                  ),
                ],

                const Divider(height: 1),
                _buildOption(
                  context,
                  icon: Icons.flag_outlined,
                  title: 'Report Message',
                  titleColor: Theme.of(context).colorScheme.error,
                  iconColor: Theme.of(context).colorScheme.error,
                  onTap: () {
                    Navigator.of(context).pop();
                    _reportMessage(context);
                  },
                ),
              ],
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _replyInThread(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply in thread')),
    );
  }

  void _toggleBookmark(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBookmarked ? 'Removed from saved messages' : 'Message saved'),
      ),
    );
  }

  void _copyText(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _copyLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _togglePin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPinned ? 'Message unpinned' : 'Message pinned to channel'),
      ),
    );
  }

  void _addReaction(BuildContext context) {
    // Show emoji picker
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('Emoji Picker'),
        ),
      ),
    );
  }

  void _shareMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing message...')),
    );
  }

  void _editMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit message')),
    );
  }

  void _deleteMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text(
            'Are you sure you want to delete this message? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message deleted')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _reportMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Message'),
          content: const Text(
            'Are you sure you want to report this message? This will notify the moderators.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message reported')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }
}
