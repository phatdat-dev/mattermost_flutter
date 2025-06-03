import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for user-related endpoints
///
/// This class provides access to all user-related API endpoints
/// as defined in the Mattermost OpenAPI specification.
class MUsersApi {
  final Dio _dio;

  MUsersApi(this._dio);

  /// Get a user by ID
  Future<MUser> getUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get users with pagination
  Future<List<MUser>> getUsers({
    int page = 0,
    int perPage = 60,
    String? inTeam,
    String? notInTeam,
    String? inChannel,
    String? notInChannel,
    String? sort = '',
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (inTeam != null) queryParams['in_team'] = inTeam;
      if (notInTeam != null) queryParams['not_in_team'] = notInTeam;
      if (inChannel != null) queryParams['in_channel'] = inChannel;
      if (notInChannel != null) queryParams['not_in_channel'] = notInChannel;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final response = await _dio.get(
        '/api/v4/users',
        queryParameters: queryParams,
      );

      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new user
  Future<MUser> createUser({
    required String username,
    required String email,
    String? password,
    String? firstName,
    String? lastName,
    String? nickname,
    String? position,
    String? locale,
    MTimeZone? timezone,
    String? authData,
    String? authService,
    Map<String, dynamic>? props,
    MUserNotifyProps? notifyProps,
    String? invitationToken,
    String? invitationLinkToken,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (invitationToken != null) queryParams['t'] = invitationToken;
      if (invitationLinkToken != null) queryParams['iid'] = invitationLinkToken;

      final data = {
        'username': username,
        'email': email,
        if (password != null) 'password': password,
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
        if (position != null && position.isNotEmpty) 'position': position,
        if (locale != null && locale.isNotEmpty) 'locale': locale,
        if (timezone != null) 'timezone': timezone.toJson(),
        if (authData != null) 'auth_data': authData,
        if (authService != null) 'auth_service': authService,
        if (props != null) 'props': props,
        if (notifyProps != null) 'notify_props': notifyProps.toJson(),
      };

      final response = await _dio.post(
        '/api/v4/users',
        data: data,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a user
  Future<MUser> updateUser(
    String userId, {
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? nickname,
    String? position,
    String? locale,
    Map<String, dynamic>? props,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (nickname != null) data['nickname'] = nickname;
      if (position != null) data['position'] = position;
      if (locale != null) data['locale'] = locale;
      if (props != null) data['props'] = props;

      final response = await _dio.put(
        '/api/v4/users/$userId',
        data: data,
      );
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _dio.delete('/api/v4/users/$userId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by username
  Future<MUser> getUserByUsername(String username) async {
    try {
      final response = await _dio.get('/api/v4/users/username/$username');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by email
  Future<MUser> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('/api/v4/users/email/$email');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the current user
  Future<MUser> getMe() async {
    try {
      final response = await _dio.get('/api/v4/users/me');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user password
  Future<void> updateUserPassword(
    String userId, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/api/v4/users/$userId/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _dio.post(
        '/api/v4/users/password/reset/send',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's sessions
  Future<List<MSession>> getUserSessions(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/sessions');
      return (response.data as List).map((sessionData) => MSession.fromJson(sessionData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Revoke a user session
  Future<void> revokeUserSession(String userId, String sessionId) async {
    try {
      await _dio.post(
        '/api/v4/users/$userId/sessions/revoke',
        data: {'session_id': sessionId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's teams
  Future<List<MTeam>> getUserTeams(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams');
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search users
  Future<List<MUser>> searchUsers({
    required String term,
    String? teamId,
    String? notInTeamId,
    String? inChannelId,
    String? notInChannelId,
    bool? allowInactive,
    bool? withoutTeam,
    int? limit,
  }) async {
    try {
      final data = {
        'term': term,
        if (teamId != null) 'team_id': teamId,
        if (notInTeamId != null) 'not_in_team_id': notInTeamId,
        if (inChannelId != null) 'in_channel_id': inChannelId,
        if (notInChannelId != null) 'not_in_channel_id': notInChannelId,
        if (allowInactive != null) 'allow_inactive': allowInactive,
        if (withoutTeam != null) 'without_team': withoutTeam,
        if (limit != null) 'limit': limit,
      };

      final response = await _dio.post(
        '/api/v4/users/search',
        data: data,
      );
      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Login with CWS token
  ///
  /// Auto-Login with CWS token. Redirects to the SSO provider and logs the user in with a one-time use code received from the third party service.
  /// Requires `cws_token` request cookie.
  /// ##### Permissions
  /// No permission required.
  ///
  /// Parameters:
  /// - [loginId]: The email or username used to login
  /// - [cws_token]: Token from a successful CWS authentication
  Future<MUser> loginByCwsToken({
    required String loginId,
    required String cws_token,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/login/cws',
        data: {
          'login_id': loginId,
          'cws_token': cws_token,
        },
      );
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Revoke all sessions for a user
  ///
  /// Revokes all user sessions from the provided user id and session id strings.
  /// ##### Permissions
  /// Must be logged in as the user being updated or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<void> revokeUserAllSessions(String userId) async {
    try {
      await _dio.post('/api/v4/users/$userId/sessions/revoke/all');
    } catch (e) {
      rethrow;
    }
  }

  /// Attach mobile device to session
  ///
  /// Attach a mobile device id to the current session.
  /// ##### Permissions
  /// Must be authenticated.
  ///
  /// Parameters:
  /// - [deviceId]: Mobile device id. For Android prefix the id with `android:` and Apple with `apple:`
  Future<void> attachDeviceId(String deviceId) async {
    try {
      await _dio.put(
        '/api/v4/users/sessions/device',
        data: {'device_id': deviceId},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER PROFILE METHODS ====================

  /// Patch a user
  ///
  /// Partially update a user by providing only the fields you want to update.
  /// Omitted fields will not be updated. The fields that can be updated are defined in the request body, all other provided fields will be ignored.
  /// ##### Permissions
  /// Must be logged in as the user being updated or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [username]: The new username for the user
  /// - [firstName]: The new first name for the user
  /// - [lastName]: The new last name for the user
  /// - [nickname]: The new nickname for the user
  /// - [email]: The new email for the user
  /// - [position]: The new position for the user
  /// - [locale]: The new locale for the user
  /// - [timezone]: The new user's timezone
  /// - [notifyProps]: The new notify props for the user
  /// - [props]: The new props for the user
  Future<MUser> patchUser(
    String userId, {
    String? username,
    String? firstName,
    String? lastName,
    String? nickname,
    String? email,
    String? position,
    String? locale,
    MTimeZone? timezone,
    MUserNotifyProps? notifyProps,
    Map<String, dynamic>? props,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (nickname != null) data['nickname'] = nickname;
      if (email != null) data['email'] = email;
      if (position != null) data['position'] = position;
      if (locale != null) data['locale'] = locale;
      if (timezone != null) data['timezone'] = timezone.toJson();
      if (notifyProps != null) data['notify_props'] = notifyProps.toJson();
      if (props != null) data['props'] = props;

      final response = await _dio.put(
        '/api/v4/users/$userId/patch',
        data: data,
      );
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user roles
  ///
  /// Update a user's roles in the system. All the roles that are to be assigned/unassigned have to be explicitly passed.
  /// Valid user roles are "system_user", "system_admin" or both of them.
  /// Overwrites any previously assigned roles.
  /// ##### Permissions
  /// Must have the `manage_roles` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [roles]: Space-delimited system roles to assign to the user
  Future<void> updateUserRoles(String userId, {required String roles}) async {
    try {
      await _dio.put(
        '/api/v4/users/$userId/roles',
        data: {'roles': roles},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update user active status
  ///
  /// Update user active status from true to false or vice versa.
  /// ##### Permissions
  /// User can deactivate themselves.
  /// User with `manage_system` permission can activate or deactivate a user.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [active]: Use `true` to set the user active, `false` for inactive
  Future<void> updateUserActive(String userId, {required bool active}) async {
    try {
      await _dio.put(
        '/api/v4/users/$userId/active',
        data: {'active': active},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== PROFILE IMAGE METHODS ====================

  /// Get user's profile image
  ///
  /// Get a user's profile image.
  /// ##### Permissions
  /// Must be logged in.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<List<int>> getUserProfileImage(String userId) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/image',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Set user's profile image
  ///
  /// Set a user's profile image based on user_id string parameter.
  /// ##### Permissions
  /// Must be logged in as the user being updated or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [image]: The image to be uploaded
  Future<void> setUserProfileImage(String userId, List<int> image) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          image,
          filename: 'profile.jpg',
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      await _dio.post(
        '/api/v4/users/$userId/image',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user's profile image
  ///
  /// Delete user's profile image and reset to default image based on user_id string parameter.
  /// ##### Permissions
  /// Must be logged in as the user being updated or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<void> deleteUserProfileImage(String userId) async {
    try {
      await _dio.delete('/api/v4/users/$userId/image');
    } catch (e) {
      rethrow;
    }
  }

  /// Get default user's profile image
  ///
  /// Get a user's default profile image. Returns the profile image created based on username.
  /// ##### Permissions
  /// Must be logged in.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<List<int>> getDefaultUserProfileImage(String userId) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/image/default',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== MFA METHODS ====================

  /// Update a user's MFA
  ///
  /// Activates multi-factor authentication for the user if `activate` is true and a valid `code` is provided.
  /// If activate is false, then `code` is not required and multi-factor authentication is disabled for the user.
  /// ##### Permissions
  /// Must be logged in as the user being updated or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [activate]: Use `true` to activate, `false` to deactivate
  /// - [code]: The code produced by your MFA client. Required if `activate` is true
  Future<void> updateUserMfa(
    String userId, {
    required bool activate,
    String? code,
  }) async {
    try {
      final data = <String, dynamic>{
        'activate': activate,
      };
      if (code != null) data['code'] = code;

      await _dio.put(
        '/api/v4/users/$userId/mfa',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generate MFA secret
  ///
  /// Generates an multi-factor authentication secret for a user and returns it as a string and as base64 encoded QR code image.
  /// ##### Permissions
  /// Must be logged in as the user or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<Map<String, dynamic>> generateMfaSecret(String userId) async {
    try {
      final response = await _dio.post('/api/v4/users/$userId/mfa/generate');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Check MFA
  ///
  /// Check if a user has multi-factor authentication active on their account by providing a login id.
  /// Used to check whether an MFA code needs to be provided when logging in.
  /// ##### Permissions
  /// No permission required.
  ///
  /// Parameters:
  /// - [loginId]: The email or username used to login
  Future<Map<String, dynamic>> checkUserMfa(String loginId) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/mfa',
        data: {'login_id': loginId},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER ACCESS TOKEN METHODS ====================

  /// Create a user access token
  ///
  /// Generate a user access token that can be used to authenticate with the Mattermost REST API.
  /// ##### Permissions
  /// Must have `create_user_access_token` permission. For non-self requests, must also have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [description]: A description of the token usage
  Future<Map<String, dynamic>> createUserAccessToken(
    String userId, {
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/$userId/tokens',
        data: {'description': description},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user access tokens
  ///
  /// Get a list of user access tokens for a user. Does not include the actual authentication tokens.
  /// Use query parameters for paging.
  /// ##### Permissions
  /// Must have `read_user_access_token` permission. For non-self requests, must also have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [page]: The page to select
  /// - [perPage]: The number of tokens per page
  Future<List<Map<String, dynamic>>> getUserAccessTokens(
    String userId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/tokens',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Revoke a user access token
  ///
  /// Revoke a user access token and delete any sessions using the token.
  /// ##### Permissions
  /// Must have `revoke_user_access_token` permission. For non-self requests, must also have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [tokenId]: The user access token GUID
  Future<void> revokeUserAccessToken(String tokenId) async {
    try {
      await _dio.post(
        '/api/v4/users/tokens/revoke',
        data: {'token_id': tokenId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get a user access token
  ///
  /// Get a user access token. Does not include the actual authentication token.
  /// ##### Permissions
  /// Must have `read_user_access_token` permission. For non-self requests, must also have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [tokenId]: The user access token GUID
  Future<Map<String, dynamic>> getUserAccessToken(String tokenId) async {
    try {
      final response = await _dio.get('/api/v4/users/tokens/$tokenId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Disable personal access token
  ///
  /// Disable a personal access token and delete any sessions using the token.
  /// The token can be re-enabled using `/users/tokens/enable`.
  /// ##### Permissions
  /// Must have `revoke_user_access_token` permission. For non-self requests, must also have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [tokenId]: The personal access token GUID
  Future<void> disableUserAccessToken(String tokenId) async {
    try {
      await _dio.post(
        '/api/v4/users/tokens/disable',
        data: {'token_id': tokenId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Enable personal access token
  ///
  /// Re-enable a personal access token that has been disabled.
  /// ##### Permissions
  /// Must have `create_user_access_token` permission. For non-self requests, must also have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [tokenId]: The personal access token GUID
  Future<void> enableUserAccessToken(String tokenId) async {
    try {
      await _dio.post(
        '/api/v4/users/tokens/enable',
        data: {'token_id': tokenId},
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER STATISTICS AND FILTERING ====================

  /// Get users by IDs
  ///
  /// Get a list of users based on a provided list of user ids.
  /// ##### Permissions
  /// Requires an active session but no other permissions.
  ///
  /// Parameters:
  /// - [userIds]: List of user ids
  /// - [since]: Only return users that have been modified since the given Unix timestamp (in milliseconds)
  Future<List<MUser>> getUsersByIds(
    List<String> userIds, {
    int? since,
  }) async {
    try {
      final data = <String, dynamic>{
        'user_ids': userIds,
      };
      if (since != null) data['since'] = since;

      final response = await _dio.post(
        '/api/v4/users/ids',
        data: data,
      );
      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get users by usernames
  ///
  /// Get a list of users based on a provided list of usernames.
  /// ##### Permissions
  /// Requires an active session but no other permissions.
  ///
  /// Parameters:
  /// - [usernames]: List of usernames
  Future<List<MUser>> getUsersByUsernames(List<String> usernames) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/usernames',
        data: usernames,
      );
      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get users by group channels
  ///
  /// Get an object containing a key per group channel id in the query and its value as a list of users members of that group channel.
  /// ##### Permissions
  /// Must have `read_channel` permission for the given channels.
  ///
  /// Parameters:
  /// - [groupChannelIds]: List of group channel ids
  Future<Map<String, List<MUser>>> getUsersByGroupChannels(List<String> groupChannelIds) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/group_channels',
        data: groupChannelIds,
      );

      final Map<String, List<MUser>> result = {};
      for (final entry in response.data.entries) {
        result[entry.key] = (entry.value as List).map((userData) => MUser.fromJson(userData)).toList();
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Get total users stats
  ///
  /// Get a total system user stats. This endpoint uses a system-level token and does not require authentication.
  /// ##### Permissions
  /// Must have `get_analytics` permission.
  Future<Map<String, dynamic>> getTotalUsersStats() async {
    try {
      final response = await _dio.get('/api/v4/users/stats');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get filtered users stats
  ///
  /// Get a subset of user stats provided a filter. This endpoint uses a system-level token and does not require authentication.
  /// ##### Permissions
  /// Must have `get_analytics` permission.
  ///
  /// Parameters:
  /// - [inTeam]: The team ID to filter the users by
  /// - [inChannel]: The channel ID to filter the users by
  /// - [includeDeleted]: Include deactivated users
  /// - [includeBots]: Include bot user accounts
  /// - [rolesFilter]: Filter users that have any of the specified roles, specified as a comma separated value
  /// - [channelRolesFilter]: Filter users that have any of the specified channel roles, specified as a comma separated value
  /// - [teamRolesFilter]: Filter users that have any of the specified team roles, specified as a comma separated value
  Future<Map<String, dynamic>> getFilteredUsersStats({
    String? inTeam,
    String? inChannel,
    bool? includeDeleted,
    bool? includeBots,
    String? rolesFilter,
    String? channelRolesFilter,
    String? teamRolesFilter,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (inTeam != null) queryParams['in_team'] = inTeam;
      if (inChannel != null) queryParams['in_channel'] = inChannel;
      if (includeDeleted != null) queryParams['include_deleted'] = includeDeleted.toString();
      if (includeBots != null) queryParams['include_bots'] = includeBots.toString();
      if (rolesFilter != null) queryParams['roles'] = rolesFilter;
      if (channelRolesFilter != null) queryParams['channel_roles'] = channelRolesFilter;
      if (teamRolesFilter != null) queryParams['team_roles'] = teamRolesFilter;

      final response = await _dio.get(
        '/api/v4/users/stats/filtered',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER THREAD METHODS ====================

  /// Get user threads
  ///
  /// Get all threads that user is following.
  /// ##### Permissions
  /// Must be logged in as the user or have `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user. This can also be "me" which will point to the current user.
  /// - [teamId]: The ID of the team in which the thread is
  /// - [since]: Since filters the threads based on their LastUpdateAt timestamp
  /// - [deleted]: Deleted will specify that even deleted threads should be returned (For mobile sync)
  /// - [extended]: Extended will enrich the response with participant details
  /// - [page]: Page specifies which part of the results to return, by perPage
  /// - [pageSize]: PageSize specifies the size of the returned chunk of results
  /// - [totalsOnly]: Setting this to true will only return the total counts
  /// - [threadsOnly]: Setting this to true will only return threads
  Future<Map<String, dynamic>> getUserThreads(
    String userId, {
    required String teamId,
    int? since,
    bool? deleted,
    bool? extended,
    int? page,
    int? pageSize,
    bool? totalsOnly,
    bool? threadsOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'teamId': teamId,
      };
      if (since != null) queryParams['since'] = since.toString();
      if (deleted != null) queryParams['deleted'] = deleted.toString();
      if (extended != null) queryParams['extended'] = extended.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (pageSize != null) queryParams['pageSize'] = pageSize.toString();
      if (totalsOnly != null) queryParams['totalsOnly'] = totalsOnly.toString();
      if (threadsOnly != null) queryParams['threadsOnly'] = threadsOnly.toString();

      final response = await _dio.get(
        '/api/v4/users/$userId/threads',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update a thread's read state
  ///
  /// Update a thread's read state to timestamp.
  /// ##### Permissions
  /// Must be logged in as the user or have `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user. This can also be "me" which will point to the current user.
  /// - [teamId]: The ID of the team in which the thread is
  /// - [threadId]: The ID of the thread to update
  /// - [timestamp]: The timestamp to which the thread's "last read reply" will be reset
  Future<Map<String, dynamic>> updateThreadRead(
    String userId, {
    required String teamId,
    required String threadId,
    required int timestamp,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v4/users/$userId/teams/$teamId/threads/$threadId/read/$timestamp',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Start following a thread
  ///
  /// Start following a thread.
  /// ##### Permissions
  /// Must be logged in as the user or have `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user. This can also be "me" which will point to the current user.
  /// - [teamId]: The ID of the team in which the thread is
  /// - [threadId]: The ID of the thread to follow
  Future<Map<String, dynamic>> followThread(
    String userId, {
    required String teamId,
    required String threadId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v4/users/$userId/teams/$teamId/threads/$threadId/following',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Stop following a thread
  ///
  /// Stop following a thread.
  /// ##### Permissions
  /// Must be logged in as the user or have `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user. This can also be "me" which will point to the current user.
  /// - [teamId]: The ID of the team in which the thread is
  /// - [threadId]: The ID of the thread to update
  Future<void> unfollowThread(
    String userId, {
    required String teamId,
    required String threadId,
  }) async {
    try {
      await _dio.delete(
        '/api/v4/users/$userId/teams/$teamId/threads/$threadId/following',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER MIGRATION METHODS ====================

  /// Migrate user accounts authentication type
  ///
  /// Migrate a user, with a new type of authentication. For example, you can migrate a user from email authentication to OAuth 2.0.
  /// ##### Permissions
  /// Must have `manage_system` permission.
  ///
  /// Parameters:
  /// - [from]: The current authentication type for the matched users.
  /// - [to]: The authentication service to migrate users to.
  /// - [matchField]: Foreign user field name to match.
  /// - [force]: Whether to force the migration.
  /// - [dryRun]: If true, do not actually do any migration.
  Future<void> migrateAuthToOAuth({
    required String from,
    required String to,
    required String matchField,
    bool? force,
    bool? dryRun,
  }) async {
    try {
      final data = <String, dynamic>{
        'from': from,
        'to': to,
        'match_field': matchField,
      };
      if (force != null) data['force'] = force;
      if (dryRun != null) data['dry_run'] = dryRun;

      await _dio.post(
        '/api/v4/users/migrate_auth/oauth',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Migrate user accounts authentication type
  ///
  /// Migrate a user, with a new type of authentication. For example, you can migrate a user from OAuth 2.0 to email authentication.
  /// ##### Permissions
  /// Must have `manage_system` permission.
  ///
  /// Parameters:
  /// - [from]: The current authentication type for the matched users.
  /// - [to]: The authentication service to migrate users to.
  /// - [matchField]: Foreign user field name to match.
  /// - [force]: Whether to force the migration.
  /// - [dryRun]: If true, do not actually do any migration.
  Future<void> migrateAuthToSaml({
    required String from,
    required String to,
    required String matchField,
    bool? force,
    bool? dryRun,
  }) async {
    try {
      final data = <String, dynamic>{
        'from': from,
        'to': to,
        'match_field': matchField,
      };
      if (force != null) data['force'] = force;
      if (dryRun != null) data['dry_run'] = dryRun;

      await _dio.post(
        '/api/v4/users/migrate_auth/saml',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ADDITIONAL USER METHODS ====================

  /// Reset password
  ///
  /// Update the password for a user using a one-use, timed recovery code tied to the user's account.
  /// Only works for non-SSO users.
  /// ##### Permissions
  /// No permissions required.
  ///
  /// Parameters:
  /// - [code]: The recovery code
  /// - [newPassword]: The new password for the user
  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/api/v4/users/password/reset',
        data: {
          'code': code,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user audits
  ///
  /// Get a list of audit by providing the user GUID.
  /// ##### Permissions
  /// Must be logged in as the user or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<List<Map<String, dynamic>>> getUserAudits(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/audits');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify user email
  ///
  /// Verify the email used by a user to sign-up their account with.
  /// ##### Permissions
  /// No permissions required.
  ///
  /// Parameters:
  /// - [token]: The token given to validate the email
  Future<void> verifyUserEmail(String token) async {
    try {
      await _dio.post(
        '/api/v4/users/email/verify',
        data: {'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Send verification email
  ///
  /// Send an email with a verification link to a user that has an email matching the one in the request body.
  /// This endpoint will return success even if the email does not match any users on the system.
  /// ##### Permissions
  /// No permissions required.
  ///
  /// Parameters:
  /// - [email]: The email of the user
  Future<void> sendVerificationEmail(String email) async {
    try {
      await _dio.post(
        '/api/v4/users/email/verify/send',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Convert user to bot
  ///
  /// Convert a regular user into a bot user.
  /// ##### Permissions
  /// Must have `manage_bots` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<Map<String, dynamic>> convertUserToBot(String userId) async {
    try {
      final response = await _dio.post('/api/v4/users/$userId/convert_to_bot');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user terms of service
  ///
  /// Get terms of service for the user
  /// ##### Permissions
  /// Must be logged in as the user or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  Future<Map<String, dynamic>> getUserTermsOfService(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/terms_of_service');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Records user action when they accept or decline custom terms of service
  ///
  /// Records user action when they accept or decline custom terms of service.
  /// Records the action in audit table. Updates user's last accepted terms of service ID if they accepted it.
  /// ##### Permissions
  /// Must be logged in as the user or have the `edit_other_users` permission.
  ///
  /// Parameters:
  /// - [userId]: User GUID
  /// - [serviceTermsId]: terms of service ID on which the user is acting on
  /// - [accepted]: true or false, indicates whether the user accepted or rejected the terms of service.
  Future<void> registerTermsOfServiceAction(
    String userId, {
    required String serviceTermsId,
    required bool accepted,
  }) async {
    try {
      await _dio.post(
        '/api/v4/users/$userId/terms_of_service',
        data: {
          'serviceTermsId': serviceTermsId,
          'accepted': accepted,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
