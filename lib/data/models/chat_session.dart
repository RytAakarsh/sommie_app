// class ChatMessage {
//   final String id;
//   final String role; // "user" or "assistant"
//   final String content;
//   final String? imageBase64;
//   final int timestamp;
//   bool? isLiked;
//   bool? isDisliked;

//   ChatMessage({
//     required this.id,
//     required this.role,
//     required this.content,
//     this.imageBase64,
//     required this.timestamp,
//     this.isLiked,
//     this.isDisliked,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       role: json['role'] ?? json['type'] ?? 'user',
//       content: json['content'] ?? json['text'] ?? '',
//       imageBase64: json['imageBase64'],
//       timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
//       isLiked: json['isLiked'],
//       isDisliked: json['isDisliked'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'role': role,
//       'content': content,
//       'imageBase64': imageBase64,
//       'timestamp': timestamp,
//       'isLiked': isLiked,
//       'isDisliked': isDisliked,
//     };
//   }

//   ChatMessage copyWith({
//     String? id,
//     String? role,
//     String? content,
//     String? imageBase64,
//     int? timestamp,
//     bool? isLiked,
//     bool? isDisliked,
//   }) {
//     return ChatMessage(
//       id: id ?? this.id,
//       role: role ?? this.role,
//       content: content ?? this.content,
//       imageBase64: imageBase64 ?? this.imageBase64,
//       timestamp: timestamp ?? this.timestamp,
//       isLiked: isLiked ?? this.isLiked,
//       isDisliked: isDisliked ?? this.isDisliked,
//     );
//   }
// }

// class ChatSession {
//   final String id;
//   final String title;
//   final List<ChatMessage> messages;
//   final int updatedAt;
//   final String? lastMessage;

//   ChatSession({
//     required this.id,
//     required this.title,
//     required this.messages,
//     required this.updatedAt,
//     this.lastMessage,
//   });

//   factory ChatSession.fromJson(Map<String, dynamic> json) {
//     return ChatSession(
//       id: json['id'] ?? json['chatId'] ?? '',
//       title: json['title'] ?? 'New chat',
//       messages: (json['messages'] as List? ?? [])
//           .map((m) => ChatMessage.fromJson(m))
//           .toList(),
//       updatedAt: json['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
//       lastMessage: json['lastMessage'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'messages': messages.map((m) => m.toJson()).toList(),
//       'updatedAt': updatedAt,
//       'lastMessage': lastMessage,
//     };
//   }

//   ChatSession copyWith({
//     String? id,
//     String? title,
//     List<ChatMessage>? messages,
//     int? updatedAt,
//     String? lastMessage,
//   }) {
//     return ChatSession(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       messages: messages ?? this.messages,
//       updatedAt: updatedAt ?? this.updatedAt,
//       lastMessage: lastMessage ?? this.lastMessage,
//     );
//   }
// }




class ChatMessage {
  final String id;
  final String role; // "user" or "assistant"
  final String content;
  final String? imageBase64;
  final int timestamp;
  bool? isLiked;
  bool? isDisliked;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.imageBase64,
    required this.timestamp,
    this.isLiked,
    this.isDisliked,
  });

  /// ✅ Helper function to parse timestamp from String or int
  static int _parseTimestamp(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch;
      } catch (e) {
        print('Error parsing timestamp: $e');
        return DateTime.now().millisecondsSinceEpoch;
      }
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] ?? json['type'] ?? 'user',
      content: json['content'] ?? json['text'] ?? '',
      imageBase64: json['imageBase64'],
      timestamp: _parseTimestamp(json['timestamp']),
      isLiked: json['isLiked'],
      isDisliked: json['isDisliked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'imageBase64': imageBase64,
      'timestamp': timestamp,
      'isLiked': isLiked,
      'isDisliked': isDisliked,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    String? imageBase64,
    int? timestamp,
    bool? isLiked,
    bool? isDisliked,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      imageBase64: imageBase64 ?? this.imageBase64,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isDisliked: isDisliked ?? this.isDisliked,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final int updatedAt;
  final String? lastMessage;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.lastMessage,
  });

  /// ✅ Helper function to parse timestamp from String or int
  static int _parseTimestamp(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch;
      } catch (e) {
        print('Error parsing timestamp: $e');
        return DateTime.now().millisecondsSinceEpoch;
      }
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    // Parse messages safely
    List<ChatMessage> parsedMessages = [];
    final messagesData = json['messages'] as List? ?? [];
    for (var msg in messagesData) {
      try {
        parsedMessages.add(ChatMessage.fromJson(msg));
      } catch (e) {
        print('Error parsing message: $e');
      }
    }

    return ChatSession(
      id: json['id'] ?? json['chatId'] ?? '',
      title: json['title'] ?? 'New chat',
      messages: parsedMessages,
      updatedAt: _parseTimestamp(json['updatedAt']),
      lastMessage: json['lastMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'updatedAt': updatedAt,
      'lastMessage': lastMessage,
    };
  }

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    int? updatedAt,
    String? lastMessage,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
