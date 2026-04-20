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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.priorityBgColor(priority),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _icon,
              size: 11,
              color: AppColors.priorityColor(priority),
            ),
            const SizedBox(width: 3),
          ],
          Text(
            TicketConstants.priorityLabel(priority),
            style: TextStyle(
              color: AppColors.priorityColor(priority),
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}