import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

class TeamSettingsScreen extends StatefulWidget {
  final MattermostClient client;
  final MUser currentUser;
  final MTeam team;

  const TeamSettingsScreen({
    super.key,
    required this.client,
    required this.currentUser,
    required this.team,
  });

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isAdmin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkPermissions();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _displayNameController.text = widget.team.displayName;
    _descriptionController.text = widget.team.description;
  }

  Future<void> _checkPermissions() async {
    try {
      // Check if user has team admin permissions
      final teamMember = await widget.client.teams.getTeamMember(
        widget.team.id,
        widget.currentUser.id,
      );

      setState(() {
        _isAdmin = teamMember.roles.contains('team_admin');
      });
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<void> _updateTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.client.teams.updateTeam(
        widget.team.id,
        displayName: _displayNameController.text.trim(),
        description: _descriptionController.text.trim(),
        companyName: widget.team.companyName,
        allowedDomains: widget.team.allowedDomains,
        allowOpenInvite: widget.team.allowOpenInvite,
        inviteId: widget.team.inviteId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team updated successfully')),
        );
        Navigator.of(context).pop(
          widget.team,
          // displayName: _displayNameController.text.trim(),
          // description: _descriptionController.text.trim(),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update team: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text(
          'Are you sure you want to delete "${widget.team.displayName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _deleteTeam();
    }
  }

  Future<void> _deleteTeam() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.client.teams.deleteTeam(widget.team.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team deleted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete team: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (_isAdmin)
            IconButton(
              onPressed: _isLoading ? null : _updateTeam,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : const Icon(Icons.check),
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Team Icon
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 50,
                    child: Text(
                      widget.team.displayName.isNotEmpty ? widget.team.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isAdmin)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 16,
                        child: IconButton(
                          onPressed: () {
                            // TODO: Implement team icon change
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Icon change coming soon')),
                            );
                          },
                          icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Team Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      enabled: _isAdmin,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a team name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      enabled: _isAdmin,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          widget.team.type == 'O' ? Icons.public : Icons.lock,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Type: ${widget.team.type == 'O' ? 'Open Team' : 'Private Team'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Team Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Created: ${_formatDate(widget.team.createAt)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.update,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Updated: ${_formatDate(widget.team.updateAt)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
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
            ],

            // Admin Actions
            if (_isAdmin) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.people, color: Colors.blue),
                        title: const Text('Manage Members'),
                        subtitle: const Text('Add, remove, or change member roles'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to team members screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Member management coming soon')),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        title: Text(
                          'Delete Team',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                        subtitle: const Text('Permanently delete this team'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _showDeleteConfirmation,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}
