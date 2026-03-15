import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'api_result.dart';
import 'base_url_service.dart';

/// Generic API client using base URL from [BaseUrlService] (local storage) for all requests.
class ApiClient {
  ApiClient({BaseUrlService? baseUrlService})
      : _baseUrlService = baseUrlService ?? BaseUrlService(),
        _client = http.Client();

  final BaseUrlService _baseUrlService;
  final http.Client _client;

  /// POST [path] with [body] as JSON. [path] is appended to base URL from storage.
  /// If [fromJson] is provided and response has success==true and data, maps data to T.
  /// Otherwise returns ApiFailure with message from response or a generic error.
  Future<ApiResult<T>> post<T>(
    String path,
    Map<String, dynamic> body, {
    T Function(dynamic)? fromJson,
  }) async {
    final baseUrl = await _baseUrlService.getBaseUrl();
    final uri = Uri.parse(baseUrl + path);
    final bodyBytes = utf8.encode(jsonEncode(body));
    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': ApiConstants.contentType,
              'Accept': '*/*',
            },
            body: bodyBytes,
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () => throw Exception('Connection timeout'),
          );

      final decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>?)
          : null;

      final success = decoded?['success'] == true;
      final message = decoded?['message'] as String? ?? 'Request failed';
      final data = decoded?['data'];

      if (success && data != null) {
        if (fromJson != null) {
          return ApiSuccess(fromJson(data));
        }
        return ApiSuccess(data as T);
      }

      return ApiFailure(
        message,
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return ApiFailure(msg.contains('timeout') ? 'Connection timeout' : msg);
    }
  }

  /// PUT [path] with [body] as JSON.
  Future<ApiResult<T>> put<T>(
    String path,
    Map<String, dynamic> body, {
    T Function(dynamic)? fromJson,
  }) async {
    final baseUrl = await _baseUrlService.getBaseUrl();
    final uri = Uri.parse(baseUrl + path);
    final bodyBytes = utf8.encode(jsonEncode(body));
    try {
      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': ApiConstants.contentType,
              'Accept': '*/*',
            },
            body: bodyBytes,
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () => throw Exception('Connection timeout'),
          );

      final decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>?)
          : null;

      final success = decoded?['success'] == true;
      final message = decoded?['message'] as String? ?? 'Request failed';
      final data = decoded?['data'];

      if (success && data != null) {
        if (fromJson != null) {
          return ApiSuccess(fromJson(data));
        }
        return ApiSuccess(data as T);
      }

      return ApiFailure(
        message,
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return ApiFailure(msg.contains('timeout') ? 'Connection timeout' : msg);
    }
  }

  /// GET [path]. Optional [fromJson] to map response data to T.
  Future<ApiResult<T>> get<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    final baseUrl = await _baseUrlService.getBaseUrl();
    final uri = Uri.parse(baseUrl + path);
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': ApiConstants.contentType,
            },
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () => throw Exception('Connection timeout'),
          );

      final decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>?)
          : null;

      final success = decoded?['success'] == true;
      final message = decoded?['message'] as String? ?? 'Request failed';
      final data = decoded?['data'];

      if (success && data != null) {
        if (fromJson != null) {
          return ApiSuccess(fromJson(data));
        }
        return ApiSuccess(data as T);
      }

      return ApiFailure(
        message,
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return ApiFailure(msg.contains('timeout') ? 'Connection timeout' : msg);
    }
  }

  /// DELETE [path]. Response data may be null (e.g. task delete returns data: null).
  Future<ApiResult<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    final baseUrl = await _baseUrlService.getBaseUrl();
    final uri = Uri.parse(baseUrl + path);
    try {
      final response = await _client
          .delete(
            uri,
            headers: {
              'Accept': ApiConstants.contentType,
            },
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () => throw Exception('Connection timeout'),
          );

      final decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>?)
          : null;

      final success = decoded?['success'] == true;
      final message = decoded?['message'] as String? ?? 'Request failed';
      final data = decoded?['data'];

      if (success) {
        if (data != null && fromJson != null) {
          return ApiSuccess(fromJson(data));
        }
        return ApiSuccess(data as T);
      }

      return ApiFailure(
        message,
        statusCode: response.statusCode,
      );
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return ApiFailure(msg.contains('timeout') ? 'Connection timeout' : msg);
    }
  }
}
