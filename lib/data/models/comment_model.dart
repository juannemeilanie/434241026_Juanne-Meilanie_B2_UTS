class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String userRole;
  final String content;
  final DateTime createdAt;
  final bool isInternal;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
    this.isInternal = false,
  });

  String get initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName.substring(0, userName.length >= 2 ? 2 : 1).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket_id': ticketId,
    'user_id': userId,
    'user_name': userName,
    'user_role': userRole,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'is_internal': isInternal,
  };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'],
    ticketId: json['ticket_id'],
    userId: json['user_id'],
    userName: json['user_name'],
    userRole: json['user_role'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
    isInternal: json['is_internal'] ?? false,
  );
}
