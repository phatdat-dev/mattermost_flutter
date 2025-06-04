import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final Function(String) onInsert;

  const MarkdownToolbar({
    super.key,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            onPressed: () => onInsert('**bold**'),
          ),
          _buildToolbarButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            onPressed: () => onInsert('*italic*'),
          ),
          _buildToolbarButton(
            icon: Icons.format_strikethrough,
            tooltip: 'Strikethrough',
            onPressed: () => onInsert('~~strikethrough~~'),
          ),
          _buildToolbarButton(
            icon: Icons.code,
            tooltip: 'Inline Code',
            onPressed: () => onInsert('`code`'),
          ),
          _buildToolbarButton(
            icon: Icons.code_off,
            tooltip: 'Code Block',
            onPressed: () => onInsert('```\ncode block\n```'),
          ),
          _buildToolbarButton(
            icon: Icons.format_quote,
            tooltip: 'Quote',
            onPressed: () => onInsert('> quote'),
          ),
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bullet List',
            onPressed: () => onInsert('- item'),
          ),
          _buildToolbarButton(
            icon: Icons.format_list_numbered,
            tooltip: 'Numbered List',
            onPressed: () => onInsert('1. item'),
          ),
          _buildToolbarButton(
            icon: Icons.link,
            tooltip: 'Link',
            onPressed: () => onInsert('[link text](url)'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }
}
