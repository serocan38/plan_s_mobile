import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/satellite.dart';
import '../../services/orbit_calculator.dart';

class InteractiveGlobe3D extends StatefulWidget {
  final List<Satellite> satellites;
  final Satellite? selectedSatellite;
  final DateTime currentTime;
  final Function(Satellite)? onSatelliteSelected;
  final double size;

  const InteractiveGlobe3D({
    super.key,
    required this.satellites,
    this.selectedSatellite,
    required this.currentTime,
    this.onSatelliteSelected,
    this.size = 300,
  });

  @override
  State<InteractiveGlobe3D> createState() => _InteractiveGlobe3DState();
}

class _InteractiveGlobe3DState extends State<InteractiveGlobe3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _rotationY = 0.0;
  double _rotationX = 0.3; 
  Map<String, SatellitePosition> _satellitePositions = {};
  double _scale = 1.0; 
  double _baseScale = 1.0; 
  static const double _minScale = 0.5;
  static const double _maxScale = 3.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _updateSatellitePositions();
  }

  @override
  void didUpdateWidget(InteractiveGlobe3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.satellites != widget.satellites ||
        oldWidget.currentTime != widget.currentTime) {
      _updateSatellitePositions();
    }
  }

  void _updateSatellitePositions() {
    setState(() {
      _satellitePositions = {};
      for (var satellite in widget.satellites) {
        final position = OrbitCalculator.calculatePosition(
          satellite,
          widget.currentTime,
        );
        if (position != null) {
          _satellitePositions[satellite.id] = position;
        }
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
    _rotationController.stop();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_baseScale * details.scale).clamp(_minScale, _maxScale);
      
      if (details.pointerCount == 1) {
        _rotationY += details.focalPointDelta.dx * 0.01;
        _rotationX += details.focalPointDelta.dy * 0.01;
        _rotationX = _rotationX.clamp(-math.pi / 2, math.pi / 2);
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _rotationController.repeat();
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.2).clamp(_minScale, _maxScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.2).clamp(_minScale, _maxScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _rotationY = 0.0;
      _rotationX = 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  final autoRotation = _rotationController.value * 2 * math.pi;
                  return CustomPaint(
                    size: Size(
                      constraints.maxWidth.isFinite ? constraints.maxWidth : 300,
                      constraints.maxHeight.isFinite ? constraints.maxHeight : 300,
                    ),
                    painter: Globe3DPainter(
                      rotationY: _rotationY,
                      autoRotationY: autoRotation * 0.1,
                      rotationX: _rotationX,
                      satellites: widget.satellites,
                      selectedSatellite: widget.selectedSatellite,
                      satellitePositions: _satellitePositions,
                      currentTime: widget.currentTime,
                      scale: _scale,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _zoomIn,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _resetZoom,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _zoomOut,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Zoom: ${(_scale * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
class Globe3DPainter extends CustomPainter {
  final double rotationY; 
  final double autoRotationY; 
  final double rotationX;
  final List<Satellite> satellites;
  final Satellite? selectedSatellite;
  final Map<String, SatellitePosition> satellitePositions;
  final DateTime currentTime;
  final double scale;

  Globe3DPainter({
    required this.rotationY,
    required this.autoRotationY,
    required this.rotationX,
    required this.satellites,
    this.selectedSatellite,
    required this.satellitePositions,
    required this.currentTime,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minDimension = math.min(size.width, size.height);
    final radius = (minDimension / 2.5) * scale; 

    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.8),
          Colors.black,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: minDimension / 2));
    canvas.drawRect(Offset.zero & size, bgPaint);

    _drawStars(canvas, size);

    _drawEarth(canvas, center, radius);

    _drawLatLongLines(canvas, center, radius);

    if (satellites.isNotEmpty) {
      for (var satellite in satellites) {
        final position = satellitePositions[satellite.id];
        if (position != null) {
          final isSelected = selectedSatellite?.id == satellite.id;
          _drawSatellite(canvas, center, radius, satellite, position, isSelected);
        }
      }
    }

    if (selectedSatellite != null) {
      final position = satellitePositions[selectedSatellite!.id];
      if (position != null) {
        _drawOrbitPath(canvas, center, radius, selectedSatellite!, position);
      }
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42); 

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    final shadowGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.5,
      colors: [
        const Color(0xFF1E88E5),
        const Color(0xFF0D47A1),
        const Color(0xFF000A1F),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final earthPaint = Paint()
      ..shader = shadowGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, earthPaint);

    final glowPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * scale);
    canvas.drawCircle(center, radius + (10 * scale), glowPaint);

    _drawContinents(canvas, center, radius);
  }

  void _drawContinents(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final continents = [
      _createContinentPath(center, radius, [
        {'lat': 20, 'lon': 15},
        {'lat': 10, 'lon': 40},
        {'lat': -30, 'lon': 35},
        {'lat': -35, 'lon': 20},
        {'lat': -20, 'lon': 15},
      ]),
      _createContinentPath(center, radius, [
        {'lat': 10, 'lon': -75},
        {'lat': -10, 'lon': -50},
        {'lat': -35, 'lon': -60},
        {'lat': -55, 'lon': -70},
      ]),
    ];

    for (final path in continents) {
      if (path != null) {
        canvas.drawPath(path, paint);
      }
    }
  }

  Path? _createContinentPath(Offset center, double radius, List<Map<String, num>> points) {
    if (points.isEmpty) return null;

    final path = Path();
    bool firstPoint = true;

    for (final point in points) {
      final lat = (point['lat'] as num).toDouble();
      final lon = (point['lon'] as num).toDouble();
      final projected = _projectToSphere(lat, lon, center, radius);

      if (projected != null) {
        if (firstPoint) {
          path.moveTo(projected.dx, projected.dy);
          firstPoint = false;
        } else {
          path.lineTo(projected.dx, projected.dy);
        }
      }
    }

    path.close();
    return path;
  }

  void _drawLatLongLines(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, scale * 0.8);

    for (int lat = -60; lat <= 60; lat += 30) {
      final path = Path();
      bool firstPoint = true;

      for (int lon = -180; lon <= 180; lon += 10) {
        final projected = _projectToSphere(lat.toDouble(), lon.toDouble(), center, radius);
        if (projected != null) {
          if (firstPoint) {
            path.moveTo(projected.dx, projected.dy);
            firstPoint = false;
          } else {
            path.lineTo(projected.dx, projected.dy);
          }
        }
      }

      canvas.drawPath(path, paint);
    }

    for (int lon = -180; lon < 180; lon += 30) {
      final path = Path();
      bool firstPoint = true;

      for (int lat = -90; lat <= 90; lat += 5) {
        final projected = _projectToSphere(lat.toDouble(), lon.toDouble(), center, radius);
        if (projected != null) {
          if (firstPoint) {
            path.moveTo(projected.dx, projected.dy);
            firstPoint = false;
          } else {
            path.lineTo(projected.dx, projected.dy);
          }
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawSatellite(Canvas canvas, Offset center, double radius, Satellite satellite, SatellitePosition position, bool isSelected) {
    final satLat = position.latitude;
    final satLon = position.longitude;
    final satAltitude = position.altitude;
    
    final satRadius = radius * (1 + satAltitude / 6371);

    
    final projected = _projectSatelliteToSphere(satLat, satLon, center, satRadius);
    
    if (projected != null) {
      
      final satColor = isSelected ? Colors.red : satellite.getColor();
      final glowOpacity = isSelected ? 0.5 : 0.3;

      
      final satPaint = Paint()
        ..color = satColor
        ..style = PaintingStyle.fill;
      
      
      final satSize = (isSelected ? 6.0 : 4.0) * math.sqrt(scale);
      canvas.drawCircle(projected, satSize, satPaint);

      
      final glowPaint = Paint()
        ..color = satColor.withValues(alpha: glowOpacity)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (isSelected ? 10.0 : 8.0) * math.sqrt(scale),
        );
      canvas.drawCircle(projected, (isSelected ? 10.0 : 8.0) * math.sqrt(scale), glowPaint);

      
      if (isSelected) {
        final panelPaint = Paint()
          ..color = Colors.blue[200]!
          ..style = PaintingStyle.fill;
        final panelOffset = 12.0 * math.sqrt(scale);
        final panelWidth = 8.0 * math.sqrt(scale);
        final panelHeight = 4.0 * math.sqrt(scale);
        
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(projected.dx - panelOffset, projected.dy),
            width: panelWidth,
            height: panelHeight,
          ),
          panelPaint,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(projected.dx + panelOffset, projected.dy),
            width: panelWidth,
            height: panelHeight,
          ),
          panelPaint,
        );

        
        final textPainter = TextPainter(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${satellite.name}\n',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Alt: ${satAltitude.toStringAsFixed(0)} km',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        
        final textBgRect = Rect.fromLTWH(
          projected.dx - textPainter.width / 2 - 4,
          projected.dy - 35,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(textBgRect, const Radius.circular(4)),
          Paint()..color = Colors.black.withValues(alpha: 0.7),
        );
        
        textPainter.paint(
          canvas,
          Offset(projected.dx - textPainter.width / 2, projected.dy - 33),
        );
      }
    }
  }

  void _drawOrbitPath(Canvas canvas, Offset center, double radius, Satellite satellite, SatellitePosition position) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, scale * 1.5);
    
    final path = Path();
    bool firstPoint = true;
    
    for (int i = 0; i <= 90; i++) {
      final timeOffset = Duration(minutes: i * 2); 
      final futureTime = currentTime.add(timeOffset);

      final futurePosition = OrbitCalculator.calculatePosition(satellite, futureTime);
      
      if (futurePosition != null) {
        final satRadius = radius * (1 + futurePosition.altitude / 6371);
        final projected = _projectSatelliteToSphere(
          futurePosition.latitude,
          futurePosition.longitude,
          center,
          satRadius,
        );
        
        if (projected != null) {
          if (firstPoint) {
            path.moveTo(projected.dx, projected.dy);
            firstPoint = false;
          } else {
            path.lineTo(projected.dx, projected.dy);
          }
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  Offset? _projectToSphere(double lat, double lon, Offset center, double radius) {
    final latRad = lat * math.pi / 180;
    final lonRad = lon * math.pi / 180;

    final cosLat = math.cos(latRad);
    final sinLat = math.sin(latRad);
    final cosLon = math.cos(lonRad + rotationY + autoRotationY);
    final sinLon = math.sin(lonRad + rotationY + autoRotationY);

    final x = radius * cosLat * sinLon;
    final y = radius * (sinLat * math.cos(rotationX) - cosLat * cosLon * math.sin(rotationX));
    final z = radius * (sinLat * math.sin(rotationX) + cosLat * cosLon * math.cos(rotationX));

    if (z < 0) return null;

    return Offset(center.dx + x, center.dy - y);
  }

  Offset? _projectSatelliteToSphere(double lat, double lon, Offset center, double radius) {
    final latRad = lat * math.pi / 180;
    final lonRad = lon * math.pi / 180;

    final cosLat = math.cos(latRad);
    final sinLat = math.sin(latRad);
    final cosLon = math.cos(lonRad + rotationY);
    final sinLon = math.sin(lonRad + rotationY);

    final x = radius * cosLat * sinLon;
    final y = radius * (sinLat * math.cos(rotationX) - cosLat * cosLon * math.sin(rotationX));
    final z = radius * (sinLat * math.sin(rotationX) + cosLat * cosLon * math.cos(rotationX));

    if (z < 0) return null;

    return Offset(center.dx + x, center.dy - y);
  }

  @override
  bool shouldRepaint(Globe3DPainter oldDelegate) {
    return oldDelegate.rotationY != rotationY ||
        oldDelegate.autoRotationY != autoRotationY ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.satellites != satellites ||
        oldDelegate.selectedSatellite != selectedSatellite ||
        oldDelegate.satellitePositions != satellitePositions ||
        oldDelegate.currentTime != currentTime ||
        oldDelegate.scale != scale;
  }
}
