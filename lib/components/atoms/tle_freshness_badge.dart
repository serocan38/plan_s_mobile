import 'package:flutter/material.dart';

class TLEFreshnessBadge extends StatelessWidget {
  final int daysFromEpoch;
  final bool compact;

  const TLEFreshnessBadge({
    super.key,
    required this.daysFromEpoch,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusStyle();

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              '${daysFromEpoch}d',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getStatusStyle() {
    if (daysFromEpoch <= 3) {
      return (Colors.green, Icons.check_circle);
    } else if (daysFromEpoch <= 7) {
      return (Colors.orange, Icons.warning);
    } else {
      return (Colors.red, Icons.error);
    }
  }

  String _getStatusText() {
    if (daysFromEpoch <= 3) {
      return 'Fresh ($daysFromEpoch days)';
    } else if (daysFromEpoch <= 7) {
      return 'Aging ($daysFromEpoch days)';
    } else {
      return 'Stale ($daysFromEpoch days)';
    }
  }
}
