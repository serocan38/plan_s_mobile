import 'dart:math';

class PassPrediction {
  final DateTime startTime; 
  final DateTime endTime; 
  final DateTime maxElevationTime; 
  final double maxElevation; 
  final double duration; 
  final double startAzimuth; 
  final double endAzimuth; 

  DateTime get aos => startTime;
  DateTime get tca => maxElevationTime;
  DateTime get los => endTime;
  double get azimuthAos => startAzimuth;
  double get azimuthLos => endAzimuth;

  PassPrediction({
    required this.startTime,
    required this.endTime,
    required this.maxElevationTime,
    required this.maxElevation,
    required this.duration,
    required this.startAzimuth,
    required this.endAzimuth,
  });

  factory PassPrediction.fromJson(Map<String, dynamic> json) {
    final hasNewFormat = json.containsKey('startTime');
    
    return PassPrediction(
      startTime: DateTime.parse(
        hasNewFormat ? json['startTime'] as String : json['aos'] as String
      ),
      endTime: DateTime.parse(
        hasNewFormat ? json['endTime'] as String : json['los'] as String
      ),
      maxElevationTime: DateTime.parse(
        hasNewFormat ? json['maxElevationTime'] as String : json['tca'] as String
      ),
      maxElevation: (json['maxElevation'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      startAzimuth: ((hasNewFormat 
        ? json['startAzimuth'] 
        : json['azimuthAos']
      ) as num).toDouble(),
      endAzimuth: ((hasNewFormat 
        ? json['endAzimuth'] 
        : json['azimuthLos']
      ) as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'maxElevationTime': maxElevationTime.toIso8601String(),
      'maxElevation': maxElevation,
      'duration': duration,
      'startAzimuth': startAzimuth,
      'endAzimuth': endAzimuth,
    };
  }

  String get durationFormatted {
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60).floor();
    return '${minutes}m ${seconds}s';
  }

  String get maxElevationFormatted {
    return '${maxElevation.toStringAsFixed(1)}°';
  }
}

class GroundLocation {
  final double latitude;
  final double longitude;
  final double altitude; 

  GroundLocation({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
    };
  }

  factory GroundLocation.fromJson(Map<String, dynamic> json) {
    return GroundLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class VelocityVector {
  final double x;
  final double y;
  final double z;

  VelocityVector({
    required this.x,
    required this.y,
    required this.z,
  });

  factory VelocityVector.fromJson(Map<String, dynamic> json) {
    return VelocityVector(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  double get magnitude => sqrt(x * x + y * y + z * z);
}

class SatellitePosition {
  final double latitude;
  final double longitude;
  final double altitude;
  final VelocityVector velocity;

  SatellitePosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.velocity,
  });

  factory SatellitePosition.fromJson(Map<String, dynamic> json) {
    return SatellitePosition(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      velocity: VelocityVector.fromJson(json['velocity'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'velocity': velocity.toJson(),
    };
  }
}
