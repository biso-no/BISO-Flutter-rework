import 'package:appwrite/appwrite.dart';
import 'dart:async';

import '../../core/constants/app_constants.dart';
import '../models/chat_model.dart';
import 'appwrite_service.dart';

class ChatService {
  RealtimeSubscription? _subscription;
  final StreamController<List<ChatModel>> _chatsController = StreamController<List<ChatModel>>.broadcast();
  final StreamController<List<ChatMessageModel>> _messagesController = StreamController<List<ChatMessageModel>>.broadcast();
  
  // Using simplified global Appwrite instances
  Databases get _databases => databases;
  Realtime get _realtime => realtime;

  Stream<List<ChatModel>> get chatsStream => _chatsController.stream;
  Stream<List<ChatMessageModel>> get messagesStream => _messagesController.stream;

  // Get user's chats
  Future<List<ChatModel>> getUserChats(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        queries: [
          Query.contains('participants', userId),
          Query.equal('is_active', true),
          Query.orderDesc('last_activity_at'),
        ],
      );

      final chats = response.documents
          .map((doc) => ChatModel.fromMap(doc.data))
          .toList();

      _chatsController.add(chats);
      return chats;
    } on AppwriteException catch (e) {
      throw ChatException('Failed to fetch chats: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Get messages for a specific chat
  Future<List<ChatMessageModel>> getChatMessages({
    required String chatId,
    int limit = AppConstants.defaultPageSize,
    String? offset,
  }) async {
    try {
      List<String> queries = [
        Query.equal('chat_id', chatId),
        Query.orderDesc('timestamp'),
        Query.limit(limit),
      ];

      if (offset != null) {
        queries.add(Query.cursorAfter(offset));
      }

      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        queries: queries,
      );

      return response.documents
          .map((doc) => ChatMessageModel.fromMap(doc.data))
          .toList()
          .reversed // Reverse to show oldest first
          .toList();
    } on AppwriteException catch (e) {
      throw ChatException('Failed to fetch messages: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Send a message
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
    List<String> attachments = const [],
    String? replyToId,
  }) async {
    try {
      final messageData = {
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_name': senderName,
        'content': content,
        'type': type,
        'attachments': attachments,
        'reply_to_id': replyToId,
        'timestamp': DateTime.now().toIso8601String(),
        'is_edited': false,
        'is_deleted': false,
        'reactions': [],
        'metadata': {},
      };

      final doc = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        documentId: ID.unique(),
        data: messageData,
      );

      final message = ChatMessageModel.fromMap(doc.data);

      // Update chat's last message and activity
      await _updateChatLastMessage(chatId, message);

      return message;
    } on AppwriteException catch (e) {
      throw ChatException('Failed to send message: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Create a new chat
  Future<ChatModel> createChat({
    required String name,
    required List<String> participants,
    String type = 'group',
    String? description,
    String? teamId,
    String? departmentId,
  }) async {
    try {
      final chatData = {
        'name': name,
        'description': description,
        'type': type,
        'participants': participants,
        'team_id': teamId,
        'department_id': departmentId,
        'is_active': true,
        'is_muted': false,
        'unread_count': 0,
        'metadata': {},
        'last_activity_at': DateTime.now().toIso8601String(),
      };

      final doc = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: ID.unique(),
        data: chatData,
      );

      return ChatModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      throw ChatException('Failed to create chat: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Start real-time subscription for chats and messages
  void subscribeToUpdates(String userId) {
    try {
      _subscription = _realtime.subscribe([
        'databases.${AppConstants.databaseId}.collections.chats.documents',
        'databases.${AppConstants.databaseId}.collections.chat_messages.documents',
      ]);

      _subscription!.stream.listen((response) {
        final payload = response.payload;
        
        if (response.channels.contains('databases.${AppConstants.databaseId}.collections.chat_messages.documents')) {
          _handleMessageUpdate(payload);
        } else if (response.channels.contains('databases.${AppConstants.databaseId}.collections.chats.documents')) {
          _handleChatUpdate(payload, userId);
        }
      });
    } catch (e) {
      throw ChatException('Failed to subscribe to updates: $e');
    }
  }

  // Add user to chat
  Future<void> addUserToChat(String chatId, String userId) async {
    try {
      final chat = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: chatId,
      );

      final participants = List<String>.from(chat.data['participants']);
      if (!participants.contains(userId)) {
        participants.add(userId);

        await _databases.updateDocument(
          databaseId: AppConstants.databaseId,
          collectionId: 'chats',
          documentId: chatId,
          data: {'participants': participants},
        );
      }
    } on AppwriteException catch (e) {
      throw ChatException('Failed to add user to chat: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Remove user from chat
  Future<void> removeUserFromChat(String chatId, String userId) async {
    try {
      final chat = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: chatId,
      );

      final participants = List<String>.from(chat.data['participants']);
      participants.remove(userId);

      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: chatId,
        data: {'participants': participants},
      );
    } on AppwriteException catch (e) {
      throw ChatException('Failed to remove user from chat: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: chatId,
        data: {
          'unread_count': 0,
          'metadata': {
            'last_read_by_$userId': DateTime.now().toIso8601String(),
          },
        },
      );
    } on AppwriteException catch (e) {
      throw ChatException('Failed to mark as read: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Edit message
  Future<ChatMessageModel> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      final doc = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        documentId: messageId,
        data: {
          'content': newContent,
          'is_edited': true,
          'edited_at': DateTime.now().toIso8601String(),
        },
      );

      return ChatMessageModel.fromMap(doc.data);
    } on AppwriteException catch (e) {
      throw ChatException('Failed to edit message: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        documentId: messageId,
        data: {
          'is_deleted': true,
          'content': 'This message has been deleted',
        },
      );
    } on AppwriteException catch (e) {
      throw ChatException('Failed to delete message: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Add reaction to message
  Future<void> addReaction({
    required String messageId,
    required String emoji,
    required String userId,
    required String userName,
  }) async {
    try {
      final message = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        documentId: messageId,
      );

      final reactions = List<Map<String, dynamic>>.from(message.data['reactions'] ?? []);
      
      // Remove existing reaction from same user with same emoji
      reactions.removeWhere((r) => r['user_id'] == userId && r['emoji'] == emoji);
      
      // Add new reaction
      reactions.add({
        'emoji': emoji,
        'user_id': userId,
        'user_name': userName,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        documentId: messageId,
        data: {'reactions': reactions},
      );
    } on AppwriteException catch (e) {
      throw ChatException('Failed to add reaction: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Search messages
  Future<List<ChatMessageModel>> searchMessages({
    required String chatId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'chat_messages',
        queries: [
          Query.equal('chat_id', chatId),
          Query.search('content', query),
          Query.orderDesc('timestamp'),
          Query.limit(limit),
        ],
      );

      return response.documents
          .map((doc) => ChatMessageModel.fromMap(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      throw ChatException('Failed to search messages: ${e.message}');
    } catch (e) {
      throw ChatException('Network error occurred');
    }
  }

  // Private helper methods
  Future<void> _updateChatLastMessage(String chatId, ChatMessageModel message) async {
    try {
      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: chatId,
        data: {
          'last_message': message.toMap(),
          'last_activity_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Don't throw, as this is a secondary operation
      // Failed to update last message: $e
    }
  }

  void _handleMessageUpdate(Map<String, dynamic> payload) {
    try {
      final message = ChatMessageModel.fromMap(payload);
      // For now, we'll just add a single message as a list
      // In a full implementation, you'd maintain the current list and add to it
      _messagesController.add([message]);
    } catch (e) {
      // Error handling message update: $e
    }
  }

  void _handleChatUpdate(Map<String, dynamic> payload, String userId) {
    try {
      final chat = ChatModel.fromMap(payload);
      if (chat.participants.contains(userId)) {
        // Refresh chats list
        getUserChats(userId);
      }
    } catch (e) {
      // Error handling chat update: $e
    }
  }

  // Create group chat
  Future<ChatModel> createGroupChat({
    required String name,
    required List<String> participants,
    required String createdBy,
  }) async {
    try {
      final chatData = {
        'name': name,
        'type': 'group',
        'participants': participants,
        'is_active': true,
        'created_by': createdBy,
        'last_activity_at': DateTime.now().toIso8601String(),
      };

      final response = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: ID.unique(),
        data: chatData,
      );

      return ChatModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  // Create direct chat
  Future<ChatModel> createDirectChat({
    required List<String> participants,
  }) async {
    try {
      // Check if direct chat already exists between these participants
      final existingChats = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        queries: [
          Query.equal('type', 'direct'),
          Query.contains('participants', participants[0]),
          Query.contains('participants', participants[1]),
        ],
      );

      if (existingChats.documents.isNotEmpty) {
        return ChatModel.fromMap(existingChats.documents.first.data);
      }

      // Create new direct chat
      final chatData = {
        'name': 'Direct Chat',
        'type': 'direct',
        'participants': participants,
        'is_active': true,
        'created_by': participants[0],
        'last_activity_at': DateTime.now().toIso8601String(),
      };

      final response = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'chats',
        documentId: ID.unique(),
        data: chatData,
      );

      return ChatModel.fromMap(response.data);
    } catch (e) {
      throw Exception('Failed to create direct chat: $e');
    }
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String chatId, String userId, bool isTyping) async {
    try {
      // TODO: Implement typing indicator via Appwrite realtime
      // For now, this is a placeholder method
    } catch (e) {
      // Typing indicator error: $e
    }
  }

  // React to message
  Future<void> reactToMessage({
    required String messageId,
    required String userId,
    required String reaction,
  }) async {
    try {
      // TODO: Implement message reactions
      // This would update the message document in Appwrite
      // to add/remove the user from the reaction list
    } catch (e) {
      throw Exception('Failed to react to message: $e');
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      // TODO: Implement marking chat as read
      // This would update the user's read status for the chat
    } catch (e) {
      // Mark as read error: $e
    }
  }

  // Clean up resources
  void dispose() {
    _subscription?.close();
    _chatsController.close();
    _messagesController.close();
  }
}

class ChatException implements Exception {
  final String message;
  ChatException(this.message);

  @override
  String toString() => message;
}