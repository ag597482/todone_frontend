import '../constants/api_constants.dart';
import 'api_client.dart';
import 'api_result.dart';
import 'task_group_api_models.dart';

class TaskGroupService {
  TaskGroupService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// GET /api/task-groups?userId=...
  Future<ApiResult<List<TaskGroupModel>>> getTaskGroups(String userId) {
    final path = ApiConstants.taskGroupsForUserQuery(userId);
    return _client.get<List<TaskGroupModel>>(
      path,
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => TaskGroupModel.fromJson(e)).toList();
        }
        return <TaskGroupModel>[];
      },
    );
  }

  /// POST /api/task-groups — body { name, authorId }
  Future<ApiResult<TaskGroupModel>> createTaskGroup({
    required String name,
    required String authorId,
  }) {
    final body = <String, dynamic>{'name': name, 'authorId': authorId};
    return _client.post<TaskGroupModel>(
      ApiConstants.taskGroupsPath,
      body,
      fromJson: TaskGroupModel.fromJson,
    );
  }

  /// PUT /api/task-groups/{taskGroupId}?userId=... body: { name }
  Future<ApiResult<TaskGroupModel>> updateTaskGroup({
    required String taskGroupId,
    required String name,
    required String userId,
  }) {
    final path =
        '${ApiConstants.taskGroupByIdPath(taskGroupId)}?userId=$userId';
    final body = <String, dynamic>{'name': name};
    return _client.put<TaskGroupModel>(
      path,
      body,
      fromJson: TaskGroupModel.fromJson,
    );
  }

  /// DELETE /api/task-groups/{taskGroupId}?userId=...
  Future<ApiResult<Object?>> deleteTaskGroup({
    required String taskGroupId,
    required String userId,
  }) {
    final path =
        '${ApiConstants.taskGroupByIdPath(taskGroupId)}?userId=$userId';
    return _client.delete<Object?>(path);
  }
}
