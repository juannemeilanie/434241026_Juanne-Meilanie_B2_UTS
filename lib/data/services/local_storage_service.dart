import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';

class LocalStorageService {
  static const _keyUsers = 'users';
  static const _keyTickets = 'tickets';
  static const _keyComments = 'comments';
  static const _keyNotifications = 'notifications';
  static const _keyLoggedInUserId = 'logged_in_user_id';
  static const _keyTicketCounter = 'ticket_counter';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('LocalStorageService belum di-init');
    return _prefs!;
  }

  static List<UserModel> getUsers() {
    final raw = prefs.getString(_keyUsers);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  static Future<void> saveUsers(List<UserModel> users) async {
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_keyUsers, encoded);
  }

  static Future<void> seedDefaultUsers() async {
    final users = getUsers();

    // Kalau sudah ada user, jangan seed ulang
    if (users.isNotEmpty) return;

    final defaultUsers = [
      UserModel(
        id: 'admin_1',
        name: 'Admin',
        email: 'admin@gmail.com',
        password: '123456',
        role: 'admin',
      ),
      UserModel(
        id: 'helpdesk_1',
        name: 'Helpdesk',
        email: 'helpdesk@gmail.com',
        password: '123456',
        role: 'helpdesk',
      ),
    ];

    await saveUsers(defaultUsers);
  }

  static Future<void> addUser(UserModel user) async {
    final users = getUsers();
    users.add(user);
    await saveUsers(users);
  }

  static UserModel? getUserByEmail(String email) {
    final users = getUsers();
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static UserModel? getUserById(String id) {
    final users = getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUser(UserModel updated) async {
    final users = getUsers();
    final idx = users.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      users[idx] = updated;
      await saveUsers(users);
    }
  }

  // ── Session (siapa yang sedang login) ──
  static Future<void> saveLoggedInUserId(String userId) async {
    await prefs.setString(_keyLoggedInUserId, userId);
  }

  static String? getLoggedInUserId() {
    return prefs.getString(_keyLoggedInUserId);
  }


  static Future<void> clearLoggedInUser() async {
    await prefs.remove(_keyLoggedInUserId);
  }

  static UserModel? getLoggedInUser() {
    final id = getLoggedInUserId();
    if (id == null) return null;
    return getUserById(id);
  }

  static List<TicketModel> getTickets() {
    final raw = prefs.getString(_keyTickets);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => TicketModel.fromJson(e)).toList();
  }

  static Future<void> saveTickets(List<TicketModel> tickets) async {
    final encoded = jsonEncode(tickets.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTickets, encoded);
  }

  static Future<TicketModel> addTicket(TicketModel ticket) async {
    final tickets = getTickets();
    tickets.insert(0, ticket);
    await saveTickets(tickets);
    return ticket;
  }

  static Future<void> updateTicket(TicketModel updated) async {
    final tickets = getTickets();
    final idx = tickets.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      tickets[idx] = updated;
      await saveTickets(tickets);
    }
  }

  // Generate ID tiket otomatis: TKT-001, TKT-002, dst
  static Future<String> generateTicketId() async {
    final counter = (prefs.getInt(_keyTicketCounter) ?? 0) + 1;
    await prefs.setInt(_keyTicketCounter, counter);
    return 'TKT-${counter.toString().padLeft(3, '0')}';
  }


  static List<CommentModel> getComments() {
    final raw = prefs.getString(_keyComments);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => CommentModel.fromJson(e)).toList();
  }

  static List<CommentModel> getCommentsByTicket(String ticketId) {
    return getComments()
        .where((c) => c.ticketId == ticketId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static Future<void> saveComments(List<CommentModel> comments) async {
    final encoded = jsonEncode(comments.map((c) => c.toJson()).toList());
    await prefs.setString(_keyComments, encoded);
  }

  static Future<void> addComment(CommentModel comment) async {
    final comments = getComments();
    comments.add(comment);
    await saveComments(comments);
  }

  static List<NotificationModel> getNotifications() {
    final raw = prefs.getString(_keyNotifications);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  static List<NotificationModel> getNotificationsForUser(String userId) {
    return getNotifications()
        .where((n) => n.targetUserId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveNotifications(List<NotificationModel> notifs) async {
    final encoded = jsonEncode(notifs.map((n) => n.toJson()).toList());
    await prefs.setString(_keyNotifications, encoded);
  }

  static Future<void> addNotification(NotificationModel notif) async {
    final notifs = getNotifications();
    notifs.insert(0, notif);
    await saveNotifications(notifs);
  }

  static Future<void> markNotificationRead(String id) async {
    final notifs = getNotifications();
    final idx = notifs.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifs[idx].isRead = true;
      await saveNotifications(notifs);
    }
  }

  static Future<void> markAllNotificationsRead(String userId) async {
    final notifs = getNotifications();
    for (final n in notifs) {
      if (n.targetUserId == userId) n.isRead = true;
    }
    await saveNotifications(notifs);
  }


  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
