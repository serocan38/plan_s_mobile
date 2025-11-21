import '../models/satellite.dart';

Map<String, dynamic> checkTLEFreshness(TLE tle) {
  final now = DateTime.now();
  final epochDate = tle.epoch; 
  
  final difference = now.difference(epochDate);
  final daysFromEpoch = difference.inDays;
  
  final isStale = daysFromEpoch > 7;
  
  return {
    'isStale': isStale,
    'daysFromEpoch': daysFromEpoch,
  };
}
