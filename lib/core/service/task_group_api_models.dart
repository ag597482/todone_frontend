/// Task group from GET /api/task-groups and POST /api/task-groups (data).
class TaskGroupModel {
  const TaskGroupModel({
    required this.taskGroupId,
    required this.name,
    required this.userId,
  });

  final String taskGroupId;
  final String name;
  final String userId;

  static TaskGroupModel fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    return TaskGroupModel(
      taskGroupId: map['task_group_id']?.toString() ?? map['taskGroupId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? map['userId']?.toString() ?? map['authorId']?.toString() ?? '',
    );
  }
}
