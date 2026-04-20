import 'package:flutter/material.dart';

class StatusStep extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const StatusStep({
    super.key,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  Color getColor(BuildContext context) {
    if (isDone) return Colors.green;
    if (isActive) return Theme.of(context).primaryColor;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(context);

    return Column(
      children: [
        // 🔵 Circle
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: 16,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 4),

        // 📝 Label
        Text(
          label.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}