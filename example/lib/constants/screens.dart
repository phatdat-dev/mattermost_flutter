// Constants for screen names used in navigation
class Screens {
  // Auth screens
  static const String login = 'login';
  static const String sso = 'sso';
  static const String mfa = 'mfa';
  static const String forgotPassword = 'forgot_password';
  static const String selectServer = 'select_server';
  static const String termsOfService = 'terms_of_service';

  // Main screens
  static const String home = 'home';
  static const String dashboard = 'dashboard';
  static const String channelList = 'channel_list';
  static const String channel = 'channel';
  static const String thread = 'thread';

  // Channel related screens
  static const String browseChannels = 'browse_channels';
  static const String createChannel = 'create_channel';
  static const String editChannel = 'edit_channel';
  static const String channelInfo = 'channel_info';
  static const String channelFiles = 'channel_files';
  static const String channelNotificationPreferences = 'channel_notification_preferences';
  static const String manageChannelMembers = 'manage_channel_members';
  static const String addChannelMembers = 'add_channel_members';

  // Direct message screens
  static const String directMessages = 'direct_messages';
  static const String createDirectMessage = 'create_direct_message';
  static const String groupChat = 'group_chat';

  // Message related screens
  static const String globalThreads = 'global_threads';
  static const String savedMessages = 'saved_messages';
  static const String recentMentions = 'recent_mentions';
  static const String searchMessages = 'search_messages';
  static const String pinnedMessages = 'pinned_messages';
  static const String editPost = 'edit_post';
  static const String postOptions = 'post_options';
  static const String reactions = 'reactions';

  // User/Profile screens
  static const String profile = 'profile';
  static const String userProfile = 'user_profile';
  static const String editProfile = 'edit_profile';
  static const String customStatus = 'custom_status';

  // Settings screens
  static const String settings = 'settings';
  static const String displaySettings = 'display_settings';
  static const String themeSettings = 'theme_settings';
  static const String notificationSettings = 'notification_settings';
  static const String advancedSettings = 'advanced_settings';
  static const String about = 'about';

  // Team screens
  static const String selectTeam = 'select_team';
  static const String teamSettings = 'team_settings';
  static const String invite = 'invite';

  // Utility screens
  static const String gallery = 'gallery';
  static const String imageViewer = 'image_viewer';
  static const String videoPlayer = 'video_player';
  static const String fileViewer = 'file_viewer';
  static const String emojiPicker = 'emoji_picker';
  static const String bottomSheet = 'bottom_sheet';

  // Search and find
  static const String search = 'search';
  static const String findChannels = 'find_channels';

  // Call screens (if calls feature is implemented)
  static const String callScreen = 'call_screen';
  static const String callParticipants = 'call_participants';

  // Other utility screens
  static const String loading = 'loading';
  static const String error = 'error';
  static const String webView = 'web_view';
}

// Screen categories for navigation handling
class ScreenCategories {
  static const Set<String> authScreens = {
    Screens.login,
    Screens.sso,
    Screens.mfa,
    Screens.forgotPassword,
    Screens.selectServer,
    Screens.termsOfService,
  };

  static const Set<String> mainScreens = {
    Screens.home,
    Screens.dashboard,
    Screens.channelList,
    Screens.channel,
    Screens.directMessages,
    Screens.globalThreads,
    Screens.savedMessages,
    Screens.recentMentions,
  };

  static const Set<String> modalScreens = {
    Screens.browseChannels,
    Screens.createChannel,
    Screens.editChannel,
    Screens.channelInfo,
    Screens.createDirectMessage,
    Screens.userProfile,
    Screens.editProfile,
    Screens.settings,
    Screens.invite,
    Screens.emojiPicker,
  };

  static const Set<String> settingsScreens = {
    Screens.settings,
    Screens.displaySettings,
    Screens.themeSettings,
    Screens.notificationSettings,
    Screens.advancedSettings,
    Screens.about,
  };
}
