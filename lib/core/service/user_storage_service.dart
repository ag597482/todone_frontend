import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_api_models.dart';

const String _userDataKey = 'user_data';

/// Persists and reads the logged-in user (from login verify) in local storage.
class UserStorageService {
  /// Saves user after successful OTP verification.
  Future<void> saveUser(LoginVerifyResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
  }

  /// Returns the stored user, or null if none.
  Future<LoginVerifyResponse?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userDataKey);
    if (json == null || json.isEmpty) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LoginVerifyResponse.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Removes stored user (e.g. on logout).
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  /// True if user data exists in storage.
  Future<bool> hasUser() async {
    final user = await getUser();
    return user != null;
  }
}
