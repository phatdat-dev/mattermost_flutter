import 'package:flutter/material.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _headerController = TextEditingController();

  bool _isPrivate = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _purposeController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _createChannel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real implementation, create the channel via API
      await Future.delayed(const Duration(seconds: 2));

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Channel "${_displayNameController.text}" created successfully')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create channel: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _generateChannelName(String displayName) {
    // Auto-generate channel name from display name
    final name = displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\-_]'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');

    _nameController.text = name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Channel'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createChannel,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Channel type selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Channel Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Public'),
                            subtitle: const Text('Anyone can join'),
                            value: false,
                            groupValue: _isPrivate,
                            onChanged: (value) {
                              setState(() {
                                _isPrivate = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Private'),
                            subtitle: const Text('Invite only'),
                            value: true,
                            groupValue: _isPrivate,
                            onChanged: (value) {
                              setState(() {
                                _isPrivate = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Display name
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name *',
                hintText: 'Enter channel display name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                if (value.length < 2) {
                  return 'Display name must be at least 2 characters';
                }
                return null;
              },
              onChanged: _generateChannelName,
            ),

            const SizedBox(height: 16),

            // Channel name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Channel Name *',
                hintText: 'channel-name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                helperText: 'Lowercase letters, numbers, hyphens, and underscores only',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a channel name';
                }
                if (!RegExp(r'^[a-z0-9\-_]+$').hasMatch(value)) {
                  return 'Invalid characters in channel name';
                }
                if (value.length < 2) {
                  return 'Channel name must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Purpose
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose (Optional)',
                hintText: 'Describe what this channel is for',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
              maxLines: 2,
              maxLength: 250,
            ),

            const SizedBox(height: 16),

            // Header
            TextFormField(
              controller: _headerController,
              decoration: const InputDecoration(
                labelText: 'Header (Optional)',
                hintText: 'Add additional information about this channel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              maxLines: 2,
              maxLength: 1024,
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createChannel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Create Channel'),
              ),
            ),

            const SizedBox(height: 16),

            // Help text
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Public channels are discoverable and joinable by anyone\n'
                      '• Private channels require an invitation to join\n'
                      '• Choose a descriptive name and purpose to help others understand the channel\'s focus',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
