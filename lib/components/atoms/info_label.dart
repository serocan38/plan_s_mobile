import 'package:flutter/material.dart';

class InfoLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isStatus;

  const InfoLabel({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: valueColor?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          valueColor == Colors.green ? Icons.check_circle : Icons.warning,
                          size: 14,
                          color: valueColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: valueColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
