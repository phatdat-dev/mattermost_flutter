import 'dart:typed_data';

import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  final List<GalleryItem>? items;
  final int initialIndex;
  final String? channelName;

  const GalleryScreen({
    super.key,
    this.items,
    this.initialIndex = 0,
    this.channelName,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showControls = true;

  late List<GalleryItem> _items;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize with sample data if no items provided
    _items = widget.items ?? _generateSampleItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<GalleryItem> _generateSampleItems() {
    return [
      GalleryItem(
        id: '1',
        fileName: 'screenshot1.png',
        mimeType: 'image/png',
        fileUrl: 'https://via.placeholder.com/800x600/FF6B6B/FFFFFF?text=Image+1',
        fileSize: 1024 * 512, // 512 KB
        uploadDate: DateTime.now().subtract(const Duration(hours: 2)),
        uploaderName: 'John Doe',
      ),
      GalleryItem(
        id: '2',
        fileName: 'photo.jpg',
        mimeType: 'image/jpeg',
        fileUrl: 'https://via.placeholder.com/600x800/4ECDC4/FFFFFF?text=Image+2',
        fileSize: 1024 * 1024 * 2, // 2 MB
        uploadDate: DateTime.now().subtract(const Duration(hours: 5)),
        uploaderName: 'Jane Smith',
      ),
      GalleryItem(
        id: '3',
        fileName: 'diagram.png',
        mimeType: 'image/png',
        fileUrl: 'https://via.placeholder.com/900x600/45B7D1/FFFFFF?text=Image+3',
        fileSize: 1024 * 800, // 800 KB
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        uploaderName: 'Bob Wilson',
      ),
      GalleryItem(
        id: '4',
        fileName: 'presentation.png',
        mimeType: 'image/png',
        fileUrl: 'https://via.placeholder.com/1200x800/96CEB4/FFFFFF?text=Image+4',
        fileSize: 1024 * 1024 * 3, // 3 MB
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        uploaderName: 'Alice Brown',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Image viewer
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildImagePage(_items[index]);
              },
            ),

            // Top controls
            if (_showControls) _buildTopControls(),

            // Bottom controls
            if (_showControls) _buildBottomControls(),

            // Page indicator
            if (_showControls && _items.length > 1) _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePage(GalleryItem item) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: item.fileUrl != null
            ? Image.network(
                item.fileUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading ${item.fileName}...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget(item);
                },
              )
            : item.fileData != null
            ? Image.memory(
                item.fileData!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget(item);
                },
              )
            : _buildPlaceholder(item),
      ),
    );
  }

  Widget _buildErrorWidget(GalleryItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 80,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.fileName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(GalleryItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.fileName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _items[_currentIndex].fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.channelName != null)
                  Text(
                    'from ${widget.channelName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _shareCurrentImage,
                icon: const Icon(Icons.share, color: Colors.white),
              ),
              IconButton(
                onPressed: _downloadCurrentImage,
                icon: const Icon(Icons.download, color: Colors.white),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: _onMenuSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'info',
                    child: Text('File Info'),
                  ),
                  const PopupMenuItem(
                    value: 'copy_link',
                    child: Text('Copy Link'),
                  ),
                  const PopupMenuItem(
                    value: 'open_external',
                    child: Text('Open in External App'),
                  ),
                  const PopupMenuItem(
                    value: 'save_to_gallery',
                    child: Text('Save to Gallery'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final currentItem = _items[_currentIndex];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentItem.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Uploaded by ${currentItem.uploaderName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatFileSize(currentItem.fileSize),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(currentItem.uploadDate),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_currentIndex + 1} of ${_items.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _shareCurrentImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_items[_currentIndex].fileName}...'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _downloadCurrentImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${_items[_currentIndex].fileName}...'),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _onMenuSelected(String value) {
    final currentItem = _items[_currentIndex];

    switch (value) {
      case 'info':
        _showFileInfo(currentItem);
        break;
      case 'copy_link':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
            backgroundColor: Colors.grey,
          ),
        );
        break;
      case 'open_external':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening in external app...'),
            backgroundColor: Colors.grey,
          ),
        );
        break;
      case 'save_to_gallery':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saving ${currentItem.fileName} to gallery...'),
            backgroundColor: Colors.grey,
          ),
        );
        break;
    }
  }

  void _showFileInfo(GalleryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', item.fileName),
            _buildInfoRow('Type', item.mimeType),
            _buildInfoRow('Size', _formatFileSize(item.fileSize)),
            _buildInfoRow('Uploaded by', item.uploaderName),
            _buildInfoRow('Upload date', _formatDate(item.uploadDate)),
            if (item.fileUrl != null) _buildInfoRow('URL', item.fileUrl!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class GalleryItem {
  final String id;
  final String fileName;
  final String mimeType;
  final String? fileUrl;
  final Uint8List? fileData;
  final int? fileSize;
  final DateTime? uploadDate;
  final String uploaderName;

  GalleryItem({
    required this.id,
    required this.fileName,
    required this.mimeType,
    this.fileUrl,
    this.fileData,
    this.fileSize,
    this.uploadDate,
    required this.uploaderName,
  });
}
