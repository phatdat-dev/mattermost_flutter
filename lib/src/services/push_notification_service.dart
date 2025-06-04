/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/config.dart';
import '../mattermost_client.dart';

class PushNotificationService {
  final MattermostClient client;
  final MattermostConfig config;
  
  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;
  
  final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  
  PushNotificationService({required this.client, required this.config});
  
  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    
    // Request permission
    await _requestPermission();
    
    // Initialize local notifications
    _localNotifications = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Configure notification channels for Android
    if (Platform.isAndroid) {
      await _configureAndroidChannels();
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle notification taps when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message.data);
      }
    });
    
    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data);
    });
    
    // Register device token with Mattermost server
    await _registerDeviceToken();
  }
  
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    debugPrint('User notification permission status: ${settings.authorizationStatus}');
  }
  
  Future<void> _configureAndroidChannels() async {
    // Create high priority channel for important notifications
    const highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    
    // Create default channel for regular notifications
    const defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'This channel is used for default notifications.',
      importance: Importance.defaultImportance,
    );
    
    // Register the channels with the system
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannels([highImportanceChannel, defaultChannel]);
  }
  
  Future<void> _registerDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        
        // Register the token with Mattermost server
        await client.users.attachDeviceToUser(
          deviceId: token,
          platform: Platform.isAndroid ? 'android' : 'ios',
        );
      }
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.data}');
    
    // Extract notification data
    final data = message.data;
    final notification = message.notification;
    
    if (notification != null) {
      // Show local notification
      _showLocalNotification(
        id: data.hashCode,
        title: notification.title ?? 'New Message',
        body: notification.body ?? '',
        payload: jsonEncode(data),
      );
    }
    
    // Broadcast notification data to app
    _notificationController.add(data);
  }
  
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationTap(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }
  
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Broadcast notification tap event to app
    _notificationController.add({
      ...data,
      'tapped': true,
    });
  }
  
  Future<void> updateNotificationPreferences({
    required String userId,
    required String channelId,
    bool? desktop,
    bool? mobile,
    bool? markUnread,
  }) async {
    try {
      // Get current notification preferences
      final member = await client.channels.getChannelMember(channelId, userId);
      final notifyProps = member.notifyProps ?? MChannelNotifyProps();
      
      // Update notification preferences
      final updatedProps = MChannelNotifyProps(
        desktop: desktop != null ? (desktop ? 'all' : 'none') : notifyProps.desktop,
        mobile: mobile != null ? (mobile ? 'all' : 'none') : notifyProps.mobile,
        markUnread: markUnread != null ? (markUnread ? 'all' : 'mention') : notifyProps.markUnread,
      );
      
      // Save updated preferences
      await client.channels.updateChannelMemberNotifyProps(
        channelId,
        userId,
        updatedProps,
      );
    } catch (e) {
      debugPrint('Failed to update notification preferences: $e');
      rethrow;
    }
  }
  
  void dispose() {
    _notificationController.close();
  }
}

// This function must be top-level (not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handling
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.data}');
  
  // You can't show UI here, but you can update local storage or perform other background tasks
}
*/