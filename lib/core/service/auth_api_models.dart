/// Request body for POST /api/auth/login/initiate
class LoginInitiateRequest {
  LoginInitiateRequest(this.phoneNumber);
  final String phoneNumber;

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}

/// Response data from login initiate (success)
class LoginInitiateResponse {
  LoginInitiateResponse({required this.sessionId, required this.message});

  final String sessionId;
  final String message;

  static LoginInitiateResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return LoginInitiateResponse(
      sessionId: map['sessionId'] as String,
      message: map['message'] as String? ?? 'OTP sent',
    );
  }
}

/// Request body for POST /api/auth/login/verify
class LoginVerifyRequest {
  LoginVerifyRequest(this.sessionId, this.otp);

  final String sessionId;
  final String otp;

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'otp': otp,
      };
}

/// Response data from login verify (success)
class LoginVerifyResponse {
  LoginVerifyResponse({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.metadata,
  });

  final String userId;
  final String name;
  final String phoneNumber;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'phoneNumber': phoneNumber,
        'metadata': metadata ?? {},
      };

  static LoginVerifyResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return LoginVerifyResponse(
      userId: map['user_id'] as String,
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
