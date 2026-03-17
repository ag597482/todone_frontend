import 'dart:convert';

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
    var title = (map['notification_title'] ?? '').toString();
    var description = (map['notification_desc'] ?? '').toString();

    // Some notifications embed a JSON payload as the description:
    // {
    //   "title": "...",
    //   "body": "..."
    // }
    // Try to parse and extract a nicer title/body when present.
    if (description.trim().startsWith('{') && description.trim().endsWith('}')) {
      try {
        final dynamic decoded = jsonDecode(description);
        if (decoded is Map<String, dynamic>) {
          final innerTitle = decoded['title']?.toString();
          final innerBody = decoded['body']?.toString();
          if (innerTitle != null && innerTitle.isNotEmpty) {
            title = innerTitle;
          }
          if (innerBody != null && innerBody.isNotEmpty) {
            description = innerBody;
          }
        }
      } catch (_) {
        // Ignore parse errors and keep original description.
      }
    }

    return NotificationModel(
      id: map['notification_id']?.toString() ?? '',
      title: title,
      description: description,
      targetedUser: (map['targeted_user'] ?? '').toString(),
      time: (map['notification_time'] ?? '').toString(),
      status: (map['notification_status'] ?? '').toString(),
    );
  }
}
