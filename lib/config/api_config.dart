class ApiConfig {
  static const String baseUrl = 'http://localhost:3001/api';
  
  static const String wsUrl = 'http://localhost:3001';
  
  static const String satellitesEndpoint = '/satellites';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const bool autoConnect = true;
  static const int reconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);
  
  static String getPlatformBaseUrl() {
    return baseUrl;
  }
  
  static String getPlatformWsUrl() {
    return wsUrl;
  }
}
