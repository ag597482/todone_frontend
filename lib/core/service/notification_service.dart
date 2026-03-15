import '../constants/api_constants.dart';
import 'api_client.dart';
import 'api_result.dart';
import 'notification_api_models.dart';

/// Notifications API: list and update status.
class NotificationService {
  NotificationService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// GET /api/notifications/user/{userId}. Returns list of notifications.
  Future<ApiResult<List<NotificationModel>>> getNotifications(String userId) {
    final path = ApiConstants.notificationsForUserPath(userId);
    return _client.get<List<NotificationModel>>(
      path,
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => NotificationModel.fromJson(e)).toList();
        }
        return <NotificationModel>[];
      },
    );
  }

  /// DELETE /api/notifications/user/{userId}. Deletes all read notifications for the user.
  Future<ApiResult<Object?>> clearAllReadNotifications(String userId) {
    final path = ApiConstants.notificationsForUserPath(userId);
    return _client.delete<Object?>(path);
  }

  /// PATCH /api/notifications/{notificationId}/status with body { userId, notificationStatus }.
  Future<ApiResult<NotificationModel>> updateNotificationStatus(
    String notificationId,
    String userId,
    String notificationStatus,
  ) {
    final path = ApiConstants.notificationStatusPath(notificationId);
    return _client.patch<NotificationModel>(
      path,
      {
        'userId': userId,
        'notificationStatus': notificationStatus,
      },
      fromJson: NotificationModel.fromJson,
    );
  }
}
