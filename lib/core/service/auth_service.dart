import '../constants/api_constants.dart';
import 'api_client.dart';
import 'api_result.dart';
import 'auth_api_models.dart';

/// Auth API: login initiate (send OTP) and login verify (verify OTP).
class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Start login: send OTP to [phoneNumber]. Returns sessionId on success.
  Future<ApiResult<LoginInitiateResponse>> loginInitiate(String phoneNumber) {
    final body = LoginInitiateRequest(phoneNumber).toJson();
    return _client.post<LoginInitiateResponse>(
      ApiConstants.loginInitiatePath,
      body,
      fromJson: LoginInitiateResponse.fromJson,
    );
  }

  /// Verify OTP for [sessionId] with [otp]. Returns user data on success.
  Future<ApiResult<LoginVerifyResponse>> loginVerify(
    String sessionId,
    String otp,
  ) {
    final body = LoginVerifyRequest(sessionId, otp).toJson();
    return _client.post<LoginVerifyResponse>(
      ApiConstants.loginVerifyPath,
      body,
      fromJson: LoginVerifyResponse.fromJson,
    );
  }
}
