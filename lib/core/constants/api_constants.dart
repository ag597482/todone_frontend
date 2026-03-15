class ApiConstants {
  // Default base URL when none is stored (used by BaseUrlService)
  static const String defaultBaseUrl = 'https://todone-todone.up.railway.app';

  // Fallback / legacy (prefer defaultBaseUrl + BaseUrlService for runtime URL)
  static const String baseUrl = 'http://localhost:8080';

  // Auth - login flow
  static const String loginInitiatePath = '/api/auth/login/initiate';
  static const String loginVerifyPath = '/api/auth/login/verify';

  // Endpoints - Auth (legacy, if needed)
  static const String sendOTPEndpoint = '/auth/send-otp';
  static const String verifyOTPEndpoint = '/auth/verify-otp';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';

  // Endpoints - User
  static const String getUserEndpoint = '/user/profile';
  static const String updateUserEndpoint = '/user/profile';
  /// GET /api/users/{userId}/profile — returns user, tasks, completedTasksCount, pendingTasksCount
  static String userProfilePath(String userId) => '/api/users/$userId/profile';
  /// PUT /api/users/{userId} — body: { name }
  static String updateUserPath(String userId) => '/api/users/$userId';
  /// PATCH /api/users/{userId}/telegram — body: { telegramToken }
  static String userTelegramPath(String userId) => '/api/users/$userId/telegram';

  // Endpoints - Tasks
  static const String getTasksEndpoint = '/tasks';
  static const String getTasksForUserPath = '/api/tasks/user'; // append /{userId}?date=yyyy-MM-dd
  static const String updateTaskStatusPath = '/api/tasks'; // append /{taskId}/status or /{taskId} for GET/DELETE
  static const String getTaskPath = '/api/tasks'; // append /{taskId} for GET, /{taskId}?userId= for DELETE
  static const String createTaskPath = '/api/tasks'; // POST
  // PUT /api/tasks/{taskId}/subtask-status — body: userId, subtaskValue, completed
  static String subtaskStatusPath(String taskId) => '$getTaskPath/$taskId/subtask-status';
  static const String createTaskEndpoint = '/tasks';
  static const String updateTaskEndpoint = '/tasks/:id';
  static const String deleteTaskEndpoint = '/tasks/:id';

  // Endpoints - Notifications
  static const String getNotificationsEndpoint = '/notifications';
  static const String markNotificationReadEndpoint = '/notifications/:id/read';
  /// GET /api/notifications/user/{userId}
  static String notificationsForUserPath(String userId) => '/api/notifications/user/$userId';
  /// PATCH /api/notifications/{notificationId}/status — body: userId, notificationStatus
  static String notificationStatusPath(String notificationId) => '/api/notifications/$notificationId/status';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
