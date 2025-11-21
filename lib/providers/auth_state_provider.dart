import 'package:flutter/foundation.dart';
import '../core/data/auth_data_source.dart';
import '../core/network/api_client.dart';
import '../core/errors/failures.dart';
import '../core/utils/error_message_mapper.dart';
import '../models/user.dart';

class AuthStateProvider with ChangeNotifier {
  final IAuthDataSource _authDataSource;
  
  User? _user;
  bool _isLoading = false;
  Failure? _failure;
  bool _isAuthenticated = false;

  AuthStateProvider({
    IAuthDataSource? authDataSource,
    ApiClient? apiClient,
  }) : _authDataSource = authDataSource ?? AuthDataSource(apiClient ?? ApiClient()) {
    _initialize();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get error => _failure != null 
      ? ErrorMessageMapper.getReadableMessage(_failure!)
      : null;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> _initialize() async {
    _setLoading(true);
    
    final response = await _authDataSource.getCurrentUser();
    
    response.fold(
      onSuccess: (user) {
        _user = user;
        _isAuthenticated = true;
        _failure = null;
      },
      onFailure: (failure) {
        _user = null;
        _isAuthenticated = false;
        _failure = null; 
      },
    );
    
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _failure = null;

    final response = await _authDataSource.login(email, password);

    return response.fold(
      onSuccess: (authResponse) {
        if (authResponse.user != null) {
          _user = authResponse.user;
          _isAuthenticated = true;
          _failure = null;
          _setLoading(false);
          return true;
        } else {
          _failure = const AuthenticationFailure(message: 'Login failed');
          _setLoading(false);
          return false;
        }
      },
      onFailure: (failure) {
        _failure = failure;
        _isAuthenticated = false;
        _setLoading(false);
        return false;
      },
    );
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _failure = null;

    final response = await _authDataSource.register(email, password);

    return response.fold(
      onSuccess: (authResponse) {
        if (authResponse.user != null) {
          _user = authResponse.user;
          _isAuthenticated = true;
          _failure = null;
          _setLoading(false);
          return true;
        } else {
          _failure = const AuthenticationFailure(message: 'Registration failed');
          _setLoading(false);
          return false;
        }
      },
      onFailure: (failure) {
        _failure = failure;
        _isAuthenticated = false;
        _setLoading(false);
        return false;
      },
    );
  }

  Future<void> logout() async {
    _setLoading(true);

    await _authDataSource.logout();

    _user = null;
    _isAuthenticated = false;
    _failure = null;
    _setLoading(false);
  }

  Future<void> refreshUser() async {
    final response = await _authDataSource.getCurrentUser();

    response.fold(
      onSuccess: (user) {
        _user = user;
        notifyListeners();
      },
      onFailure: (_) { },
    );
  }

  void clearError() {
    _failure = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
