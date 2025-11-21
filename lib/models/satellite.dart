import 'dart:math' as math;
import 'package:flutter/material.dart';

class Satellite {
  final String id;
  final String name;
  final String noradId;
  final TLE tle;
  final DateTime createdAt;
  final DateTime updatedAt;

  Satellite({
    required this.id,
    required this.name,
    required this.noradId,
    required this.tle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Satellite.fromJson(Map<String, dynamic> json) {
    return Satellite(
      id: json['id'] as String,
      name: json['name'] as String,
      noradId: json['noradId'] as String,
      tle: TLE.fromJson(json['tle'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'noradId': noradId,
      'tle': tle.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Satellite copyWith({
    String? id,
    String? name,
    String? noradId,
    TLE? tle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Satellite(
      id: id ?? this.id,
      name: name ?? this.name,
      noradId: noradId ?? this.noradId,
      tle: tle ?? this.tle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Color getColor() {
    return const Color(0xFF42A5F5);
  }
}

class TLE {
  final String line1;
  final String line2;
  final DateTime epoch;

  TLE({
    required this.line1,
    required this.line2,
    required this.epoch,
  });

  factory TLE.fromJson(Map<String, dynamic> json) {
    return TLE(
      line1: json['line1'] as String,
      line2: json['line2'] as String,
      epoch: DateTime.parse(json['epoch'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'epoch': epoch.toIso8601String(),
    };
  }
  
  bool get isValid {
    return line1.isNotEmpty && 
           line2.isNotEmpty && 
           line1.length >= 69 && 
           line2.length >= 69;
  }
  
  String get statusMessage {
    if (!isValid) {
      return '⚠️ TLE Data Missing - Positions are approximate';
    }
    
    final daysSinceEpoch = DateTime.now().difference(epoch).inDays;
    
    if (daysSinceEpoch <= 7) {
      return '✅ TLE Data Fresh';
    } else if (daysSinceEpoch <= 14) {
      return '⚠️ TLE Data Aging - Consider updating';
    } else {
      return '❌ TLE Data Stale - Update required';
    }
  }

  bool get isFresh {
    final now = DateTime.now();
    final daysSinceEpoch = now.difference(epoch).inDays;
    return daysSinceEpoch <= 7;
  }

  String get freshnessStatus {
    final daysSinceEpoch = DateTime.now().difference(epoch).inDays;
    
    if (daysSinceEpoch <= 7) {
      return 'Fresh';
    } else if (daysSinceEpoch <= 14) {
      return 'Moderate';
    } else {
      return 'Stale';
    }
  }

  String? getAccuracyWarning(DateTime targetTime) {
    final timeDiff = targetTime.difference(epoch).abs();
    final daysDiff = timeDiff.inDays;
    
    if (daysDiff <= 2) {
      return null; 
    } else if (daysDiff <= 7) {
      return 'Accuracy: Good (~95%)';
    } else if (daysDiff <= 14) {
      return 'Accuracy: Moderate (~80%) - TLE is aging';
    } else if (daysDiff <= 30) {
      return 'Accuracy: Low (~60%) - TLE is stale';
    } else {
      return 'Warning: TLE very outdated ($daysDiff days from epoch). Position may be highly inaccurate.';
    }
  }

  double getAccuracyPercentage(DateTime targetTime) {
    final daysDiff = targetTime.difference(epoch).abs().inDays;
    
    if (daysDiff <= 2) return 99.9;
    if (daysDiff <= 7) return 95.0;
    if (daysDiff <= 14) return 80.0;
    if (daysDiff <= 30) return 60.0;
    return math.max(30.0, 100.0 - (daysDiff * 2.5));
  }
  
  Color get freshnessColor {
    final daysSinceEpoch = DateTime.now().difference(epoch).inDays;
    
    if (daysSinceEpoch <= 7) {
      return const Color(0xFF4CAF50); 
    } else if (daysSinceEpoch <= 14) {
      return const Color(0xFFFFA726); 
    } else {
      return const Color(0xFFEF5350); 
    }
  }
}
