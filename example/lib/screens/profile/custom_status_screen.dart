import 'package:flutter/material.dart';

class CustomStatusScreen extends StatefulWidget {
  const CustomStatusScreen({super.key});

  @override
  State<CustomStatusScreen> createState() => _CustomStatusScreenState();
}

class _CustomStatusScreenState extends State<CustomStatusScreen> {
  final _textController = TextEditingController();
  String _selectedEmoji = '';
  DateTime? _expiresAt;
  bool _isLoading = false;

  final List<String> _popularEmojis = [
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
    '😏',
    '😒',
    '😞',
    '🏠',
    '🏢',
    '🏥',
    '🏫',
    '🏪',
    '🏬',
    '🏭',
    '🏯',
    '💻',
    '📱',
    '⌚',
    '📺',
    '📻',
    '🎵',
    '🎶',
    '🎤',
    '☕',
    '🍕',
    '🍔',
    '🍟',
    '🌮',
    '🥗',
    '🍜',
    '🍱',
    '✈️',
    '🚗',
    '🚕',
    '🚌',
    '🚎',
    '🚇',
    '🚆',
    '🚄',
  ];

  final List<Map<String, dynamic>> _quickPresets = [
    {'emoji': '🏠', 'text': 'Working from home', 'duration': const Duration(hours: 8)},
    {'emoji': '🍕', 'text': 'Out for lunch', 'duration': const Duration(hours: 1)},
    {'emoji': '😴', 'text': 'Sleeping', 'duration': const Duration(hours: 8)},
    {'emoji': '🏖️', 'text': 'On vacation', 'duration': const Duration(days: 7)},
    {'emoji': '🤒', 'text': 'Sick', 'duration': const Duration(days: 1)},
    {'emoji': '🔄', 'text': 'In a meeting', 'duration': const Duration(hours: 2)},
    {'emoji': '🎯', 'text': 'Focusing', 'duration': const Duration(hours: 4)},
    {'emoji': '☕', 'text': 'On a coffee break', 'duration': const Duration(minutes: 30)},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadCurrentStatus() {
    // TODO: Load current custom status from API
    // Mock current status
    _selectedEmoji = '💻';
    _textController.text = 'Working on a cool project';
    _expiresAt = DateTime.now().add(const Duration(hours: 2));
  }

  void _saveStatus() async {
    if (_selectedEmoji.isEmpty && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an emoji or text')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Save custom status via API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated')),
        );
        Navigator.pop(context, {
          'emoji': _selectedEmoji,
          'text': _textController.text.trim(),
          'expires_at': _expiresAt,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearStatus() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Clear custom status via API
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status cleared')),
        );
        Navigator.pop(context, null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectEmoji(String emoji) {
    setState(() => _selectedEmoji = emoji);
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _selectedEmoji = preset['emoji'];
      _textController.text = preset['text'];
      _expiresAt = DateTime.now().add(preset['duration']);
    });
  }

  void _selectExpiration() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('30 minutes'),
              onTap: () {
                setState(() => _expiresAt = DateTime.now().add(const Duration(minutes: 30)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('1 hour'),
              onTap: () {
                setState(() => _expiresAt = DateTime.now().add(const Duration(hours: 1)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('4 hours'),
              onTap: () {
                setState(() => _expiresAt = DateTime.now().add(const Duration(hours: 4)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Today'),
              onTap: () {
                final now = DateTime.now();
                setState(() => _expiresAt = DateTime(now.year, now.month, now.day, 23, 59));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('This week'),
              onTap: () {
                final now = DateTime.now();
                final daysUntilSunday = 7 - now.weekday;
                setState(() => _expiresAt = now.add(Duration(days: daysUntilSunday)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Custom'),
              onTap: () async {
                Navigator.pop(context);
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null && mounted) {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_expiresAt ?? DateTime.now().add(const Duration(hours: 1))),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _expiresAt = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Don\'t clear'),
              onTap: () {
                setState(() => _expiresAt = null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiration(DateTime? expiresAt) {
    if (expiresAt == null) return 'Don\'t clear';

    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) {
      return 'Expires in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'Expires in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'Expires in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Custom Status'),
        actions: [
          if (_selectedEmoji.isNotEmpty || _textController.text.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _clearStatus,
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: _isLoading ? null : _saveStatus,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji.isEmpty ? '😀' : _selectedEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _textController.text.isEmpty ? 'Status message' : _textController.text,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _textController.text.isEmpty ? Colors.grey[500] : null,
                          ),
                        ),
                        if (_expiresAt != null)
                          Text(
                            _formatExpiration(_expiresAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'What\'s your status?',
                      border: const OutlineInputBorder(),
                      prefixIcon: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          _selectedEmoji.isEmpty ? '😀' : _selectedEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    maxLength: 100,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Expiration
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Clear after'),
              subtitle: Text(_formatExpiration(_expiresAt)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectExpiration,
            ),
          ),

          const SizedBox(height: 16),

          // Quick presets
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Presets',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ..._quickPresets.map(
                    (preset) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        preset['emoji'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(preset['text']),
                      subtitle: Text(_formatExpiration(DateTime.now().add(preset['duration']))),
                      onTap: () => _applyPreset(preset),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Emoji picker
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Emoji',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _popularEmojis.length,
                    itemBuilder: (context, index) {
                      final emoji = _popularEmojis[index];
                      final isSelected = _selectedEmoji == emoji;

                      return InkWell(
                        onTap: () => _selectEmoji(emoji),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary) : null,
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Open full emoji picker
                        Navigator.pushNamed(context, '/emoji-picker');
                      },
                      icon: const Icon(Icons.sentiment_satisfied),
                      label: const Text('More Emojis'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
