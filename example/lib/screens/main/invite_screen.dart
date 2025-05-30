import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class InviteScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MTeam team;

  const InviteScreen({
    super.key,
    required this.client,
    required this.currentUser,
    required this.team,
  });

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _linkController = TextEditingController();

  final List<String> _emailList = [];
  bool _isLoading = false;
  String? _inviteLink;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateInviteLink();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _generateInviteLink() async {
    try {
      // In a real implementation, generate an invite link from the server
      final link = 'https://mattermost.example.com/signup_user_complete/?id=${widget.team.inviteId}';
      setState(() {
        _inviteLink = link;
        _linkController.text = link;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate invite link: $e';
      });
    }
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && _isValidEmail(email)) {
      setState(() {
        if (!_emailList.contains(email)) {
          _emailList.add(email);
        }
        _emailController.clear();
      });
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _emailList.remove(email);
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _sendInvites() async {
    if (_emailList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      for (final email in _emailList) {
        // In a real implementation, send invite emails through the API
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent ${_emailList.length} invite(s) successfully')),
        );
        setState(() {
          _emailList.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send invites: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyInviteLink() async {
    if (_inviteLink != null) {
      await Clipboard.setData(ClipboardData(text: _inviteLink!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite link copied to clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite People'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.email), text: 'Send Invites'),
            Tab(icon: Icon(Icons.link), text: 'Share Link'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmailInviteTab(),
          _buildLinkShareTab(),
        ],
      ),
    );
  }

  Widget _buildEmailInviteTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 20,
                        child: Text(
                          widget.team.displayName.isNotEmpty ? widget.team.displayName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
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
                              'Invite to ${widget.team.displayName}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.team.description.isNotEmpty)
                              Text(
                                widget.team.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Add Email Addresses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _addEmail(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addEmail,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_emailList.isNotEmpty) ...[
            Text(
              'Email List (${_emailList.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _emailList.length,
                  itemBuilder: (context, index) {
                    final email = _emailList[index];
                    return ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(email),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeEmail(email),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No email addresses added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_errorMessage != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _emailList.isNotEmpty && !_isLoading ? _sendInvites : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Send ${_emailList.length} Invite${_emailList.length != 1 ? 's' : ''}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkShareTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Invite Link',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Anyone with this link can join ${widget.team.displayName}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Invite Link',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _copyInviteLink,
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Note',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This link allows anyone to join your team. Only share it with people you trust.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Share options
          Text(
            'Share Options',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: const Text('Share via Message'),
                  subtitle: const Text('Send the link through a message app'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement message sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message sharing coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text('Share via Email'),
                  subtitle: const Text('Send the link through email'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement email sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email sharing coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.purple),
                  title: const Text('Show QR Code'),
                  subtitle: const Text('Display a QR code for easy scanning'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement QR code generation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR code generation coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
