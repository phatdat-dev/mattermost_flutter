import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class MessageComposer extends StatefulWidget {
  final void Function(String message, List<File>? attachments) onSendMessage;
  final VoidCallback? onFileAttachment;
  final Function(String emoji)? onEmojiSelected;
  final String channelId;
  final String placeholder;
  final bool showFormatting;
  final bool showAttachments;
  final bool showEmoji;

  const MessageComposer({
    super.key,
    required this.onSendMessage,
    this.onFileAttachment,
    this.onEmojiSelected,
    required this.channelId,
    this.placeholder = 'Type a message...',
    this.showFormatting = true,
    this.showAttachments = true,
    this.showEmoji = true,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  final List<File> _attachments = [];
  bool _showEmojiPicker = false;
  bool _showFormatToolbar = false;
  bool _isRecording = false;

  // Common emojis for quick access
  final List<String> _quickEmojis = ['👍', '👎', '😄', '😢', '😮', '😡', '❤️', '🎉'];

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Format toolbar
          if (_showFormatToolbar && widget.showFormatting) _buildFormatToolbar(),

          // Attachments preview
          if (_attachments.isNotEmpty) _buildAttachmentsPreview(),

          // Main input area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                if (widget.showAttachments) _buildAttachmentButton(),

                const SizedBox(width: 8),

                // Message input field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Format button
                        if (widget.showFormatting)
                          IconButton(
                            icon: Icon(
                              _showFormatToolbar ? Icons.format_clear : Icons.format_bold,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _showFormatToolbar = !_showFormatToolbar;
                              });
                            },
                          ),

                        // Text input
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            decoration: InputDecoration(
                              hintText: widget.placeholder,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            onChanged: _onMessageChanged,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),

                        // Emoji button
                        if (widget.showEmoji)
                          IconButton(
                            icon: Icon(
                              _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                              size: 20,
                            ),
                            onPressed: _toggleEmojiPicker,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send/Voice button
                _buildSendButton(),
              ],
            ),
          ),

          // Quick emoji bar
          if (widget.showEmoji && !_showEmojiPicker) _buildQuickEmojiBar(),

          // Emoji picker
          if (_showEmojiPicker) _buildEmojiPicker(),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.add_circle_outline),
      onSelected: _handleAttachmentOption,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Camera'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library),
              SizedBox(width: 8),
              Text('Photo Library'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'file',
          child: Row(
            children: [
              Icon(Icons.attach_file),
              SizedBox(width: 8),
              Text('File'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'voice',
          child: Row(
            children: [
              Icon(Icons.mic),
              SizedBox(width: 8),
              Text('Voice Message'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    final hasContent = _messageController.text.trim().isNotEmpty || _attachments.isNotEmpty;

    return IconButton(
      onPressed: hasContent ? _sendMessage : _startVoiceRecording,
      icon: Icon(
        hasContent ? Icons.send : Icons.mic,
        color: hasContent ? Theme.of(context).primaryColor : Colors.grey,
      ),
      style: IconButton.styleFrom(
        backgroundColor: hasContent ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
      ),
    );
  }

  Widget _buildFormatToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          _buildFormatButton(Icons.format_bold, '**', 'Bold'),
          _buildFormatButton(Icons.format_italic, '_', 'Italic'),
          _buildFormatButton(Icons.format_strikethrough, '~~', 'Strikethrough'),
          _buildFormatButton(Icons.code, '`', 'Code'),
          _buildFormatButton(Icons.format_quote, '>', 'Quote'),
          _buildFormatButton(Icons.format_list_bulleted, '- ', 'List'),
        ],
      ),
    );
  }

  Widget _buildFormatButton(IconData icon, String markdown, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () => _insertMarkdown(markdown),
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          final file = _attachments[index];
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildAttachmentPreview(file),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _removeAttachment(index),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(24, 24),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentPreview(File file) {
    final extension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.grey.shade600),
            Text(
              extension.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildQuickEmojiBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _quickEmojis
            .map(
              (emoji) => GestureDetector(
                onTap: () => _insertEmoji(emoji),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    // Simplified emoji picker - in a real app, use a proper emoji picker package
    final emojis = [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '😂',
      '🤣',
      '😊',
      '😇',
      '🙂',
      '🙃',
      '😉',
      '😌',
      '😍',
      '🥰',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😛',
      '😝',
      '😜',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😎',
      '🤩',
      '🥳',
      '😏',
      '👍',
      '👎',
      '👌',
      '🤞',
      '✌️',
      '🤟',
      '🤘',
      '👊',
      '✊',
      '🤛',
      '🤜',
      '👏',
      '🙌',
      '👐',
      '🤲',
      '🤝',
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _insertEmoji(emojis[index]),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                emojis[index],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onMessageChanged(String text) {
    // Handle typing indicators, slash commands, etc.
    setState(() {});
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });

    if (_showEmojiPicker) {
      _messageFocusNode.unfocus();
    } else {
      _messageFocusNode.requestFocus();
    }
  }

  void _insertMarkdown(String markdown) {
    final text = _messageController.text;
    final selection = _messageController.selection;

    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$markdown$selectedText$markdown',
      );

      _messageController.text = newText;
      _messageController.selection = TextSelection.collapsed(
        offset: selection.start + markdown.length + selectedText.length + markdown.length,
      );
    } else {
      final newText = text + markdown;
      _messageController.text = newText;
      _messageController.selection = TextSelection.collapsed(offset: newText.length);
    }
  }

  void _insertEmoji(String emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );

    _messageController.text = newText;
    _messageController.selection = TextSelection.collapsed(
      offset: selection.start + emoji.length,
    );

    widget.onEmojiSelected?.call(emoji);
  }

  Future<void> _handleAttachmentOption(String option) async {
    switch (option) {
      case 'camera':
        await _pickImageFromCamera();
        break;
      case 'gallery':
        await _pickImageFromGallery();
        break;
      case 'file':
        await _pickFile();
        break;
      case 'voice':
        await _startVoiceRecording();
        break;
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _attachments.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final List<XFile> images = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _attachments.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _attachments.addAll(
          result.files.map((file) => File(file.path!)),
        );
      });
    }
  }

  Future<void> _startVoiceRecording() async {
    // Voice recording implementation
    setState(() {
      _isRecording = true;
    });

    // TODO: Implement voice recording
    // This would typically use a package like flutter_sound

    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording not implemented yet')),
    );

    setState(() {
      _isRecording = false;
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isNotEmpty || _attachments.isNotEmpty) {
      widget.onSendMessage(message, _attachments.isNotEmpty ? _attachments : null);

      // Clear input
      _messageController.clear();
      setState(() {
        _attachments.clear();
        _showEmojiPicker = false;
        _showFormatToolbar = false;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }
}
