import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../../models/satellite.dart';

abstract class ICatalogDataSource {
  Future<ApiResponse<List<CatalogSatellite>>> searchCatalog(String? query);
  Future<ApiResponse<CatalogSatellite>> getCatalogSatellite(String noradId);
}

class CatalogDataSource implements ICatalogDataSource {
  final ApiClient _api;

  CatalogDataSource(this._api);

  @override
  Future<ApiResponse<List<CatalogSatellite>>> searchCatalog(String? query) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConstants.catalog,
      queryParameters: query != null ? {'search': query} : null,
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
        
        final result = data
            .map((json) => CatalogSatellite.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(result);
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse catalog: $e',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  @override
  Future<ApiResponse<CatalogSatellite>> getCatalogSatellite(String noradId) async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiConstants.catalogById(noradId),
    );

    if (response.isSuccess && response.data != null) {
      try {
        return ApiResponse.success(
          CatalogSatellite.fromJson(response.data!['satellite']),
        );
      } catch (e) {
        return ApiResponse.failure(
          ServerFailure(
            message: 'Failed to parse satellite',
            code: 'PARSE_ERROR',
          ),
        );
      }
    }

    return ApiResponse.failure(response.failure!);
  }
}

class CatalogSatellite {
  final String noradId;
  final String name;
  final TLE? tle;
  final String? objectType;
  final String? launchDate;
  final String? country;

  CatalogSatellite({
    required this.noradId,
    required this.name,
    this.tle,
    this.objectType,
    this.launchDate,
    this.country,
  });

  factory CatalogSatellite.fromJson(Map<String, dynamic> json) {
    return CatalogSatellite(
      noradId: json['noradId'] as String,
      name: json['name'] as String,
      tle: json['tle'] != null ? TLE.fromJson(json['tle']) : null,
      objectType: json['objectType'] as String?,
      launchDate: json['launchDate'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noradId': noradId,
      'name': name,
      if (tle != null) 'tle': tle!.toJson(),
      if (objectType != null) 'objectType': objectType,
      if (launchDate != null) 'launchDate': launchDate,
      if (country != null) 'country': country,
    };
  }
}
