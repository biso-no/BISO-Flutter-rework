import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String type; // 'direct', 'group', 'team', 'department'
  final List<String> participants;
  final String? teamId;
  final String? departmentId;
  final String? avatarUrl;
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final bool isActive;
  final bool isMuted;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActivityAt;

  const ChatModel({
    required this.id,
    required this.name,
    this.description,
    this.type = 'group',
    this.participants = const [],
    this.teamId,
    this.departmentId,
    this.avatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    this.isActive = true,
    this.isMuted = false,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.lastActivityAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      type: map['type'] ?? 'group',
      participants: List<String>.from(map['participants'] ?? []),
      teamId: map['team_id'],
      departmentId: map['department_id'],
      avatarUrl: map['avatar_url'],
      lastMessage: map['last_message'] != null 
          ? ChatMessageModel.fromMap(map['last_message']) 
          : null,
      unreadCount: map['unread_count'] ?? 0,
      isActive: map['is_active'] ?? true,
      isMuted: map['is_muted'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: map['\$createdAt'] != null ? DateTime.parse(map['\$createdAt']) : null,
      updatedAt: map['\$updatedAt'] != null ? DateTime.parse(map['\$updatedAt']) : null,
      lastActivityAt: map['last_activity_at'] != null ? DateTime.parse(map['last_activity_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'participants': participants,
      'team_id': teamId,
      'department_id': departmentId,
      'avatar_url': avatarUrl,
      'last_message': lastMessage?.toMap(),
      'unread_count': unreadCount,
      'is_active': isActive,
      'is_muted': isMuted,
      'metadata': metadata,
      'last_activity_at': lastActivityAt?.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    List<String>? participants,
    String? teamId,
    String? departmentId,
    String? avatarUrl,
    ChatMessageModel? lastMessage,
    int? unreadCount,
    bool? isActive,
    bool? isMuted,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      teamId: teamId ?? this.teamId,
      departmentId: departmentId ?? this.departmentId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      isMuted: isMuted ?? this.isMuted,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  bool get isDirect => type == 'direct';
  bool get isGroup => type == 'group';
  bool get isTeam => type == 'team';
  bool get isDepartment => type == 'department';
  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [
    id, name, description, type, participants, teamId, departmentId,
    avatarUrl, lastMessage, unreadCount, isActive, isMuted, metadata,
    createdAt, updatedAt, lastActivityAt,
  ];
}

class ChatMessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final String type; // 'text', 'image', 'file', 'system'
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;
  final ChatMessageModel? replyTo;
  final Map<String, List<String>> reactions;
  final DateTime timestamp;
  final DateTime? editedAt;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.type = 'text',
    this.attachments = const [],
    this.metadata = const {},
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    this.replyTo,
    this.reactions = const {},
    required this.timestamp,
    this.editedAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['\$id'] ?? '',
      chatId: map['chat_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      senderName: map['sender_name'] ?? '',
      senderAvatar: map['sender_avatar'],
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      attachments: List<String>.from(map['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      isEdited: map['is_edited'] ?? false,
      isDeleted: map['is_deleted'] ?? false,
      replyToId: map['reply_to_id'],
      replyTo: map['reply_to'] != null ? ChatMessageModel.fromMap(map['reply_to']) : null,
      reactions: Map<String, List<String>>.from(
        (map['reactions'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, List<String>.from(value as List)),
        ) ?? {},
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? map['\$createdAt']),
      editedAt: map['edited_at'] != null ? DateTime.parse(map['edited_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'content': content,
      'type': type,
      'attachments': attachments,
      'metadata': metadata,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'reply_to_id': replyToId,
      'reply_to': replyTo?.toMap(),
      'reactions': reactions,
      'timestamp': timestamp.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    String? type,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    bool? isEdited,
    bool? isDeleted,
    String? replyToId,
    ChatMessageModel? replyTo,
    Map<String, List<String>>? reactions,
    DateTime? timestamp,
    DateTime? editedAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isFile => type == 'file';
  bool get isSystem => type == 'system';
  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasReactions => reactions.isNotEmpty;
  bool get isReply => replyToId != null;

  @override
  List<Object?> get props => [
    id, chatId, senderId, senderName, senderAvatar, content, type,
    attachments, metadata, isEdited, isDeleted, replyToId, replyTo,
    reactions, timestamp, editedAt,
  ];
}

// MessageReaction class removed - using Map<String, List<String>> for reactions
// to simplify the data structure for emoji -> list of user IDs mapping