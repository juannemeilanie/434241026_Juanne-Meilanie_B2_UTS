import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static Future<UserModel?> getUserByEmail(String email) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  static Future<void> addUser(UserModel user) async {
    await supabase.from('users').insert(user.toJson());
  }

  static Future<void> updateUser(UserModel user) async {
    await supabase
        .from('users')
        .update(user.toJson())
        .eq('id', user.id);
  }

  static Future<List<UserModel>> getUsers() async {
    final data = await supabase.from('users').select();
    return (data as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  static Future<void> deleteUser(String userId) async {
    await supabase.from('users').delete().eq('id', userId);
  }

  static Future<void> addTicket(TicketModel ticket) async {
    await supabase.from('tickets').insert(ticket.toJson());
  }

  static Future<List<TicketModel>> getTickets() async {
    final data = await supabase.from('tickets').select();
    return (data as List)
        .map((e) => TicketModel.fromJson(e))
        .toList();
  }

  static Future<void> updateTicket(TicketModel ticket) async {
    await supabase
        .from('tickets')
        .update(ticket.toJson())
        .eq('id', ticket.id);
  }

  static Future<void> deleteTicket(String ticketId) async {
    await supabase.from('tickets').delete().eq('id', ticketId);
  }

  static Future<void> addComment(CommentModel comment) async {
    await supabase.from('comments').insert(comment.toJson());
  }

  static Future<List<CommentModel>> getCommentsByTicket(
      String ticketId) async {
    final data = await supabase
        .from('comments')
        .select()
        .eq('ticket_id', ticketId);

    return (data as List)
        .map((e) => CommentModel.fromJson(e))
        .toList();
  }

  static Future<void> addNotification(
      NotificationModel notif) async {
    await supabase
        .from('notifications')
        .insert(notif.toJson());
  }

  static Future<List<NotificationModel>>
  getNotificationsForUser(String userId) async {
    final data = await supabase
        .from('notifications')
        .select()
        .eq('target_user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  static Future<void> markNotificationRead(String id) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  static Future<void> markAllNotificationsRead(
      String userId) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('target_user_id', userId);
  }
}