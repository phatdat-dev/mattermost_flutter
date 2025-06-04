import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String? title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final ErrorType type;
  final Widget? customAction;

  const ErrorScreen({
    super.key,
    this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onClose,
    this.type = ErrorType.general,
    this.customAction,
  });

  // Factory constructors for common error types
  const ErrorScreen.network({
    super.key,
    this.title = 'Connection Error',
    this.message = 'Unable to connect to the server. Please check your internet connection and try again.',
    this.details,
    this.onRetry,
    this.onClose,
    this.customAction,
  }) : type = ErrorType.network;

  const ErrorScreen.server({
    super.key,
    this.title = 'Server Error',
    this.message = 'The server encountered an error. Please try again later.',
    this.details,
    this.onRetry,
    this.onClose,
    this.customAction,
  }) : type = ErrorType.server;

  const ErrorScreen.authentication({
    super.key,
    this.title = 'Authentication Error',
    this.message = 'Your session has expired. Please log in again.',
    this.details,
    this.onRetry,
    this.onClose,
    this.customAction,
  }) : type = ErrorType.authentication;

  const ErrorScreen.notFound({
    super.key,
    this.title = 'Not Found',
    this.message = 'The requested content could not be found.',
    this.details,
    this.onRetry,
    this.onClose,
    this.customAction,
  }) : type = ErrorType.notFound;

  const ErrorScreen.permission({
    super.key,
    this.title = 'Access Denied',
    this.message = 'You do not have permission to access this content.',
    this.details,
    this.onRetry,
    this.onClose,
    this.customAction,
  }) : type = ErrorType.permission;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: onClose != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error icon
              _buildErrorIcon(context),
              const SizedBox(height: 32),

              // Title
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getErrorColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              // Details
              if (details != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Error Details'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        details!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    IconData iconData;
    Color iconColor = _getErrorColor(context);

    switch (type) {
      case ErrorType.network:
        iconData = Icons.wifi_off;
        break;
      case ErrorType.server:
        iconData = Icons.dns;
        break;
      case ErrorType.authentication:
        iconData = Icons.lock_outline;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off;
        break;
      case ErrorType.permission:
        iconData = Icons.block;
        break;
      case ErrorType.general:
        iconData = Icons.error;
      // default:
      //   iconData = Icons.error_outline;
      //   break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 64,
        color: iconColor,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom action if provided
        if (customAction != null) ...[
          customAction!,
          const SizedBox(height: 12),
        ],

        // Retry button
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

        // Close/Back button
        if (onClose != null) ...[
          if (onRetry != null) const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],

        // Default navigation if no custom actions
        if (onRetry == null && onClose == null && Navigator.canPop(context))
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
      ],
    );
  }

  Color _getErrorColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.amber;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.permission:
        return Colors.purple;
      case ErrorType.general:
        return Theme.of(context).colorScheme.error;

      // default:
      //   return Theme.of(context).colorScheme.error;
    }
  }
}

enum ErrorType {
  general,
  network,
  server,
  authentication,
  notFound,
  permission,
}

// Error dialog widget for inline error display
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final ErrorType type;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.type = ErrorType.general,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? details,
    VoidCallback? onRetry,
    ErrorType type = ErrorType.general,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        details: details,
        onRetry: onRetry,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        _getIconData(),
        color: _getErrorColor(context),
        size: 32,
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (details != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Details'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    details!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        if (onRetry != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  IconData _getIconData() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.dns;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.general:
        return Icons.error_outline;
      // default:
      //   return Icons.error_outline;
    }
  }

  Color _getErrorColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.amber;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.permission:
        return Colors.purple;
      case ErrorType.general:
        return Theme.of(context).colorScheme.error;
      // default:
      //   return Theme.of(context).colorScheme.error;
    }
  }
}

// Error widget for inline use in screens
class ErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final ErrorType type;
  final bool compact;

  const ErrorWidget({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.type = ErrorType.general,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getErrorColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getErrorColor(context).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIconData(),
              color: _getErrorColor(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconData(),
              color: _getErrorColor(context),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.dns;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.general:
        return Icons.error_outline;
      // default:
      //   return Icons.error_outline;
    }
  }

  Color _getErrorColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.amber;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.permission:
        return Colors.purple;
      case ErrorType.general:
        return Theme.of(context).colorScheme.error;
      // default:
      //   return Theme.of(context).colorScheme.error;
    }
  }
}
