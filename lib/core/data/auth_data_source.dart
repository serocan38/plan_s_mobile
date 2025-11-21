import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../../models/user.dart';

abstract class IAuthDataSource {
  Future<ApiResponse<AuthResponse>> login(String email, String password);
  Future<ApiResponse<AuthResponse>> register(String email, String password);
  Future<ApiResponse<User>> getCurrentUser();
  Future<ApiResponse<void>> logout();
}

class AuthDataSource implements IAuthDataSource {
  final ApiClient _client;

  AuthDataSource(this._client);

  @override
  Future<ApiResponse<AuthResponse>> login(
    String email,
    String password,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.authLogin,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data!);
      
      if (authResponse.token != null) {
        await _client.saveToken(authResponse.token!);
      }
      
      return ApiResponse.success(authResponse);
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<AuthResponse>> register(
    String email,
    String password,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.authRegister,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data!);

      if (authResponse.token != null) {
        await _client.saveToken(authResponse.token!);
      }
      
      return ApiResponse.success(authResponse);
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.authMe,
    );

    if (response.isSuccess && response.data != null) {
      try {
        
        
        final userData = response.data!['user'];
        
        if (userData == null) {
          return ApiResponse.failure(
            ServerFailure(
              message: 'No user data in response',
              code: 'PARSE_ERROR',
            ),
          );
        }
        
        final user = User.fromJson(userData as Map<String, dynamic>);
        
        return ApiResponse.success(user);
      } catch (e) {
        
        
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse user data: $e',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<void>> logout() async {
    final response = await _client.post<void>(
      ApiConstants.authLogout,
    );

    if (response.isSuccess) {
      await _client.clearToken();
    }

    return response;
  }
}
