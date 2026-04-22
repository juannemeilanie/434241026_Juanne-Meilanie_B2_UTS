import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool small;
  final bool showIcon;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.small = false,
    this.showIcon = false,
  });

  IconData get _icon {
    switch (priority) {
      case 'critical':
        return Icons.emergency;
      case 'high':
        return Icons.arrow_upward;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.remove;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color baseColor;

    switch (priority) {
      case 'critical':
        baseColor = theme.colorScheme.error;
        break;
      case 'high':
        baseColor = Colors.orange;
        break;
      case 'medium':
        baseColor = Colors.amber;
        break;
      case 'low':
        baseColor = Colors.green;
        break;
      default:
        baseColor = theme.colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isDark ? 0.25 : 0.15), // ✅ adaptif
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _icon,
              size: 11,
              color: baseColor,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            TicketConstants.priorityLabel(priority),
            style: TextStyle(
              color: baseColor,
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}