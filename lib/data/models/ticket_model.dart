class TicketModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String priority;
  final String userId;
  final String userName;

  final String? assignedTo;        // 🔥 dibuat final (lebih aman)
  final String? assignedToName;    // 🔥 dibuat final

  final DateTime createdAt;
  final DateTime updatedAt;        // 🔥 final (hindari mutation bug)
  final List<String> attachments;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.userId,
    required this.userName,
    this.assignedTo,
    this.assignedToName,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const [],
  });

  // ================= COPY WITH =================
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    String? priority,
    String? userId,
    String? userName,
    String? assignedTo,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attachments,

    bool clearAssigned = false, // 🔥 untuk unassign
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,

      assignedTo: clearAssigned
          ? null
          : (assignedTo ?? this.assignedTo),

      assignedToName: clearAssigned
          ? null
          : (assignedToName ?? this.assignedToName),

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'status': status,
    'priority': priority,
    'userId': userId,
    'userName': userName,
    'assignedTo': assignedTo,
    'assignedToName': assignedToName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'attachments': attachments,
  };

  // ================= FROM JSON =================
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'low',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      assignedTo: json['assignedTo'],
      assignedToName: json['assignedToName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.now(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}