import '../constants/api_constants.dart';
import 'api_client.dart';
import 'api_result.dart';
import 'profile_api_models.dart';

/// User profile and update APIs.
class UserService {
  UserService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// GET /api/users/{userId}/profile — returns user, completedTasksCount, pendingTasksCount.
  Future<ApiResult<UserProfileData>> getProfile(String userId) {
    final path = ApiConstants.userProfilePath(userId);
    return _client.get<UserProfileData>(
      path,
      fromJson: UserProfileData.fromJson,
    );
  }

  /// PUT /api/users/{userId} with body { name }. Returns success; refetch profile for updated data.
  Future<ApiResult<Object?>> updateUserName(String userId, String name) async {
    final path = ApiConstants.updateUserPath(userId);
    return _client.put<Object?>(
      path,
      {'name': name.trim()},
      fromJson: (_) => null,
    );
  }
}
