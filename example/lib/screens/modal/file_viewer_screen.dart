import 'dart:typed_data';

import 'package:flutter/material.dart';

class FileViewerScreen extends StatefulWidget {
  final String? fileName;
  final String? fileUrl;
  final String? mimeType;
  final int? fileSize;
  final Uint8List? fileData;

  const FileViewerScreen({
    super.key,
    this.fileName,
    this.fileUrl,
    this.mimeType,
    this.fileSize,
    this.fileData,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;
  double _scale = 1.0;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.fileName ?? 'File Viewer',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _shareFile,
            icon: const Icon(Icons.share, color: Colors.white),
          ),
          IconButton(
            onPressed: _downloadFile,
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
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _buildFileContent(),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildFileContent() {
    final mimeType = widget.mimeType ?? '';

    if (mimeType.startsWith('image/')) {
      return _buildImageViewer();
    } else if (mimeType.startsWith('video/')) {
      return _buildVideoViewer();
    } else if (mimeType == 'application/pdf') {
      return _buildPdfViewer();
    } else if (mimeType.startsWith('text/') || mimeType == 'application/json') {
      return _buildTextViewer();
    } else {
      return _buildUnsupportedFileViewer();
    }
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 5.0,
      onInteractionUpdate: (details) {
        setState(() {
          _scale = _transformationController.value.getMaxScaleOnAxis();
        });
      },
      child: Center(
        child: widget.fileData != null
            ? Image.memory(
                widget.fileData!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget('Failed to load image');
                },
              )
            : widget.fileUrl != null
            ? Image.network(
                widget.fileUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget('Failed to load image');
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildVideoViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 100,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            widget.fileName ?? 'Video File',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatFileSize(widget.fileSize),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _playVideo,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 100,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            widget.fileName ?? 'PDF Document',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatFileSize(widget.fileSize),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openInExternalApp,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in PDF Viewer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextViewer() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Text(
          _getSampleTextContent(),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildUnsupportedFileViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 100,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            widget.fileName ?? 'Unknown File',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.mimeType ?? 'Unknown type',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatFileSize(widget.fileSize),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preview not available for this file type',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openInExternalApp,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in External App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
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
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final mimeType = widget.mimeType ?? '';

    if (mimeType.startsWith('image/')) {
      return Container(
        color: Colors.black.withValues(alpha: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _resetZoom,
              icon: const Icon(Icons.zoom_out_map, color: Colors.white),
              tooltip: 'Reset Zoom',
            ),
            IconButton(
              onPressed: _zoomIn,
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              tooltip: 'Zoom In',
            ),
            IconButton(
              onPressed: _zoomOut,
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              tooltip: 'Zoom Out',
            ),
            Text(
              '${(_scale * 100).round()}%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _shareFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing file...')),
    );
  }

  void _downloadFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading file...')),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'info':
        _showFileInfo();
        break;
      case 'copy_link':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
        break;
      case 'open_external':
        _openInExternalApp();
        break;
    }
  }

  void _showFileInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', widget.fileName ?? 'Unknown'),
            _buildInfoRow('Type', widget.mimeType ?? 'Unknown'),
            _buildInfoRow('Size', _formatFileSize(widget.fileSize)),
            if (widget.fileUrl != null) _buildInfoRow('URL', widget.fileUrl!),
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
            width: 60,
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

  void _playVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening video player...')),
    );
  }

  void _openInExternalApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening in external app...')),
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _scale = 1.0;
    });
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.5, 5.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
    setState(() {
      _scale = newScale;
    });
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.5, 5.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
    setState(() {
      _scale = newScale;
    });
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _getSampleTextContent() {
    return '''This is a sample text file content.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.''';
  }
}
