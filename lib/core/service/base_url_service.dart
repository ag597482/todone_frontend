import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

const String _baseUrlKey = 'api_base_url';

/// Reads and writes the API base URL to local storage. Used by [ApiClient] for all requests.
class BaseUrlService {
  /// Returns the stored base URL, or [ApiConstants.defaultBaseUrl] if none set.
  /// Normalized (no trailing slash).
  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_baseUrlKey);
    if (stored == null || stored.isEmpty) {
      return _normalize(ApiConstants.defaultBaseUrl);
    }
    return _normalize(stored);
  }

  /// Saves the base URL (trimmed, trailing slash removed). Used by all API calls.
  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _normalize(url));
  }

  static String _normalize(String url) {
    url = url.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
}
