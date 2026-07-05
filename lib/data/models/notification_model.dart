class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String ticketId;
  final String type;
  final String targetUserId;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.ticketId,
    required this.type,
    required this.targetUserId,
    this.isRead = false,
    required this.createdAt,
  });

  String get icon {
    switch (type) {
      case 'status_update':
        return '🔄';
      case 'comment':
        return '💬';
      case 'assigned':
        return '👤';
      case 'resolved':
        return '✅';
      default:
        return '🔔';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'ticket_id': ticketId,
    'type': type,
    'target_user_id': targetUserId,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        ticketId: json['ticket_id'],
        type: json['type'],
        targetUserId: json['target_user_id'] ?? '',
        isRead: json['is_read'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
      );
}
