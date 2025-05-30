import 'package:flutter/material.dart';

// Navigation service for managing app navigation
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  // Push a new screen
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  // Replace current screen
  static Future<T?> pushReplacementNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Push and remove all previous screens
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  // Pop current screen
  static void pop<T extends Object?>([T? result]) {
    return navigator!.pop<T>(result);
  }

  // Pop until specific route
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    return navigator!.popUntil(predicate);
  }

  // Can pop current screen
  static bool canPop() {
    return navigator!.canPop();
  }

  // Show modal dialog
  static Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      builder: (context) => child,
    );
  }

  // Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => child,
    );
  }

  // Show snackbar
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  // Navigate to home screen and clear stack
  static Future<void> navigateToHome() {
    return pushNamedAndRemoveUntil(
      '/dashboard',
      (route) => false,
    );
  }

  // Navigate to login and clear stack
  static Future<void> navigateToLogin() {
    return pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  // Navigate to channel
  static Future<void> navigateToChannel(String channelId, {String? teamId}) {
    return pushNamed(
      '/channel',
      arguments: {
        'channelId': channelId,
        'teamId': teamId,
      },
    );
  }

  // Navigate to thread
  static Future<void> navigateToThread(String threadId, String channelId) {
    return pushNamed(
      '/thread',
      arguments: {
        'threadId': threadId,
        'channelId': channelId,
      },
    );
  }

  // Navigate to user profile
  static Future<void> navigateToUserProfile(String userId) {
    return pushNamed(
      '/user-profile',
      arguments: {'userId': userId},
    );
  }

  // Navigate to settings
  static Future<void> navigateToSettings() {
    return pushNamed('/settings');
  }

  // Navigate to direct message
  static Future<void> navigateToDirectMessage(String userId) {
    return pushNamed(
      '/direct-message',
      arguments: {'userId': userId},
    );
  }

  // Navigate to group chat
  static Future<void> navigateToGroupChat(List<String> userIds) {
    return pushNamed(
      '/group-chat',
      arguments: {'userIds': userIds},
    );
  }
}
