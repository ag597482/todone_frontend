import '../constants/api_constants.dart';
import 'api_client.dart';
import 'api_result.dart';
import 'task_api_models.dart';

/// Tasks API: get tasks for user and update task status.
class TaskService {
  TaskService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// PUT /api/tasks/{taskId}/status with body { taskStatus: "COMPLETED"|"PENDING", userId }.
  Future<ApiResult<TaskModel>> updateTaskStatus(
    String taskId,
    String userId,
    String taskStatus,
  ) {
    final path = '${ApiConstants.updateTaskStatusPath}/$taskId/status';
    final body = {
      'taskStatus': taskStatus,
      'userId': userId,
    };
    return _client.put<TaskModel>(
      path,
      body,
      fromJson: TaskModel.fromJson,
    );
  }

  /// GET /api/tasks/{taskId}. Returns single task (same structure as list item).
  Future<ApiResult<TaskModel>> getTask(String taskId) {
    final path = '${ApiConstants.getTaskPath}/$taskId';
    return _client.get<TaskModel>(
      path,
      fromJson: TaskModel.fromJson,
    );
  }

  /// DELETE /api/tasks/{taskId}?userId=xxx.
  Future<ApiResult<Object?>> deleteTask(String taskId, String userId) {
    final path = '${ApiConstants.getTaskPath}/$taskId?userId=$userId';
    return _client.delete<Object?>(path);
  }

  /// PUT /api/tasks/{taskId}?userId=xxx.
  /// Body matches backend contract:
  /// {
  ///   "task_id": "...",
  ///   "name": "...",
  ///   "description": "...",
  ///   "meta": { "steps": [ { "value": "...", "completed": bool } ] },
  ///   "dueDate": "yyyy-MM-dd",
  ///   "doneDate": null | "yyyy-MM-dd",
  ///   "status": "PENDING" | "COMPLETED" | ...,
  ///   "authorId": "..."
  /// }
  Future<ApiResult<TaskModel>> updateTaskFull({
    required String taskId,
    required String userId,
    required String name,
    required String description,
    required List<SubtaskStep> steps,
    required String? dueDate,
    required String? doneDate,
    required String? status,
    required String authorId,
  }) {
    final path = '${ApiConstants.getTaskPath}/$taskId?userId=$userId';
    final body = <String, dynamic>{
      'task_id': taskId,
      'name': name,
      'description': description,
      'meta': {
        'steps': steps
            .map((s) => {
                  'value': s.value,
                  'completed': s.completed,
                })
            .toList(),
      },
      'authorId': authorId,
    };
    if (dueDate != null) {
      body['dueDate'] = dueDate;
    }
    // Allow passing explicit null to clear doneDate.
    if (doneDate != null) {
      body['doneDate'] = doneDate;
    } else {
      body['doneDate'] = null;
    }
    if (status != null) {
      body['status'] = status;
    }

    return _client.put<TaskModel>(
      path,
      body,
      fromJson: TaskModel.fromJson,
    );
  }

  /// PUT /api/tasks/{taskId}/subtask-status with body { userId, subtaskValue, completed }.
  /// Returns updated task with meta.steps reflecting the new completion state.
  Future<ApiResult<TaskModel>> updateSubtaskStatus(
    String taskId,
    String userId,
    String subtaskValue,
    bool completed,
  ) {
    final path = ApiConstants.subtaskStatusPath(taskId);
    final body = {
      'userId': userId,
      'subtaskValue': subtaskValue,
      'completed': completed,
    };
    return _client.put<TaskModel>(
      path,
      body,
      fromJson: TaskModel.fromJson,
    );
  }

  /// POST /api/tasks with body { name, description, meta?, dueDate, authorId }.
  /// dueDate format: yyyy-MM-dd.
  Future<ApiResult<TaskModel>> createTask(
    String authorId, {
    required String name,
    required String description,
    String? dueDate,
    Map<String, dynamic>? meta,
  }) {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'meta': meta ?? {},
      'authorId': authorId,
    };
    if (dueDate != null && dueDate.isNotEmpty) {
      body['dueDate'] = dueDate;
    }
    return _client.post<TaskModel>(
      ApiConstants.createTaskPath,
      body,
      fromJson: TaskModel.fromJson,
    );
  }

  /// GET /api/tasks/user/{userId} with optional [date] query (yyyy-MM-dd).
  /// Returns list of tasks from response data (same structure as Get All Tasks).
  Future<ApiResult<List<TaskModel>>> getTasksForUser(
    String userId, {
    DateTime? date,
  }) async {
    var path = '${ApiConstants.getTasksForUserPath}/$userId';
    if (date != null) {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      path = '$path?date=$dateStr';
    }
    return _client.get<List<TaskModel>>(
      path,
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => TaskModel.fromJson(e)).toList();
        }
        if (data is Map<String, dynamic> && data['tasks'] is List) {
          return (data['tasks'] as List).map((e) => TaskModel.fromJson(e)).toList();
        }
        return <TaskModel>[];
      },
    );
  }
}
