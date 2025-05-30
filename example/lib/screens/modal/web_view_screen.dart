import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;
  final bool showNavigation;
  final Map<String, String>? headers;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
    this.showNavigation = true,
    this.headers,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _simulateWebViewLoading();
  }

  void _simulateWebViewLoading() {
    // Simulate web page loading
    _loadingProgress = 0.0;
    final timer = Stream.periodic(const Duration(milliseconds: 100), (i) => i * 10.0).take(10).listen((progress) {
      setState(() {
        _loadingProgress = progress;
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      timer.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProgress = 100.0;
        });
      }
    });
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _simulateWebViewLoading();
  }

  void _goBack() {
    // Simulate navigation
    setState(() {
      _canGoBack = false;
      _canGoForward = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Going back...')),
    );
  }

  void _goForward() {
    // Simulate navigation
    setState(() {
      _canGoBack = true;
      _canGoForward = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Going forward...')),
    );
  }

  void _shareUrl() {
    Clipboard.setData(ClipboardData(text: _currentUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
  }

  void _openInBrowser() {
    // TODO: Implement opening in external browser
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $_currentUrl in browser...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Web View'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
          IconButton(
            onPressed: _shareUrl,
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'open_browser':
                  _openInBrowser();
                  break;
                case 'copy_url':
                  _shareUrl();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open_browser',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser),
                    SizedBox(width: 8),
                    Text('Open in Browser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_url',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy URL'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // URL bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentUrl,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),

          // Web content area
          Expanded(
            child: _buildWebContent(),
          ),

          // Navigation bar
          if (widget.showNavigation) _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load webpage',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _reload,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading webpage...'),
          ],
        ),
      );
    }

    // Simulated web content
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Web Content Simulation',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'URL: $_currentUrl',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This is a simulated web view. In a real implementation, this would display the actual web content using a WebView widget from packages like webview_flutter.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Features that would be available in a real WebView:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• JavaScript execution'),
          const Text('• Cookie management'),
          const Text('• File downloads'),
          const Text('• Form submission'),
          const Text('• Navigation history'),
          const Text('• Zoom controls'),
          const Text('• Custom headers'),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _canGoBack ? _goBack : null,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: _canGoBack ? Theme.of(context).colorScheme.onSurface : Theme.of(context).disabledColor,
                ),
                tooltip: 'Back',
              ),
              IconButton(
                onPressed: _canGoForward ? _goForward : null,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: _canGoForward ? Theme.of(context).colorScheme.onSurface : Theme.of(context).disabledColor,
                ),
                tooltip: 'Forward',
              ),
              IconButton(
                onPressed: _reload,
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: 'Reload',
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
