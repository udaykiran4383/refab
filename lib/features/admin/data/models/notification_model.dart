class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'system', 'pickup', 'order', 'general'
  final List<String> targetRoles;
  final String? targetUserId;
  final String? userId; // For user-specific notifications
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.targetRoles,
    this.targetUserId,
    this.userId,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      targetRoles: List<String>.from(json['targetRoles'] ?? []),
      targetUserId: json['targetUserId'],
      userId: json['userId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'targetRoles': targetRoles,
      'targetUserId': targetUserId,
      'userId': userId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    List<String>? targetRoles,
    String? targetUserId,
    String? userId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetRoles: targetRoles ?? this.targetRoles,
      targetUserId: targetUserId ?? this.targetUserId,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isSystemNotification => type == 'system';
  bool get isPickupNotification => type == 'pickup';
  bool get isOrderNotification => type == 'order';
} 