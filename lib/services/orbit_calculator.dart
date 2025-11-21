import 'dart:math' as math;
import '../models/satellite.dart' as app_models;

class SatellitePosition {
  final double latitude;
  final double longitude;
  final double altitude; 
  final DateTime timestamp;

  SatellitePosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timestamp,
  });
}

class OrbitCalculator {
  static SatellitePosition? calculatePosition(
    app_models.Satellite satellite,
    DateTime time,
  ) {
    try {
      final tle = satellite.tle;
      final line1 = tle.line1.trim();
      final line2 = tle.line2.trim();
      
      if (line1.length < 69 || line2.length < 69) {
        return _calculateFallbackPosition(satellite, time);
      }
      
      final inclinationStr = line2.substring(8, 16).trim();
      final inclination = double.tryParse(inclinationStr);
      
      final raanStr = line2.substring(17, 25).trim();
      final raan = double.tryParse(raanStr);
      
      final meanMotionStr = line2.substring(52, 63).trim();
      final meanMotion = double.tryParse(meanMotionStr);
      
      if (inclination == null || raan == null || meanMotion == null) {
        return null;
      }
      
      final orbitalPeriod = 1440.0 / meanMotion;
      
      final epochYearStr = line1.substring(18, 20).trim();
      final epochDayStr = line1.substring(20, 32).trim();
      
      final epochYear = int.tryParse(epochYearStr);
      final epochDay = double.tryParse(epochDayStr);
      
      if (epochYear == null || epochDay == null) {
        return null;
      }
      
      final year = epochYear < 57 ? 2000 + epochYear : 1900 + epochYear;
      
      final epochDate = DateTime.utc(year, 1, 1).add(
        Duration(
          days: epochDay.floor() - 1,
          milliseconds: ((epochDay - epochDay.floor()) * 24 * 60 * 60 * 1000).round(),
        ),
      );
      
      final minutesSinceEpoch = time.difference(epochDate).inSeconds / 60.0;
      
      final orbitPhase = (minutesSinceEpoch % orbitalPeriod) / orbitalPeriod;
      
      
      final meanAnomaly = orbitPhase * 2 * math.pi;
      
      final trueAnomaly = meanAnomaly;
      
      final argumentOfLatitude = trueAnomaly;
      
      const mu = 398600.4418; 
      final meanMotionRadPerSec = meanMotion * 2 * math.pi / 86400.0;
      final semiMajorAxis = math.pow(mu / (meanMotionRadPerSec * meanMotionRadPerSec), 1.0 / 3.0);
      
      const earthRadius = 6371.0; 
      final calculatedAltitude = semiMajorAxis - earthRadius;
      
      final xOrbit = semiMajorAxis * math.cos(argumentOfLatitude);
      final yOrbit = semiMajorAxis * math.sin(argumentOfLatitude);
      
      final incRad = inclination * math.pi / 180.0;
      final raanRad = raan * math.pi / 180.0;
      
      final xEci = xOrbit * math.cos(raanRad) - yOrbit * math.cos(incRad) * math.sin(raanRad);
      final yEci = xOrbit * math.sin(raanRad) + yOrbit * math.cos(incRad) * math.cos(raanRad);
      final zEci = yOrbit * math.sin(incRad);
      
      final geodetic = _eciToGeodetic(xEci, yEci, zEci, time);

      return SatellitePosition(
        latitude: geodetic['latitude']!,
        longitude: geodetic['longitude']!,
        altitude: calculatedAltitude,
        timestamp: time,
      );
    } catch (e) {
      return null;
    }
  }

  static double _dateTimeToJulian(DateTime dateTime) {
    final a = (14 - dateTime.month) ~/ 12;
    final y = dateTime.year + 4800 - a;
    final m = dateTime.month + 12 * a - 3;

    var jdn = dateTime.day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;

    final jd = jdn +
        (dateTime.hour - 12) / 24 +
        dateTime.minute / 1440 +
        dateTime.second / 86400 +
        dateTime.millisecond / 86400000;

    return jd.toDouble();
  }

