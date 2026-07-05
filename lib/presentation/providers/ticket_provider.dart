import 'package:flutter/foundation.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/notification_model.dart';

class TicketProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];

  Future<void> loadTickets() async {
    final data = await SupabaseService.getTickets();

    if (_tickets.length == data.length) return;

    _tickets = data;
    notifyListeners();
  }

  List<TicketModel> get tickets => _tickets;

  List<TicketModel> get filteredTickets {
    final list = List<TicketModel>.from(_tickets);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<TicketModel> getAllTickets() {
    return filteredTickets;
  }

  List<TicketModel> getTicketsByUser(String userId) {
    return _tickets
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TicketModel> getTicketsAssignedTo(String helpdeskId) {
    return _tickets
        .where((t) => t.assignedTo == helpdeskId)
        .toList();
  }

  Map<String, int> get stats => {
    'total': _tickets.length,
    'open': _tickets.where((t) => t.status == 'open').length,
    'in_progress':
    _tickets.where((t) => t.status == 'in_progress').length,
    'closed':
    _tickets.where((t) => t.status == 'closed').length,
  };

  Map<String, int> getStatsByUser(String id) {
    final mine = _tickets.where((t) => t.userId == id);
    return {
      'total': mine.length,
      'open': mine.where((t) => t.status == 'open').length,
      'in_progress':
      mine.where((t) => t.status == 'in_progress').length,
      'closed':
      mine.where((t) => t.status == 'closed').length,
    };
  }

  Map<String, int> getStatsByHelpdesk(String helpdeskId) {
    final mine = _tickets.where((t) => t.assignedTo == helpdeskId);
    return {
      'total': mine.length,
      'open': mine.where((t) => t.status == 'open').length,
      'in_progress': mine.where((t) => t.status == 'in_progress').length,
      'closed': mine.where((t) => t.status == 'closed').length,
    };
  }

  List<TicketModel> getRecentTickets({String? userId, String? helpdeskId}) {
    List<TicketModel> list;

    if (helpdeskId != null) {
      list = _tickets.where((t) => t.assignedTo == helpdeskId).toList();
    } else if (userId != null) {
      list = _tickets.where((t) => t.userId == userId).toList();
    } else {
      list = List<TicketModel>.from(_tickets);
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(5).toList();
  }

  TicketModel? getTicketById(String id) {
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _createNotification({
    required String title,
    required String body,
    required String ticketId,
    required String type,
    required String targetUserId,
  }) async {
    await SupabaseService.addNotification(
      NotificationModel(
        id: DateTime.now().toString(),
        title: title,
        body: body,
        ticketId: ticketId,
        type: type,
        targetUserId: targetUserId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String userId,
    required String userName,
    List<String> attachments = const [],
  }) async {
    final id = await LocalStorageService.generateTicketId();

    final t = TicketModel(
      id: id,
      title: title,
      description: description,
      category: category,
      status: 'open',
      priority: priority,
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      attachments: attachments,
    );

    await SupabaseService.addTicket(t);
    _tickets.insert(0, t);

    final users = await SupabaseService.getUsers();
    for (final u in users) {
      if (u.role == 'admin' || u.role == 'helpdesk') {
        await _createNotification(
          title: 'Tiket Baru',
          body: '$userName membuat tiket: $title',
          ticketId: t.id,
          type: 'ticket',
          targetUserId: u.id,
        );
      }
    }

    notifyListeners();
    return t;
  }

  Future<void> updateStatus(
      String id,
      String status, {
        required String updatedByUserId,
        required String updatedByName,
      }) async {
    final i = _tickets.indexWhere((t) => t.id == id);
    if (i == -1) return;

    final updated = _tickets[i].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    _tickets[i] = updated;
    await SupabaseService.updateTicket(updated);

    await _createNotification(
      title: 'Status Tiket',
      body: 'Status tiket ${updated.id} diubah menjadi $status',
      ticketId: updated.id,
      type: 'status_update',
      targetUserId: updated.userId,
    );

    notifyListeners();
  }

  Future<void> assignTicket({
    required String ticketId,
    required String helpdeskId,
    required String helpdeskName,
  }) async {
    final i = _tickets.indexWhere((t) => t.id == ticketId);
    if (i == -1) return;

    final updated = _tickets[i].copyWith(
      assignedTo: helpdeskId,
      assignedToName: helpdeskName,
      status: 'in_progress',
      updatedAt: DateTime.now(),
    );

    _tickets[i] = updated;
    await SupabaseService.updateTicket(updated);

    await _createNotification(
      title: 'Tiket Ditugaskan',
      body: 'Kamu ditugaskan ke tiket ${updated.id}',
      ticketId: updated.id,
      type: 'assigned',
      targetUserId: helpdeskId,
    );

    await _createNotification(
      title: 'Tiket Diproses',
      body: 'Tiket kamu sedang diproses oleh $helpdeskName',
      ticketId: updated.id,
      type: 'assigned',
      targetUserId: updated.userId,
    );

    notifyListeners();
  }

  Future<List<CommentModel>> getCommentsByTicket(String id) async {
    return await SupabaseService.getCommentsByTicket(id);
  }

  Future<void> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String userRole,
    required String content,
  }) async {
    await SupabaseService.addComment(
      CommentModel(
        id: DateTime.now().toString(),
        ticketId: ticketId,
        userId: userId,
        userName: userName,
        userRole: userRole,
        content: content,
        createdAt: DateTime.now(),
      ),
    );

    final ticket = getTicketById(ticketId);
    if (ticket == null) return;

    if (userRole == 'user') {
      if (ticket.assignedTo != null) {
        await _createNotification(
          title: 'Komentar Baru',
          body: '$userName: $content',
          ticketId: ticketId,
          type: 'comment',
          targetUserId: ticket.assignedTo!,
        );
      }
    } else {
      await _createNotification(
        title: 'Balasan Tiket',
        body: '$userName: $content',
        ticketId: ticketId,
        type: 'comment',
        targetUserId: ticket.userId,
      );
    }

    notifyListeners();
  }

  Future<bool> deleteTicket(String ticketId) async {
    final ticket = getTicketById(ticketId);
    if (ticket == null) return false;

    if (ticket.assignedTo != null) return false;

    await SupabaseService.deleteTicket(ticketId);
    _tickets.removeWhere((t) => t.id == ticketId);
    notifyListeners();
    return true;
  }
}