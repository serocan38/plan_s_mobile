import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import 'api_response.dart';

class ApiClient {
  final http.Client _client;
  final FlutterSecureStorage _storage;
  
  ApiClient({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: ApiConstants.storageKeyToken);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);
      
      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri 
      = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .post(
            uri,
            headers: await _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .put(
            uri,
            headers: await _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .patch(
            uri,
            headers: await _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .delete(uri, headers: await _getHeaders())
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final body = response.body.isEmpty ? '{}' : response.body;
      final data = jsonDecode(body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null) {
          try {
            final parsedData = fromJson(data);
            return ApiResponse.success(parsedData);
          } catch (e) {
            return ApiResponse.failure(
              ServerFailure(
                message: 'Failed to parse response data',
                code: 'PARSE_ERROR',
              ),
            );
          }
        }
        if (data == null || (data is Map && data.isEmpty)) {
          return ApiResponse.success(null as T);
        }
        return ApiResponse.success(data as T);
      } else {
        final message = data is Map ? (data['message'] ?? 'An error occurred') : 'An error occurred';
        final code = response.statusCode.toString();
        
        Failure failure;
        
        switch (response.statusCode) {
          case 400:
            failure = ValidationFailure(message: message, code: code);
            break;
          case 401:
            failure = UnauthorizedFailure(message: message, code: code);
            break;
          case 403:
            failure = AuthenticationFailure(message: message, code: code);
            break;
          case 404:
            failure = NotFoundFailure(message: message, code: code);
            break;
          case 409:
            failure = ConflictFailure(message: message, code: code);
            break;
          case 500:
          case 502:
          case 503:
            failure = ServerFailure(message: message, code: code);
            break;
          default:
            failure = ServerFailure(message: message, code: code);
        }
        
        return ApiResponse.failure(failure);
      }
    } catch (e) {
      return ApiResponse.failure(
        ServerFailure(
          message: 'Failed to process server response',
          code: 'RESPONSE_ERROR',
        ),
      );
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return ApiResponse.failure(
        const NetworkFailure(message: 'Request timeout'),
      );
    }
    
    return ApiResponse.failure(
      NetworkFailure(message: error.toString()),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.storageKeyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.storageKeyToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: ApiConstants.storageKeyToken);
  }

  void dispose() {
    _client.close();
  }
}
