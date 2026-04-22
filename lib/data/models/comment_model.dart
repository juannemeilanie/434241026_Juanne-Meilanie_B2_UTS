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
    'ticketId': ticketId,
    'userId': userId,
    'userName': userName,
    'userRole': userRole,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isInternal': isInternal,
  };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'],
    ticketId: json['ticketId'],
    userId: json['userId'],
    userName: json['userName'],
    userRole: json['userRole'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    isInternal: json['isInternal'] ?? false,
  );
}
