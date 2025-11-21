class ApiConstants {
  ApiConstants._();
  
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/api',
  );
  
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'http://localhost:3001',
  );
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  
  static const String catalog = '/catalog';
  static String catalogById(String noradId) => '/catalog/$noradId';
  
  static const String satellites = '/satellites';
  static String satelliteById(String id) => '/satellites/$id';
  static String satelliteRefresh(String id) => '/satellites/$id/refresh';

  static const String passesPredict = '/passes/predict';
  static const String passesNext = '/passes/next';
  static const String passesPosition = '/passes/position';
  
  static const String wsEventSatelliteAdded = 'satellite:added';
  static const String wsEventSatelliteUpdated = 'satellite:updated';
  static const String wsEventSatelliteDeleted = 'satellite:deleted';
  
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'user_data';
  
  static const int noradIdLength = 5;
  static const int passwordMinLength = 6;
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;
  static const double minElevation = 0.0;
  static const double maxElevation = 90.0;
}
