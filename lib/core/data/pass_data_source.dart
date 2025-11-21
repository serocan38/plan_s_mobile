import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../../models/pass_prediction.dart';

abstract class IPassDataSource {
  Future<ApiResponse<List<PassPrediction>>> predictPasses({
    required String noradId,
    required GroundLocation groundLocation,
    DateTime? startTime,
    double? minElevation,
    int? maxPasses,
    int? searchHours,
  });
  
  Future<ApiResponse<PassPrediction?>> predictNextPass({
    required String noradId,
    required GroundLocation groundLocation,
    DateTime? startTime,
    double? minElevation,
    int? searchHours,
  });
  
  Future<ApiResponse<SatellitePosition>> getSatellitePosition({
    required String noradId,
    Map<String, dynamic>? tle,
    DateTime? time,
  });
}

class PassDataSource implements IPassDataSource {
  final ApiClient _client;

  PassDataSource(this._client);

  @override
  Future<ApiResponse<List<PassPrediction>>> predictPasses({
    required String noradId,
    required GroundLocation groundLocation,
    DateTime? startTime,
    double? minElevation,
    int? maxPasses,
    int? searchHours,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.passesPredict,
      body: {
        'noradId': noradId,
        'groundLocation': groundLocation.toJson(),
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (minElevation != null) 'minElevation': minElevation,
        if (maxPasses != null) 'maxPasses': maxPasses,
        if (searchHours != null) 'searchHours': searchHours,
      },
    );

    if (response.isSuccess && response.data != null) {
      try {
        final passesData = response.data!['passes'];
        if (passesData == null) {
          return ApiResponse.success([]);
        }
        
        if (passesData is! List) {
          return ApiResponse.failure(
            ServerFailure(
              message: 'Invalid response format: expected list of passes',
              code: 'PARSE_ERROR',
            ),
          );
        }
        
        final passes = passesData
            .map((json) {
              return PassPrediction.fromJson(json as Map<String, dynamic>);
            })
            .toList();
        
        return ApiResponse.success(passes);
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse pass predictions: $e',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<PassPrediction?>> predictNextPass({
    required String noradId,
    required GroundLocation groundLocation,
    DateTime? startTime,
    double? minElevation,
    int? searchHours,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.passesNext,
      body: {
        'noradId': noradId,
        'groundLocation': groundLocation.toJson(),
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (minElevation != null) 'minElevation': minElevation,
        if (searchHours != null) 'searchHours': searchHours,
      },
    );

    if (response.isSuccess && response.data != null) {
      try {
        
        
        final passData = response.data!['pass'];
        
        if (passData == null) {
          
          return ApiResponse.success(null);
        }
        
        final pass = PassPrediction.fromJson(passData as Map<String, dynamic>);
        
        return ApiResponse.success(pass);
      } catch (e) {
        
        
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse pass prediction: $e',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<SatellitePosition>> getSatellitePosition({
    required String noradId,
    Map<String, dynamic>? tle,
    DateTime? time,
  }) async {
    Map<String, dynamic>? formattedTle;
    if (tle != null) {
      formattedTle = {
        'line1': tle['line1'],
        'line2': tle['line2'],
        'epoch': tle['epoch'], 
      };
    }
    
    final body = {
      'noradId': noradId,
      if (formattedTle != null) 'tle': formattedTle,
      if (time != null) 'time': time.toUtc().toIso8601String(),
    };
    
    
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.passesPosition,
      body: body,
    );

    if (response.isSuccess && response.data != null) {
      try {
        
        final positionData = response.data!['position'];
        
        if (positionData == null) {
          return ApiResponse.failure(
            ServerFailure(
              message: 'No position data in response',
              code: 'PARSE_ERROR',
            ),
          );
        }
        
        final position = SatellitePosition.fromJson(positionData as Map<String, dynamic>);
        
        return ApiResponse.success(position);
      } catch (e) {
        
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellite position: $e',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }
}
