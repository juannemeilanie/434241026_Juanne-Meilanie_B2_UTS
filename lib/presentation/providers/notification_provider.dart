import 'package:flutter/material.dart';
import 'package:utsmobile/data/services/local_storage_service.dart';
import 'package:utsmobile/data/models/notification_model.dart';
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  String? _userId;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void loadForUser(String userId) {
    final newData =
    LocalStorageService.getNotificationsForUser(userId);

    if (_userId == userId &&
        _notifications.length == newData.length) {
      return;
    }

    _userId = userId;
    _notifications = newData;

    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await LocalStorageService.markNotificationRead(id);
    loadForUser(_userId!);
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    await LocalStorageService.markAllNotificationsRead(_userId!);
    loadForUser(_userId!);
  }
}