import 'package:flutter/material.dart';

class BottomSheetScreen extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool isDismissible;
  final bool showDragHandle;
  final double? height;
  final VoidCallback? onClose;

  const BottomSheetScreen({
    super.key,
    required this.child,
    this.title,
    this.isDismissible = true,
    this.showDragHandle = true,
    this.height,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool showDragHandle = true,
    double? height,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetScreen(
        title: title,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
        height: height,
        onClose: onClose,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultHeight = screenHeight * 0.75;
    final sheetHeight = height ?? defaultHeight;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (showDragHandle && isDismissible)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Header
          if (title != null)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 8, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onClose != null || isDismissible)
                    IconButton(
                      onPressed: () {
                        if (onClose != null) {
                          onClose!();
                        }
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// Specialized bottom sheets for common use cases

class ListBottomSheet extends StatelessWidget {
  final String? title;
  final List<BottomSheetListItem> items;
  final bool showDragHandle;

  const ListBottomSheet({
    super.key,
    this.title,
    required this.items,
    this.showDragHandle = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<BottomSheetListItem> items,
    bool showDragHandle = true,
  }) {
    return BottomSheetScreen.show<T>(
      context: context,
      title: title,
      showDragHandle: showDragHandle,
      child: ListBottomSheet(
        title: title,
        items: items,
        showDragHandle: showDragHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: item.icon != null ? Icon(item.icon, color: item.iconColor) : null,
          title: Text(
            item.title,
            style: TextStyle(
              color: item.textColor,
              fontWeight: item.isDestructive ? FontWeight.w500 : null,
            ),
          ),
          subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
          trailing: item.trailing,
          enabled: item.isEnabled,
          onTap: item.isEnabled
              ? () {
                  Navigator.of(context).pop(item.value);
                  item.onTap?.call();
                }
              : null,
        );
      },
    );
  }
}

class BottomSheetListItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;
  final bool isEnabled;
  final bool isDestructive;
  final VoidCallback? onTap;
  final dynamic value;

  BottomSheetListItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.textColor,
    this.trailing,
    this.isEnabled = true,
    this.isDestructive = false,
    this.onTap,
    this.value,
  });

  factory BottomSheetListItem.destructive({
    required String title,
    String? subtitle,
    IconData? icon,
    VoidCallback? onTap,
    dynamic value,
  }) {
    return BottomSheetListItem(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: Colors.red,
      textColor: Colors.red,
      isDestructive: true,
      onTap: onTap,
      value: value,
    );
  }
}

// Action bottom sheet for quick actions
class ActionBottomSheet extends StatelessWidget {
  final String? title;
  final String? description;
  final List<ActionBottomSheetItem> actions;

  const ActionBottomSheet({
    super.key,
    this.title,
    this.description,
    required this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? description,
    required List<ActionBottomSheetItem> actions,
  }) {
    return BottomSheetScreen.show<T>(
      context: context,
      title: title,
      height: MediaQuery.of(context).size.height * 0.5,
      child: ActionBottomSheet(
        title: title,
        description: description,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (description != null) ...[
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],

          Expanded(
            child: ListView.separated(
              itemCount: actions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final action = actions[index];
                return SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: action.isEnabled
                        ? () {
                            Navigator.of(context).pop(action.value);
                            action.onPressed?.call();
                          }
                        : null,
                    icon: action.icon != null ? Icon(action.icon) : const SizedBox.shrink(),
                    label: Text(action.title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: action.isDestructive ? Theme.of(context).colorScheme.error : null,
                      foregroundColor: action.isDestructive ? Theme.of(context).colorScheme.onError : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class ActionBottomSheetItem {
  final String title;
  final IconData? icon;
  final bool isEnabled;
  final bool isDestructive;
  final VoidCallback? onPressed;
  final dynamic value;

  ActionBottomSheetItem({
    required this.title,
    this.icon,
    this.isEnabled = true,
    this.isDestructive = false,
    this.onPressed,
    this.value,
  });

  factory ActionBottomSheetItem.destructive({
    required String title,
    IconData? icon,
    VoidCallback? onPressed,
    dynamic value,
  }) {
    return ActionBottomSheetItem(
      title: title,
      icon: icon,
      isDestructive: true,
      onPressed: onPressed,
      value: value,
    );
  }
}
