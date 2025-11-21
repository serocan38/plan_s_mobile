import 'package:flutter/foundation.dart';
import '../core/data/pass_data_source.dart';
import '../core/network/api_client.dart';
import '../core/errors/failures.dart';
import '../core/utils/error_message_mapper.dart';
import '../models/pass_prediction.dart';
 
class PassStateProvider with ChangeNotifier {
  final IPassDataSource _passDataSource;
  
  List<PassPrediction> _passes = [];
  PassPrediction? _nextPass;
  SatellitePosition? _currentPosition;
  bool _isLoading = false;
  Failure? _failure;

  PassStateProvider({
    IPassDataSource? passDataSource,
    ApiClient? apiClient,
  }) : _passDataSource = passDataSource ?? PassDataSource(apiClient ?? ApiClient());

  List<PassPrediction> get passes => _passes;
  PassPrediction? get nextPass => _nextPass;
  SatellitePosition? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get error => _failure != null
      ? ErrorMessageMapper.getReadableMessage(_failure!)
      : null;
  bool get isEmpty => _passes.isEmpty;

  Future<void> predictPasses({
    required String noradId,
    required GroundLocation groundLocation,
    DateTime? startTime,
    double? minElevation,
    int? maxPasses,
    int? searchHours,
  }) async {
    _setLoading(true);
    _failure = null;

    final response = await _passDataSource.predictPasses(
      noradId: noradId,
      groundLocation: groundLocation,
      startTime: startTime,
      minElevation: minElevation,
      maxPasses: maxPasses,
      searchHours: searchHours,
    );

    response.fold(
      onSuccess: (passes) {
        _passes = passes;
        _failure = null;
        _isLoading = false;
        notifyListeners(); 
      },
      onFailure: (failure) {
        _failure = failure;
        _passes = []; 
        _isLoading = false;
        notifyListeners(); 
      },
    );
  }

  Future<void> predictNextPass({
    required String noradId,
    required GroundLocation groundLocation,
    DateTime? startTime,
    double? minElevation,
    int? searchHours,
  }) async {
    _setLoading(true);
    _failure = null;

    final response = await _passDataSource.predictNextPass(
      noradId: noradId,
      groundLocation: groundLocation,
      startTime: startTime,
      minElevation: minElevation,
      searchHours: searchHours,
    );

    response.fold(
      onSuccess: (pass) {
        _nextPass = pass;
        _failure = null;
        _isLoading = false;
        notifyListeners();
      },
      onFailure: (failure) {
        _failure = failure;
        _nextPass = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getSatellitePosition({
    required String noradId,
    Map<String, dynamic>? tle,
    DateTime? time,
  }) async {
    _setLoading(true);
    _failure = null;

    final response = await _passDataSource.getSatellitePosition(
      noradId: noradId,
      tle: tle,
      time: time,
    );

    response.fold(
      onSuccess: (position) {
        _currentPosition = position;
        _failure = null;
        _isLoading = false;
        notifyListeners();
      },
      onFailure: (failure) {
        _failure = failure;
        _currentPosition = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearPasses() {
    _passes = [];
    _nextPass = null;
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
