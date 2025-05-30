import 'package:flutter/material.dart';

class ChannelFilesScreen extends StatefulWidget {
  final Map<String, dynamic>? channel;

  const ChannelFilesScreen({super.key, this.channel});

  @override
  State<ChannelFilesScreen> createState() => _ChannelFilesScreenState();
}

class _ChannelFilesScreenState extends State<ChannelFilesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _files = [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Load files from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _files = [
        {
          'id': '1',
          'name': 'project_proposal.pdf',
          'type': 'pdf',
          'size': 2450000,
          'created_at': DateTime.now().subtract(const Duration(days: 2)),
          'user': {'username': 'john.doe', 'first_name': 'John', 'last_name': 'Doe'},
        },
        {
          'id': '2',
          'name': 'screenshot.png',
          'type': 'image',
          'size': 850000,
          'created_at': DateTime.now().subtract(const Duration(hours: 5)),
          'user': {'username': 'jane.smith', 'first_name': 'Jane', 'last_name': 'Smith'},
        },
        {
          'id': '3',
          'name': 'meeting_notes.docx',
          'type': 'document',
          'size': 156000,
          'created_at': DateTime.now().subtract(const Duration(days: 1)),
          'user': {'username': 'bob.wilson', 'first_name': 'Bob', 'last_name': 'Wilson'},
        },
        {
          'id': '4',
          'name': 'demo_video.mp4',
          'type': 'video',
          'size': 15600000,
          'created_at': DateTime.now().subtract(const Duration(hours: 12)),
          'user': {'username': 'alice.brown', 'first_name': 'Alice', 'last_name': 'Brown'},
        },
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading files: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredFiles {
    if (_selectedFilter == 'all') return _files;
    return _files.where((file) => file['type'] == _selectedFilter).toList();
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  void _openFile(Map<String, dynamic> file) {
    Navigator.pushNamed(
      context,
      '/file-viewer',
      arguments: file,
    );
  }

  void _downloadFile(Map<String, dynamic> file) {
    // TODO: Implement file download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${file['name']}...')),
    );
  }

  void _shareFile(Map<String, dynamic> file) {
    // TODO: Implement file sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${file['name']}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Files • ${widget.channel?['display_name'] ?? 'Channel'}'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement file search
              showSearch(
                context: context,
                delegate: FileSearchDelegate(_files),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // File type filters
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Images',
                  isSelected: _selectedFilter == 'image',
                  onTap: () => setState(() => _selectedFilter = 'image'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Videos',
                  isSelected: _selectedFilter == 'video',
                  onTap: () => setState(() => _selectedFilter = 'video'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Documents',
                  isSelected: _selectedFilter == 'document',
                  onTap: () => setState(() => _selectedFilter = 'document'),
                ),
              ],
            ),
          ),

          // Files list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all' ? 'No files shared yet' : 'No ${_selectedFilter}s found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Files shared in this channel will appear here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = _filteredFiles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              _getFileIcon(file['type']),
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            file['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shared by ${file['user']['first_name']} ${file['user']['last_name']}'.trim().isEmpty
                                    ? '@${file['user']['username']}'
                                    : '${file['user']['first_name']} ${file['user']['last_name']}',
                              ),
                              Text(
                                '${_formatFileSize(file['size'])} • ${_formatDate(file['created_at'])}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              switch (action) {
                                case 'open':
                                  _openFile(file);
                                  break;
                                case 'download':
                                  _downloadFile(file);
                                  break;
                                case 'share':
                                  _shareFile(file);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'open',
                                child: ListTile(
                                  leading: Icon(Icons.open_in_new),
                                  title: Text('Open'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'download',
                                child: ListTile(
                                  leading: Icon(Icons.download),
                                  title: Text('Download'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: ListTile(
                                  leading: Icon(Icons.share),
                                  title: Text('Share'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _openFile(file),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}

class FileSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> files;

  FileSearchDelegate(this.files);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = files.where((file) => file['name'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final file = results[index];
        return ListTile(
          leading: Icon(_getFileIcon(file['type'])),
          title: Text(file['name']),
          subtitle: Text('${_formatFileSize(file['size'])} • ${_formatDate(file['created_at'])}'),
          onTap: () => close(context, file),
        );
      },
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