  static Map<String, double> _eciToGeodetic(
    double x,
    double y,
    double z,
    DateTime time,
  ) {
    const earthRadius = 6371.0; 
    const flattening = 1.0 / 298.257223563;
    const eccentricitySquared = 2 * flattening - flattening * flattening;

    final gmst = _calculateGMST(time);

    final theta = gmst * math.pi / 180.0;
    final xEcef = x * math.cos(theta) + y * math.sin(theta);
    final yEcef = -x * math.sin(theta) + y * math.cos(theta);
    final zEcef = z;

    var longitude = math.atan2(yEcef, xEcef) * 180.0 / math.pi;

    final r = math.sqrt(xEcef * xEcef + yEcef * yEcef);
    var latitude = math.atan2(zEcef, r);
    var altitude = 0.0;

    for (int i = 0; i < 5; i++) {
      final sinLat = math.sin(latitude);
      final n = earthRadius / math.sqrt(1 - eccentricitySquared * sinLat * sinLat);
      altitude = r / math.cos(latitude) - n;
      latitude = math.atan2(zEcef, r * (1 - eccentricitySquared * n / (n + altitude)));
    }

    latitude = latitude * 180.0 / math.pi;

    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
    };
  }

  static double _calculateGMST(DateTime time) {
    final jd = _dateTimeToJulian(time);
    
    final t = (jd - 2451545.0) / 36525.0;

    var gmst = 67310.54841 +
        (876600.0 * 3600.0 + 8640184.812866) * t +
        0.093104 * t * t -
        6.2e-6 * t * t * t;

    gmst = (gmst / 240.0) % 360.0;
    
    if (gmst < 0) {
      gmst += 360.0;
    }

    return gmst;
  }

  static List<SatellitePosition> calculateOrbitPath(
    app_models.Satellite satellite, {
    DateTime? startTime,
    int numPoints = 50,
    Duration orbitDuration = const Duration(hours: 2),
  }) {
    final positions = <SatellitePosition>[];
    final start = startTime ?? DateTime.now();
    final step = orbitDuration.inMilliseconds / numPoints;

    for (int i = 0; i < numPoints; i++) {
      final time = start.add(Duration(milliseconds: (step * i).round()));
      final position = calculatePosition(satellite, time);
      if (position != null) {
        positions.add(position);
      }
    }

    return positions;
  }

  static SatellitePosition _calculateFallbackPosition(
    app_models.Satellite satellite,
    DateTime time,
  ) {
    final hash = satellite.noradId.hashCode.abs();
    
    final inclination = 45.0 + (hash % 60); // 45-105 degrees
    final raan = (hash % 360).toDouble(); // 0-360 degrees
    final altitude = 400.0 + (hash % 600); // 400-1000 km
    final orbitalPeriod = 90.0 + (hash % 30); // 90-120 minutes
    
    final minutesSinceEpoch = time.millisecondsSinceEpoch / 60000.0;
    final orbitPhase = (minutesSinceEpoch % orbitalPeriod) / orbitalPeriod;
    final meanAnomaly = orbitPhase * 2 * math.pi;
    
    const earthRadius = 6371.0;
    final semiMajorAxis = earthRadius + altitude;
    
    final xOrbit = semiMajorAxis * math.cos(meanAnomaly);
    final yOrbit = semiMajorAxis * math.sin(meanAnomaly);
    
    final incRad = inclination * math.pi / 180.0;
    final raanRad = raan * math.pi / 180.0;
    
    final xEci = xOrbit * math.cos(raanRad) - yOrbit * math.cos(incRad) * math.sin(raanRad);
    final yEci = xOrbit * math.sin(raanRad) + yOrbit * math.cos(incRad) * math.cos(raanRad);
    final zEci = yOrbit * math.sin(incRad);
    
    final geodetic = _eciToGeodetic(xEci, yEci, zEci, time);
    
    return SatellitePosition(
      latitude: geodetic['latitude']!,
      longitude: geodetic['longitude']!,
      altitude: altitude,
      timestamp: time,
    );
  }
}
