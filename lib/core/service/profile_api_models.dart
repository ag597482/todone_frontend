import 'task_api_models.dart';

/// User summary from GET /api/users/{userId}/profile response (data.user).
class ProfileUser {
  const ProfileUser({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.metadata,
  });

  final String userId;
  final String name;
  final String phoneNumber;
  final Map<String, dynamic>? metadata;

  static ProfileUser fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    return ProfileUser(
      userId: map['user_id']?.toString() ?? '',
      name: (map['name'] ?? '').toString().trim(),
      phoneNumber: (map['phoneNumber'] ?? map['phone_number'] ?? '').toString(),
      metadata: map['metadata'] is Map ? Map<String, dynamic>.from(map['metadata'] as Map) : null,
    );
  }
}

/// Response data from GET /api/users/{userId}/profile (data).
class UserProfileData {
  const UserProfileData({
    required this.user,
    required this.completedTasksCount,
    required this.pendingTasksCount,
    this.tasks = const [],
  });

  final ProfileUser user;
  final int completedTasksCount;
  final int pendingTasksCount;
  final List<TaskModel> tasks;

  static UserProfileData fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    final tasksList = map['tasks'];
    final List<TaskModel> taskModels = [];
    if (tasksList is List) {
      for (final e in tasksList) {
        taskModels.add(TaskModel.fromJson(e));
      }
    }
    return UserProfileData(
      user: ProfileUser.fromJson(map['user'] ?? {}),
      completedTasksCount: (map['completedTasksCount'] ?? map['completed_tasks_count'] ?? 0) as int,
      pendingTasksCount: (map['pendingTasksCount'] ?? map['pending_tasks_count'] ?? 0) as int,
      tasks: taskModels,
    );
  }
}
