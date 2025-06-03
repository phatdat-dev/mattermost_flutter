import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/models.dart';

/// Mattermost Teams API
///
/// This class provides methods for team management, member operations,
/// invitations, statistics, and team-related functionality according
/// to the Mattermost API v4 specification.
///
/// All methods require appropriate permissions as documented in each method.
class MTeamsApi {
  final Dio _dio;

  MTeamsApi(this._dio);

  /// Create a new team
  Future<MTeam> createTeam({
    required String name,
    required String displayName,
    required String type,
    String? description,
    String? companyName,
    String? allowedDomains,
    bool? allowOpenInvite,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'display_name': displayName,
        'type': type,
      };
      if (description != null) data['description'] = description;
      if (companyName != null) data['company_name'] = companyName;
      if (allowedDomains != null) data['allowed_domains'] = allowedDomains;
      if (allowOpenInvite != null) data['allow_open_invite'] = allowOpenInvite;

      final response = await _dio.post('/api/v4/teams', data: data);
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a team by ID
  Future<MTeam> getTeam(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams with pagination
  Future<List<MTeam>> getTeams({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team by name
  Future<MTeam> getTeamByName(String name) async {
    try {
      final response = await _dio.get('/api/v4/teams/name/$name');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a team
  Future<MTeam> updateTeam(
    String teamId, {
    String? displayName,
    String? description,
    String? companyName,
    String? allowedDomains,
    String? inviteId,
    bool? allowOpenInvite,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (description != null) data['description'] = description;
      if (companyName != null) data['company_name'] = companyName;
      if (allowedDomains != null) data['allowed_domains'] = allowedDomains;
      if (inviteId != null) data['invite_id'] = inviteId;
      if (allowOpenInvite != null) data['allow_open_invite'] = allowOpenInvite;

      final response = await _dio.put(
        '/api/v4/teams/$teamId',
        data: data,
      );
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a team
  Future<void> deleteTeam(String teamId, {bool permanent = false}) async {
    try {
      await _dio.delete(
        '/api/v4/teams/$teamId',
        queryParameters: {'permanent': permanent.toString()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get a team member by user ID
  Future<MTeamMember> getTeamMember(String teamId, String userId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/members/$userId');
      return MTeamMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members
  Future<List<MTeamMember>> getTeamMembers(
    String teamId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/members',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((memberData) => MTeamMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add a user to a team
  Future<MTeamMember> addTeamMember({
    required String teamId,
    required String userId,
    String? roles,
  }) async {
    try {
      final data = <String, dynamic>{
        'team_id': teamId,
        'user_id': userId,
      };
      if (roles != null) data['roles'] = roles;

      final response = await _dio.post(
        '/api/v4/teams/$teamId/members',
        data: data,
      );
      return MTeamMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a user from a team
  Future<void> removeTeamMember(String teamId, String userId) async {
    try {
      await _dio.delete('/api/v4/teams/$teamId/members/$userId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get team stats
  Future<MTeamStats> getTeamStats(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/stats');
      return MTeamStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams for a user
  Future<List<MTeam>> getTeamsForUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams');
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search teams
  Future<List<MTeam>> searchTeams({
    String? term,
    bool? allowOpenInvite,
    int? page,
    int? perPage,
    bool? excludePolicyConstrained,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (term != null) data['term'] = term;
      if (allowOpenInvite != null) data['allow_open_invite'] = allowOpenInvite;
      if (page != null) data['page'] = page;
      if (perPage != null) data['per_page'] = perPage;
      if (excludePolicyConstrained != null) data['exclude_policy_constrained'] = excludePolicyConstrained;

      final response = await _dio.post(
        '/api/v4/teams/search',
        data: data,
      );
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Patch a team
  Future<MTeam> patchTeam(
    String teamId, {
    String? displayName,
    String? description,
    String? companyName,
    String? allowedDomains,
    String? inviteId,
    bool? allowOpenInvite,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (description != null) data['description'] = description;
      if (companyName != null) data['company_name'] = companyName;
      if (allowedDomains != null) data['allowed_domains'] = allowedDomains;
      if (inviteId != null) data['invite_id'] = inviteId;
      if (allowOpenInvite != null) data['allow_open_invite'] = allowOpenInvite;

      final response = await _dio.patch(
        '/api/v4/teams/$teamId/patch',
        data: data,
      );
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Regenerate team invite id
  Future<MTeam> regenerateTeamInviteId(String teamId) async {
    try {
      final response = await _dio.post('/api/v4/teams/$teamId/regenerate_invite_id');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Restore a team
  Future<MTeam> restoreTeam(String teamId) async {
    try {
      final response = await _dio.post('/api/v4/teams/$teamId/restore');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members for a user across teams
  Future<List<MTeamMember>> getTeamMembersForUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams/members');
      return (response.data as List).map((memberData) => MTeamMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add multiple users to a team
  Future<List<MTeamMember>> addTeamMembers({
    required String teamId,
    required List<Map<String, String>> members,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams/$teamId/members/batch',
        data: members,
      );
      return (response.data as List).map((memberData) => MTeamMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members by IDs
  Future<List<MTeamMember>> getTeamMembersByIds(
    String teamId,
    List<String> userIds,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams/$teamId/members/ids',
        data: userIds,
      );
      return (response.data as List).map((memberData) => MTeamMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update team member roles
  Future<MTeamMember> updateTeamMemberRoles({
    required String teamId,
    required String userId,
    required String roles,
  }) async {
    try {
      final data = {'roles': roles};
      final response = await _dio.put(
        '/api/v4/teams/$teamId/members/$userId/roles',
        data: data,
      );
      return MTeamMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update team member scheme roles
  Future<MTeamMember> updateTeamMemberSchemeRoles({
    required String teamId,
    required String userId,
    required bool schemeAdmin,
    required bool schemeUser,
  }) async {
    try {
      final data = {
        'scheme_admin': schemeAdmin,
        'scheme_user': schemeUser,
      };
      final response = await _dio.put(
        '/api/v4/teams/$teamId/members/$userId/schemeRoles',
        data: data,
      );
      return MTeamMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if team exists
  Future<Map<String, bool>> teamExists(String name) async {
    try {
      final response = await _dio.get('/api/v4/teams/name/$name/exists');
      return {'exists': response.data['exists'] ?? false};
    } catch (e) {
      rethrow;
    }
  }

  /// Get unreads for a team
  Future<MTeamUnread> getTeamUnreads(String teamId, String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams/$teamId/unread');
      return MTeamUnread.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get unreads for teams
  Future<List<MTeamUnread>> getTeamsUnreads(String userId, {String? excludeTeam}) async {
    try {
      final queryParams = <String, String>{};
      if (excludeTeam != null) queryParams['exclude_team'] = excludeTeam;

      final response = await _dio.get(
        '/api/v4/users/$userId/teams/unread',
        queryParameters: queryParams,
      );
      return (response.data as List).map((unreadData) => MTeamUnread.fromJson(unreadData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team icon
  Future<Uint8List> getTeamIcon(String teamId) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/image',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Set team icon
  Future<void> setTeamIcon(String teamId, Uint8List imageData) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageData, filename: 'team_icon.png'),
      });
      await _dio.post('/api/v4/teams/$teamId/image', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove team icon
  Future<void> removeTeamIcon(String teamId) async {
    try {
      await _dio.delete('/api/v4/teams/$teamId/image');
    } catch (e) {
      rethrow;
    }
  }

  /// Get team by invite ID
  Future<MTeam> getTeamByInviteId(String inviteId) async {
    try {
      final response = await _dio.get('/api/v4/teams/invite/$inviteId');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Join team by invite ID
  Future<MTeam> joinTeamByInviteId(String inviteId) async {
    try {
      final response = await _dio.post('/api/v4/teams/invite/$inviteId');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Invite users to team by email
  Future<void> inviteUsersToTeam({
    required String teamId,
    required List<String> emails,
  }) async {
    try {
      await _dio.post('/api/v4/teams/$teamId/invite/email', data: emails);
    } catch (e) {
      rethrow;
    }
  }

  /// Send welcome email
  Future<void> sendWelcomeEmail({
    required String teamId,
    required String userId,
    String? message,
  }) async {
    try {
      final data = <String, dynamic>{'user_id': userId};
      if (message != null) data['message'] = message;

      await _dio.post('/api/v4/teams/$teamId/send_welcome_email', data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Import team from other application
  Future<Map<String, dynamic>> importTeam({
    required String teamId,
    required Uint8List file,
    required String filesize,
    required String importFrom,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file, filename: 'import.zip'),
        'filesize': filesize,
        'importFrom': importFrom,
      });

      final response = await _dio.post(
        '/api/v4/teams/$teamId/import',
        data: formData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get team invite info
  Future<Map<String, String>> getInviteInfo(String inviteId) async {
    try {
      final response = await _dio.get('/api/v4/teams/invite/$inviteId');
      return {
        'name': response.data['name'] ?? '',
        'display_name': response.data['display_name'] ?? '',
        'description': response.data['description'] ?? '',
        'id': response.data['id'] ?? '',
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Search team members
  Future<List<MUser>> searchTeamMembers({
    required String teamId,
    String? term,
    String? timezone,
    bool? allowInactive,
    String? role,
    String? sort,
    int? page,
    int? perPage,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (term != null) data['term'] = term;
      if (timezone != null) data['timezone'] = timezone;
      if (allowInactive != null) data['allow_inactive'] = allowInactive;
      if (role != null) data['role'] = role;
      if (sort != null) data['sort'] = sort;
      if (page != null) data['page'] = page;
      if (perPage != null) data['per_page'] = perPage;

      final response = await _dio.post(
        '/api/v4/teams/$teamId/members/search',
        data: data,
      );
      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team scheme
  Future<MScheme> getTeamScheme(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/scheme');
      return MScheme.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get public teams
  Future<List<MTeam>> getPublicTeams({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
          'include_total_count': 'true',
        },
      );
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members with status
  Future<List<Map<String, dynamic>>> getTeamMembersWithStatus(
    String teamId, {
    int page = 0,
    int perPage = 60,
    String? sort,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get(
        '/api/v4/teams/$teamId/members',
        queryParameters: queryParams,
      );
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  /// Set team privacy
  Future<MTeam> setTeamPrivacy({
    required String teamId,
    required String privacy,
  }) async {
    try {
      final data = {'privacy': privacy};
      final response = await _dio.put(
        '/api/v4/teams/$teamId/privacy',
        data: data,
      );
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get team audit log
  Future<List<Map<String, dynamic>>> getTeamAudits(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/audits');
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  /// Check team membership
  Future<bool> checkTeamMembership(String teamId, String userId) async {
    try {
      await _dio.get('/api/v4/teams/$teamId/members/$userId');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get teams by IDs
  Future<List<MTeam>> getTeamsByIds(List<String> teamIds) async {
    try {
      final response = await _dio.post('/api/v4/teams/ids', data: teamIds);
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get filtered teams
  Future<List<MTeam>> getFilteredTeams({
    int page = 0,
    int perPage = 60,
    bool? excludePolicyConstrained,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (excludePolicyConstrained != null) {
        queryParams['exclude_policy_constrained'] = excludePolicyConstrained.toString();
      }
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v4/teams',
        queryParameters: queryParams,
      );
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team stats with insights
  Future<Map<String, dynamic>> getTeamInsights(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/top/team_insights');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members not in channel
  Future<List<MUser>> getTeamMembersNotInChannel({
    required String teamId,
    required String channelId,
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/channels/$channelId/members/not_in_channel',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams autocomplete
  Future<List<MTeam>> getTeamsAutocomplete({String? name}) async {
    try {
      final queryParams = <String, String>{};
      if (name != null) queryParams['name'] = name;

      final response = await _dio.get(
        '/api/v4/teams/autocomplete',
        queryParameters: queryParams,
      );
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
