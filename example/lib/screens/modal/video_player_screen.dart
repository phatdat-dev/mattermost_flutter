import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool autoPlay;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.title,
    this.autoPlay = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isPlaying = false;
  bool _isLoading = true;
  final bool _hasError = false;
  bool _showControls = true;
  double _currentPosition = 0.0;
  final double _totalDuration = 100.0; // Mock duration
  double _volume = 1.0;
  bool _isFullScreen = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Simulate video loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (widget.autoPlay) {
            _isPlaying = true;
          }
        });

        // Start position update timer if playing
        if (_isPlaying) {
          _startPositionTimer();
        }
      }
    });
  }

  void _startPositionTimer() {
    // Simulate video position updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentPosition += 1.0;
        if (_currentPosition >= _totalDuration) {
          _currentPosition = _totalDuration;
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startPositionTimer();
    }
  }

  void _seekTo(double position) {
    setState(() {
      _currentPosition = position;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: !_isFullScreen && _showControls
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              title: Text(widget.title ?? 'Video Player'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement video sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing: ${widget.videoUrl}')),
                    );
                  },
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Implement video download
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading: ${widget.videoUrl}')),
                    );
                  },
                  tooltip: 'Download',
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video area
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: _isFullScreen ? null : BorderRadius.circular(8),
                  ),
                  child: _buildVideoContent(),
                ),
              ),
            ),

            // Video controls overlay
            if (_showControls) _buildControlsOverlay(),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
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
              'Failed to load video',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage('https://via.placeholder.com/640x360/333/fff?text=Video+Placeholder'),
          fit: BoxFit.cover,
        ),
        borderRadius: _isFullScreen ? null : BorderRadius.circular(8),
      ),
      child: Center(
        child: _isPlaying
            ? Container()
            : const Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white70,
              ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Top controls
            if (!_isFullScreen)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          widget.title ?? 'Video Player',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleFullScreen,
                        icon: Icon(
                          _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Center play button
            Center(
              child: IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),

            const Spacer(),

            // Bottom controls
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress bar
                  Row(
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentPosition,
                          max: _totalDuration,
                          onChanged: _seekTo,
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Colors.white30,
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),

                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          _seekTo((_currentPosition - 10).clamp(0, _totalDuration));
                        },
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _seekTo((_currentPosition + 10).clamp(0, _totalDuration));
                        },
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                      ),
                      // Volume control
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _volume = _volume > 0 ? 0.0 : 1.0;
                          });
                        },
                        icon: Icon(
                          _volume > 0 ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                      ),
                      if (_isFullScreen)
                        IconButton(
                          onPressed: _toggleFullScreen,
                          icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                        )
                      else
                        IconButton(
                          onPressed: _toggleFullScreen,
                          icon: const Icon(Icons.fullscreen, color: Colors.white),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
