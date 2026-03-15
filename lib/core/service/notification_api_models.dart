/// Single notification from GET /api/notifications/user/{userId} response (data item).
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetedUser,
    required this.time,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String targetedUser;
  final String time;
  final String status;

  static NotificationModel fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map);
    return NotificationModel(
      id: map['notification_id']?.toString() ?? '',
      title: (map['notification_title'] ?? '').toString(),
      description: (map['notification_desc'] ?? '').toString(),
      targetedUser: (map['targeted_user'] ?? '').toString(),
      time: (map['notification_time'] ?? '').toString(),
      status: (map['notification_status'] ?? '').toString(),
    );
  }
}
