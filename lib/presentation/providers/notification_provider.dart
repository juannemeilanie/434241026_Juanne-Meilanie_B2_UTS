import 'package:flutter/material.dart';
import 'package:utsmobile/data/services/local_storage_service.dart';
import '../../data/services/supabase_service.dart';
import 'package:utsmobile/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  String? _userId;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> loadForUser(String userId) async {
    final newData =
    await SupabaseService.getNotificationsForUser(userId);

    if (_userId == userId &&
        _notifications.length == newData.length) {
      return;
    }

    _userId = userId;
    _notifications = newData;

    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    if (_userId == null) return;

    await SupabaseService.markNotificationRead(id);
    await loadForUser(_userId!);
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    await SupabaseService.markAllNotificationsRead(_userId!);
    await loadForUser(_userId!);
  }
}