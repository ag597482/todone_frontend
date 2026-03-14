class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.todone.app/v1';

  // Endpoints - Auth
  static const String sendOTPEndpoint = '/auth/send-otp';
  static const String verifyOTPEndpoint = '/auth/verify-otp';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';

  // Endpoints - User
  static const String getUserEndpoint = '/user/profile';
  static const String updateUserEndpoint = '/user/profile';

  // Endpoints - Tasks
  static const String getTasksEndpoint = '/tasks';
  static const String createTaskEndpoint = '/tasks';
  static const String updateTaskEndpoint = '/tasks/:id';
  static const String deleteTaskEndpoint = '/tasks/:id';

  // Endpoints - Notifications
  static const String getNotificationsEndpoint = '/notifications';
  static const String markNotificationReadEndpoint = '/notifications/:id/read';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
