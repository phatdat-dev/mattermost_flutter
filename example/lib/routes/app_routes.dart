import 'package:flutter/material.dart';
import 'package:mattermost_flutter/mattermost_flutter.dart';

import '../constants/screens.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/mfa_screen.dart';
import '../screens/auth/select_server_screen.dart';
import '../screens/auth/sso_screen.dart';
import '../screens/auth/terms_of_service_screen.dart';
import '../screens/channels/add_channel_members_screen.dart';
import '../screens/channels/browse_channels_screen.dart';
import '../screens/channels/channel_files_screen.dart';
import '../screens/channels/channel_info_screen.dart';
import '../screens/channels/channel_notification_preferences_screen.dart';
import '../screens/channels/create_channel_screen.dart';
import '../screens/channels/edit_channel_screen.dart';
import '../screens/channels/manage_channel_members_screen.dart';
import '../screens/direct_messages/create_direct_message_screen.dart';
import '../screens/direct_messages/direct_messages_screen.dart';
import '../screens/direct_messages/group_chat_screen.dart';
import '../screens/main/channel_screen.dart';
import '../screens/main/dashboard_screen.dart';
import '../screens/main/thread_screen.dart';
import '../screens/messages/edit_post_screen.dart';
import '../screens/messages/global_threads_screen.dart';
import '../screens/messages/pinned_messages_screen.dart';
import '../screens/messages/recent_mentions_screen.dart';
import '../screens/messages/saved_messages_screen.dart';
import '../screens/messages/search_messages_screen.dart';
import '../screens/modal/emoji_picker_screen.dart';
import '../screens/modal/file_viewer_screen.dart';
import '../screens/modal/gallery_screen.dart';
import '../screens/modal/post_options_screen.dart';
import '../screens/modal/reactions_screen.dart';
import '../screens/profile/custom_status_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/advanced_settings_screen.dart';
import '../screens/settings/display_settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/theme_settings_screen.dart';

class AppRoutes {
  // Static references to reduce duplication
  static late MattermostClient client;
  static MUser? currentUser;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case Screens.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Screens.sso:
        return MaterialPageRoute(builder: (_) => const SSOScreen());
      case Screens.mfa:
        return MaterialPageRoute(builder: (_) => const MFAScreen());
      case Screens.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case Screens.selectServer:
        return MaterialPageRoute(builder: (_) => const SelectServerScreen());
      case Screens.termsOfService:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());

      // Main routes
      case Screens.home:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Screens.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case Screens.channel:
        return MaterialPageRoute(
          builder: (_) => ChannelScreen(channel: settings.arguments as MChannel),
        );
      case Screens.thread:
        return MaterialPageRoute(
          builder: (_) => ThreadScreen(
            post: settings.arguments as MPost,
          ),
        );

      // Channel routes
      case Screens.browseChannels:
        return MaterialPageRoute(builder: (_) => const BrowseChannelsScreen());
      case Screens.createChannel:
        return MaterialPageRoute(builder: (_) => const CreateChannelScreen());
      case Screens.editChannel:
        return MaterialPageRoute(builder: (_) => const EditChannelScreen());
      case Screens.channelInfo:
        return MaterialPageRoute(builder: (_) => const ChannelInfoScreen());
      case Screens.channelFiles:
        return MaterialPageRoute(builder: (_) => const ChannelFilesScreen());
      case Screens.manageChannelMembers:
        return MaterialPageRoute(
          builder: (_) => ManageChannelMembersScreen(
            channel: settings.arguments as MChannel,
          ),
        );
      case Screens.channelNotificationPreferences:
        return MaterialPageRoute(
          builder: (_) => ChannelNotificationPreferencesScreen(
            channel: settings.arguments as MChannel,
          ),
        );
      case Screens.addChannelMembers:
        return MaterialPageRoute(
          builder: (_) => AddChannelMembersScreen(
            channel: settings.arguments as MChannel,
          ),
        );

      // Direct message routes
      case Screens.directMessages:
        return MaterialPageRoute(
          builder: (_) => const DirectMessagesScreen(),
        );
      case Screens.createDirectMessage:
        return MaterialPageRoute(builder: (_) => const CreateDirectMessageScreen());
      case Screens.groupChat:
        final args = settings.arguments as GroupChatArguments?;
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            client: args!.client,
            currentUser: args.currentUser,
            channel: args.channel,
            members: args.members.cast<MUser>(),
          ),
        );

      // Message routes
      case Screens.globalThreads:
        return MaterialPageRoute(
          builder: (_) => const GlobalThreadsScreen(),
        );
      case Screens.savedMessages:
        return MaterialPageRoute(builder: (_) => const SavedMessagesScreen());
      case Screens.recentMentions:
        return MaterialPageRoute(builder: (_) => const RecentMentionsScreen());
      case Screens.searchMessages:
        return MaterialPageRoute(builder: (_) => const SearchMessagesScreen());
      case Screens.pinnedMessages:
        return MaterialPageRoute(
          builder: (_) => PinnedMessagesScreen(channel: settings.arguments as MChannel),
        );
      case Screens.editPost:
        final args = settings.arguments as PostArguments?;
        return MaterialPageRoute(
          builder: (_) => EditPostScreen(
            client: args!.client,
            post: args.post,
            currentUser: args.currentUser,
          ),
        );

      // Profile routes
      case Screens.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      case Screens.userProfile:
        final args = settings.arguments as UserProfileArguments?;
        return MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            user: args?.user,
            client: args?.client ?? client,
            currentUser: args?.currentUser ?? currentUser,
          ),
        );
      case Screens.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case Screens.customStatus:
        return MaterialPageRoute(builder: (_) => const CustomStatusScreen());

      // Settings routes
      case Screens.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case Screens.displaySettings:
        return MaterialPageRoute(builder: (_) => const DisplaySettingsScreen());
      case Screens.notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      case Screens.advancedSettings:
        return MaterialPageRoute(builder: (_) => const AdvancedSettingsScreen());
      case Screens.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case Screens.themeSettings:
        return MaterialPageRoute(builder: (_) => const ThemeSettingsScreen());

      // Modal routes
      case Screens.postOptions:
        return MaterialPageRoute(builder: (_) => const PostOptionsScreen());
      case Screens.reactions:
        return MaterialPageRoute(builder: (_) => const ReactionsScreen());
      case Screens.emojiPicker:
        return MaterialPageRoute(builder: (_) => const EmojiPickerScreen());
      case Screens.fileViewer:
        return MaterialPageRoute(builder: (_) => const FileViewerScreen());
      case Screens.gallery:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

class GroupChatArguments {
  final MattermostClient client;
  final MUser currentUser;
  final MChannel channel;
  final List<MUser> members;

  GroupChatArguments({
    required this.client,
    required this.currentUser,
    required this.channel,
    required this.members,
  });
}

class PostArguments {
  final MattermostClient client;
  final MPost post;
  final MUser currentUser;

  PostArguments({
    required this.client,
    required this.post,
    required this.currentUser,
  });
}

class UserProfileArguments {
  final MattermostClient client;
  final MUser user;
  final MUser currentUser;

  UserProfileArguments({
    required this.client,
    required this.user,
    required this.currentUser,
  });
}
