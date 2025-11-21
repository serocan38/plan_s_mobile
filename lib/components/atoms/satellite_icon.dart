import 'package:flutter/material.dart';

class SatelliteIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const SatelliteIcon({
    super.key,
    this.size = 24,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.4),
      decoration: BoxDecoration(
        color: (backgroundColor ?? Colors.blue).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.satellite_alt,
        color: color ?? Colors.blue,
        size: size,
      ),
    );
  }
}
