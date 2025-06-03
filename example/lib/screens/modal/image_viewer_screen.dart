import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final List<String>? imageUrls;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.title,
    this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isFullScreen = false;
  bool _showAppBar = true;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _showAppBar = !_showAppBar;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _shareImage() {
    final currentUrl = widget.imageUrls?[_currentIndex] ?? widget.imageUrl;
    // TODO: Implement image sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: $currentUrl')),
    );
  }

  void _downloadImage() {
    final currentUrl = widget.imageUrls?[_currentIndex] ?? widget.imageUrl;
    // TODO: Implement image download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading: $currentUrl')),
    );
  }

  String _getCurrentImageUrl() {
    return widget.imageUrls?[_currentIndex] ?? widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              title: Text(
                widget.title ?? 'Image ${_currentIndex + 1}${widget.imageUrls != null ? ' of ${widget.imageUrls!.length}' : ''}',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareImage,
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadImage,
                  tooltip: 'Download',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'fullscreen':
                        _toggleFullScreen();
                        break;
                      case 'zoom_reset':
                        _transformationController.value = Matrix4.identity();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'fullscreen',
                      child: Text(_isFullScreen ? 'Exit Full Screen' : 'Full Screen'),
                    ),
                    const PopupMenuItem(
                      value: 'zoom_reset',
                      child: Text('Reset Zoom'),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () {
          if (_isFullScreen) {
            _toggleFullScreen();
          }
        },
        child: widget.imageUrls != null && widget.imageUrls!.length > 1 ? _buildImageGallery() : _buildSingleImage(),
      ),
      bottomNavigationBar: _showAppBar && widget.imageUrls != null && widget.imageUrls!.length > 1
          ? Container(
              color: Colors.black.withValues(alpha: 0.7),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  Text(
                    '${_currentIndex + 1} of ${widget.imageUrls!.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    onPressed: _currentIndex < widget.imageUrls!.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildSingleImage() {
    return Center(
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 5.0,
        child: Image.network(
          _getCurrentImageUrl(),
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: widget.imageUrls!.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          transformationController: index == _currentIndex ? _transformationController : null,
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(
            widget.imageUrls![index],
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
