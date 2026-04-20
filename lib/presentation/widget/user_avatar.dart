import 'package:flutter/material.dart';
import 'package:utsmobile/data/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 24});

  Color get _color {
    switch (user.role) {
      case 'admin':
        return const Color(0xFFC62828);
      case 'helpdesk':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color,
      child: Text(
        user.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
