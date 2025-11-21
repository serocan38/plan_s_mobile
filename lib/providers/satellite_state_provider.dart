import 'package:flutter/foundation.dart';
import '../core/data/satellite_data_source.dart';
import '../core/network/api_client.dart';
import '../core/errors/failures.dart';
import '../core/utils/error_message_mapper.dart';
import '../models/satellite.dart';

class SatelliteStateProvider with ChangeNotifier {
  final ISatelliteDataSource _satelliteDataSource;
  
  List<Satellite> _satellites = [];
  Satellite? _selectedSatellite;
  bool _isLoading = false;
  Failure? _failure;

  SatelliteStateProvider({
    ISatelliteDataSource? satelliteDataSource,
    ApiClient? apiClient,
  }) : _satelliteDataSource = 
           satelliteDataSource ?? SatelliteDataSource(apiClient ?? ApiClient());

  List<Satellite> get satellites => _satellites;
  Satellite? get selectedSatellite => _selectedSatellite;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get error => _failure != null
      ? ErrorMessageMapper.getReadableMessage(_failure!)
      : null;
  bool get isEmpty => _satellites.isEmpty;

  Future<void> loadSatellites() async {
    _setLoading(true);
    _failure = null;

    final response = await _satelliteDataSource.getAllSatellites();

    response.fold(
      onSuccess: (satellites) {
        _satellites = satellites;
        _failure = null;
        _setLoading(false);
      },
      onFailure: (failure) {
        _failure = failure;
        _setLoading(false);
      },
    );
  }

  Future<void> loadSatelliteById(String id) async {
    _setLoading(true);
    _failure = null;

    final response = await _satelliteDataSource.getSatelliteById(id);

    response.fold(
      onSuccess: (satellite) {
        _selectedSatellite = satellite;
        _failure = null;
        _setLoading(false);
      },
      onFailure: (failure) {
        _failure = failure;
        _setLoading(false);
      },
    );
  }

  Future<bool> createSatellite({
    required String noradId,
    required String name,
    Map<String, dynamic>? tle,
  }) async {
    _setLoading(true);
    _failure = null;

    final response = await _satelliteDataSource.createSatellite(
      noradId: noradId,
      name: name,
      tle: tle,
    );

    return response.fold(
      onSuccess: (satellite) {
        _satellites.add(satellite);
        _failure = null;
        _setLoading(false);
        return true;
      },
      onFailure: (failure) {
        _failure = failure;
        _setLoading(false);
        return false;
      },
    );
  }

  Future<bool> updateSatelliteName({
    required String id,
    required String name,
  }) async {
    _setLoading(true);
    _failure = null;

    final response = await _satelliteDataSource.updateSatelliteName(
      id: id,
      name: name,
    );

    return response.fold(
      onSuccess: (satellite) {
        final index = _satellites.indexWhere((s) => s.id == id);
        if (index != -1) {
          _satellites[index] = satellite;
        }
        if (_selectedSatellite?.id == id) {
          _selectedSatellite = satellite;
        }
        _failure = null;
        _setLoading(false);
        return true;
      },
      onFailure: (failure) {
        _failure = failure;
        _setLoading(false);
        return false;
      },
    );
  }

  Future<bool> refreshTLE(String id) async {
    _setLoading(true);
    _failure = null;

    final response = await _satelliteDataSource.refreshTLE(id);

    return response.fold(
      onSuccess: (satellite) {
        final index = _satellites.indexWhere((s) => s.id == id);
        if (index != -1) {
          _satellites[index] = satellite;
        }
        if (_selectedSatellite?.id == id) {
          _selectedSatellite = satellite;
        }
        _failure = null;
        _setLoading(false);
        return true;
      },
      onFailure: (failure) {
        _failure = failure;
        _setLoading(false);
        return false;
      },
    );
  }

  Future<bool> deleteSatellite(String id) async {
    _setLoading(true);
    _failure = null;

    final response = await _satelliteDataSource.deleteSatellite(id);

    return response.fold(
      onSuccess: (_) {
        _satellites.removeWhere((s) => s.id == id);
        if (_selectedSatellite?.id == id) {
          _selectedSatellite = null;
        }
        _failure = null;
        _setLoading(false);
        return true;
      },
      onFailure: (failure) {
        _failure = failure;
        _setLoading(false);
        return false;
      },
    );
  }

  void selectSatellite(Satellite satellite) {
    _selectedSatellite = satellite;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSatellite = null;
    notifyListeners();
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
