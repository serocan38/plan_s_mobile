import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../../models/satellite.dart';

abstract class ISatelliteDataSource {
  Future<ApiResponse<List<Satellite>>> getAllSatellites();
  Future<ApiResponse<Satellite>> getSatelliteById(String id);
  Future<ApiResponse<Satellite>> createSatellite({
    required String noradId,
    required String name,
    Map<String, dynamic>? tle,
  });
  Future<ApiResponse<Satellite>> updateSatelliteName({
    required String id,
    required String name,
  });
  Future<ApiResponse<Satellite>> refreshTLE(String id);
  Future<ApiResponse<void>> deleteSatellite(String id);
}

class SatelliteDataSource implements ISatelliteDataSource {
  final ApiClient _client;

  SatelliteDataSource(this._client);

  @override
  Future<ApiResponse<List<Satellite>>> getAllSatellites() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.satellites,
    );

    if (response.isSuccess && response.data != null) {
      try {
        final data = response.data!['satellites'];
        
        if (data == null) {
          return ApiResponse.success([]);
        }
        
        if (data is! List) {
          return ApiResponse.failure(
            ServerFailure(
              message: 'Invalid response format',
              code: 'PARSE_ERROR',
            ),
          );
        }
        
        final satellites = data
            .map((json) => Satellite.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(satellites);
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellites: $e',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<Satellite>> getSatelliteById(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.satelliteById(id),
    );

    if (response.isSuccess && response.data != null) {
      try {
        return ApiResponse.success(Satellite.fromJson(response.data!));
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellite data',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<Satellite>> createSatellite({
    required String noradId,
    required String name,
    Map<String, dynamic>? tle,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.satellites,
      body: {
        'noradId': noradId,
        'name': name,
        if (tle != null) 'tle': tle,
      },
    );

    if (response.isSuccess && response.data != null) {
      try {
        return ApiResponse.success(Satellite.fromJson(response.data!));
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellite data',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<Satellite>> updateSatelliteName({
    required String id,
    required String name,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      ApiConstants.satelliteById(id),
      body: {'name': name},
    );

    if (response.isSuccess && response.data != null) {
      try {
        return ApiResponse.success(Satellite.fromJson(response.data!));
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellite data',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<Satellite>> refreshTLE(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.satelliteRefresh(id),
    );

    if (response.isSuccess && response.data != null) {
      try {
        return ApiResponse.success(Satellite.fromJson(response.data!));
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellite data',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<void>> deleteSatellite(String id) async {
    return await _client.delete<void>(
      ApiConstants.satelliteById(id),
    );
  }
}
