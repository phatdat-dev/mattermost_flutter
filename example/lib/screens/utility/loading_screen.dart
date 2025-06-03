import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final String? message;
  final String? subtitle;
  final bool showLogo;
  final Duration? minimumDuration;

  const LoadingScreen({
    super.key,
    this.message,
    this.subtitle,
    this.showLogo = true,
    this.minimumDuration,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
          ),
        );

    _controller.forward();

    // Auto-dismiss after minimum duration if specified
    if (widget.minimumDuration != null) {
      Future.delayed(widget.minimumDuration!, () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or icon
                  if (widget.showLogo) ...[
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.chat,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading message
                  if (widget.message != null) ...[
                    Text(
                      widget.message!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Subtitle
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Specialized loading screens for common scenarios

class SplashLoadingScreen extends StatelessWidget {
  final String appName;
  final String? version;

  const SplashLoadingScreen({
    super.key,
    this.appName = 'Mattermost',
    this.version,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(
      message: appName,
      subtitle: version != null ? 'Version $version' : null,
      showLogo: true,
      minimumDuration: const Duration(seconds: 2),
    );
  }
}

class ConnectingLoadingScreen extends StatelessWidget {
  final String? serverUrl;

  const ConnectingLoadingScreen({
    super.key,
    this.serverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(
      message: 'Connecting to server...',
      subtitle: serverUrl != null ? 'Server: $serverUrl' : null,
      showLogo: false,
    );
  }
}

class AuthenticatingLoadingScreen extends StatelessWidget {
  final String? username;

  const AuthenticatingLoadingScreen({
    super.key,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(
      message: 'Authenticating...',
      subtitle: username != null ? 'User: $username' : null,
      showLogo: false,
    );
  }
}

class SyncingLoadingScreen extends StatelessWidget {
  final String? operation;

  const SyncingLoadingScreen({
    super.key,
    this.operation,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(
      message: 'Syncing data...',
      subtitle: operation,
      showLogo: false,
    );
  }
}

// Loading overlay that can be shown on top of other content
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Loading button widget
class LoadingButton extends StatelessWidget {
  final String text;
  final String? loadingText;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;

  const LoadingButton({
    super.key,
    required this.text,
    this.loadingText,
    required this.isLoading,
    this.onPressed,
    this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: style,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : icon!,
        label: Text(isLoading ? (loadingText ?? text) : text),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(loadingText ?? text),
              ],
            )
          : Text(text),
    );
  }
}
