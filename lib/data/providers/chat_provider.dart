// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../data/services/chat_service.dart';
// import '../../core/constants/api_endpoints.dart';
// import '../../core/utils/storage_helper.dart';
// import '../models/chat_session.dart';

// class ChatProvider extends ChangeNotifier {
//   List<ChatSession> _sessions = [];
//   String _activeSessionId = '';
//   bool _isLoading = false;
//   bool _isSending = false;
//   String? _userId;
//   String? _token;
//   bool _isInitialized = false;
//   String? _lastUserMessage;

//   final ChatService _chatService = ChatService();

//   List<ChatSession> get sessions => _sessions;
//   String get activeSessionId => _activeSessionId;
//   bool get isLoading => _isLoading;
//   bool get isSending => _isSending;
//   bool get isInitialized => _isInitialized;
//   String? get lastUserMessage => _lastUserMessage;

//   List<ChatMessage> get currentMessages {
//     final session = _sessions.firstWhere(
//       (s) => s.id == _activeSessionId,
//       orElse: () => ChatSession(id: '', title: '', messages: [], updatedAt: 0),
//     );
//     return session.messages;
//   }

//   ChatProvider() {
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     await _loadUser();
//     await _loadSessions();
//   }

//   Future<void> _loadUser() async {
//     final user = await StorageHelper.getUser();
//     _token = await StorageHelper.getToken();
//     if (user != null) {
//       _userId = user.userId;
//       print('✅ ChatProvider loaded for user: ${user.name}');
//     }
//   }

//   Future<void> _loadSessions() async {
//     if (_userId == null) {
//       print('❌ Cannot load sessions - No userId');
//       _isInitialized = true;
//       notifyListeners();
//       return;
//     }

//     try {
//       _isLoading = true;
//       notifyListeners();

//       _sessions = await StorageHelper.getChatSessions(_userId!);
//       _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//       print('✅ Loaded ${_sessions.length} chat sessions');

//       if (_sessions.isEmpty) {
//         await _createNewSession();
//       } else {
//         _activeSessionId = _sessions.first.id;
//       }

//       _isInitialized = true;
//       notifyListeners();
//     } catch (e) {
//       print('❌ Error loading sessions: $e');
//       _isInitialized = true;
//       notifyListeners();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _saveSessions() async {
//     if (_userId != null) {
//       await StorageHelper.saveChatSessions(_userId!, _sessions);
//     }
//   }

//   Future<void> _createNewSession() async {
//     final newSession = ChatSession(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       title: 'New chat',
//       messages: [],
//       updatedAt: DateTime.now().millisecondsSinceEpoch,
//     );
//     _sessions.insert(0, newSession);
//     _activeSessionId = newSession.id;
//     await _saveSessions();
//     notifyListeners();
//     print('✅ Created new chat session');
//   }

//   Future<void> createNewSession() async {
//     await _createNewSession();
//   }

//   Future<void> switchSession(String sessionId) async {
//     final session = _sessions.firstWhere((s) => s.id == sessionId);
//     if (session.id.isNotEmpty) {
//       _activeSessionId = sessionId;
//       notifyListeners();
//       print('✅ Switched to session: $sessionId');
//     }
//   }

//   Future<void> renameSession(String sessionId, String newTitle) async {
//     final index = _sessions.indexWhere((s) => s.id == sessionId);
//     if (index != -1) {
//       _sessions[index] = _sessions[index].copyWith(
//         title: newTitle,
//         updatedAt: DateTime.now().millisecondsSinceEpoch,
//       );
//       await _saveSessions();
//       notifyListeners();
//       print('✅ Renamed session to: $newTitle');
//     }
//   }

//   Future<void> deleteSession(String sessionId) async {
//     _sessions.removeWhere((s) => s.id == sessionId);
    
//     if (_sessions.isEmpty) {
//       await _createNewSession();
//     } else if (sessionId == _activeSessionId) {
//       _activeSessionId = _sessions.first.id;
//     }
    
//     await _saveSessions();
//     notifyListeners();
//     print('✅ Deleted session: $sessionId');
//   }

//   Future<void> deleteMessage(int messageIndex) async {
//     final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
//     if (sessionIndex == -1) return;

//     final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
//     newMessages.removeAt(messageIndex);

//     _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
//       messages: newMessages,
//       updatedAt: DateTime.now().millisecondsSinceEpoch,
//     );

//     await _saveSessions();
//     notifyListeners();
//   }

//   Future<void> editMessage(int messageIndex, String newText) async {
//     final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
//     if (sessionIndex == -1) return;

//     final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
//     newMessages[messageIndex] = newMessages[messageIndex].copyWith(content: newText);

//     _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
//       messages: newMessages,
//       updatedAt: DateTime.now().millisecondsSinceEpoch,
//     );

//     await _saveSessions();
//     notifyListeners();
//   }

//   void likeMessage(int messageIndex, bool isLike) {
//     final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
//     if (sessionIndex == -1) return;

//     final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
//     if (isLike) {
//       newMessages[messageIndex] = newMessages[messageIndex].copyWith(isLiked: true, isDisliked: false);
//     } else {
//       newMessages[messageIndex] = newMessages[messageIndex].copyWith(isLiked: false, isDisliked: true);
//     }

//     _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(messages: newMessages);
//     notifyListeners();
//   }

//   /// Send message - SIMPLE request/response (NO STREAMING)
//   Future<void> sendMessage(String text, {String? imageBase64}) async {
//     if (text.trim().isEmpty || _isSending || _userId == null || _token == null) return;

//     _lastUserMessage = text;
    
//     final isFirstMessage = currentMessages.isEmpty;
//     final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    
//     // Add user message
//     final userMessage = ChatMessage(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       role: 'user',
//       content: text,
//       imageBase64: imageBase64,
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//     );

//     final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
//     newMessages.add(userMessage);

//     _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
//       messages: newMessages,
//       updatedAt: DateTime.now().millisecondsSinceEpoch,
//     );
    
//     await _saveSessions();
//     notifyListeners();

//     // Update title if first message
//     if (isFirstMessage) {
//       final newTitle = _generateTitleFromMessage(text);
//       await renameSession(_activeSessionId, newTitle);
//     }

//     _isSending = true;
//     notifyListeners();

//     try {
//       // Determine mode
//       final mode = _detectMode(text, imageBase64 != null);
      
//       // ✅ Simple API call - NO STREAMING
//       final reply = await _chatService.sendMessage(
//         text: text,
//         userId: _userId!,
//         sessionId: _activeSessionId,
//         token: _token!,
//         mode: mode,
//       );

//       // Add bot response
//       final botMessage = ChatMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         role: 'assistant',
//         content: reply,
//         timestamp: DateTime.now().millisecondsSinceEpoch,
//       );

//       final finalSessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
//       if (finalSessionIndex != -1) {
//         final finalMessages = List<ChatMessage>.from(_sessions[finalSessionIndex].messages);
//         finalMessages.add(botMessage);
//         _sessions[finalSessionIndex] = _sessions[finalSessionIndex].copyWith(
//           messages: finalMessages,
//           updatedAt: DateTime.now().millisecondsSinceEpoch,
//         );
//         await _saveSessions();
//       }

//       notifyListeners();
//     } catch (e) {
//       print('❌ Chat error: $e');
      
//       // Add error message
//       final errorMessage = ChatMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         role: 'assistant',
//         content: 'Sorry, I encountered an error: ${e.toString().replaceFirst('Exception: ', '')}',
//         timestamp: DateTime.now().millisecondsSinceEpoch,
//       );

//       final finalSessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
//       if (finalSessionIndex != -1) {
//         final finalMessages = List<ChatMessage>.from(_sessions[finalSessionIndex].messages);
//         finalMessages.add(errorMessage);
//         _sessions[finalSessionIndex] = _sessions[finalSessionIndex].copyWith(
//           messages: finalMessages,
//           updatedAt: DateTime.now().millisecondsSinceEpoch,
//         );
//         await _saveSessions();
//       }
//       notifyListeners();
//     } finally {
//       _isSending = false;
//       notifyListeners();
//     }
//   }

//   String _generateTitleFromMessage(String text) {
//     const maxLength = 30;
//     final cleanText = text.trim();
//     if (cleanText.length <= maxLength) return cleanText;
//     return '${cleanText.substring(0, maxLength)}...';
//   }

//   String _detectMode(String text, bool hasImage) {
//     // If has image, always use cellar mode
//     if (hasImage) return 'cellar';
    
//     final lowerText = text.toLowerCase();
    
//     // Wine-related keywords
//     const wineKeywords = ['wine', 'vinho', 'red', 'white', 'sparkling', 
//                           'cork', 'grape', 'uva', 'pairing', 'harmoniz', 
//                           'cellar', 'adega', 'bottle', 'garrafa'];
    
//     for (final keyword in wineKeywords) {
//       if (lowerText.contains(keyword)) {
//         return 'cellar';
//       }
//     }
    
//     // Default to general mode
//     return 'general';
//   }

//   Future<void> refreshAfterLogin() async {
//     await _loadUser();
//     await _loadSessions();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/chat_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/storage_helper.dart';
import '../models/chat_session.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  String _activeSessionId = '';
  bool _isLoading = false;
  bool _isSending = false;
  String? _userId;
  String? _token;
  bool _isInitialized = false;
  String? _lastUserMessage;

  final ChatService _chatService = ChatService();

  List<ChatSession> get sessions => _sessions;
  String get activeSessionId => _activeSessionId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isInitialized => _isInitialized;
  String? get lastUserMessage => _lastUserMessage;

  List<ChatMessage> get currentMessages {
    final session = _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => ChatSession(id: '', title: '', messages: [], updatedAt: 0),
    );
    return session.messages;
  }

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUser();
    await _loadSessions();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    _token = await StorageHelper.getToken();
    if (user != null) {
      _userId = user.userId;
      print('✅ ChatProvider loaded for user: ${user.name}');
    }
  }

  Future<void> _loadSessions() async {
    if (_userId == null) {
      print('❌ Cannot load sessions - No userId');
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // ✅ Try to load from backend first
      if (_token != null) {
        try {
          final backendChats = await _chatService.getChats(token: _token!);
          if (backendChats.isNotEmpty) {
            _sessions = backendChats.map((chat) {
              try {
                return ChatSession.fromJson(chat);
              } catch (e) {
                print('❌ Error parsing chat: $e');
                return null;
              }
            }).whereType<ChatSession>().toList();
            
            _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            print('✅ Loaded ${_sessions.length} chats from backend');
            
            // Save to local storage for offline access
            await StorageHelper.saveChatSessions(_userId!, _sessions);
          } else {
            // Fallback to local storage
            _sessions = await StorageHelper.getChatSessions(_userId!);
            _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            print('✅ Loaded ${_sessions.length} chats from local storage');
          }
        } catch (e) {
          print('❌ Error loading from backend, falling back to local: $e');
          _sessions = await StorageHelper.getChatSessions(_userId!);
          _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        }
      } else {
        _sessions = await StorageHelper.getChatSessions(_userId!);
        _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }

      if (_sessions.isEmpty) {
        await _createNewSession();
      } else {
        _activeSessionId = _sessions.first.id;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading sessions: $e');
      _isInitialized = true;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSessions() async {
    if (_userId != null) {
      await StorageHelper.saveChatSessions(_userId!, _sessions);
    }
  }

  /// Sync current session to backend
  Future<void> _saveChatToBackend() async {
    if (_userId == null || _token == null) return;

    try {
      final session = _sessions.firstWhere(
        (s) => s.id == _activeSessionId,
        orElse: () => ChatSession(id: '', title: '', messages: [], updatedAt: 0),
      );
      
      if (session.id.isEmpty) return;

      await _chatService.saveChat(
        token: _token!,
        chatId: session.id,
        title: session.title,
        messages: session.messages.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      print('❌ Failed to sync chat to backend: $e');
    }
  }

  Future<void> _createNewSession() async {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New chat',
      messages: [],
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _sessions.insert(0, newSession);
    _activeSessionId = newSession.id;
    await _saveSessions();
    await _saveChatToBackend();
    notifyListeners();
    print('✅ Created new chat session');
  }

  Future<void> createNewSession() async {
    await _createNewSession();
  }

  Future<void> switchSession(String sessionId) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    if (session.id.isNotEmpty) {
      _activeSessionId = sessionId;
      notifyListeners();
      print('✅ Switched to session: $sessionId');
    }
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        title: newTitle,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _saveSessions();
      await _saveChatToBackend();
      notifyListeners();
      print('✅ Renamed session to: $newTitle');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    
    if (_token != null) {
      await _chatService.deleteChat(token: _token!, chatId: sessionId);
    }
    
    if (_sessions.isEmpty) {
      await _createNewSession();
    } else if (sessionId == _activeSessionId) {
      _activeSessionId = _sessions.first.id;
    }
    
    await _saveSessions();
    notifyListeners();
    print('✅ Deleted session: $sessionId');
  }

  Future<void> deleteMessage(int messageIndex) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
    newMessages.removeAt(messageIndex);

    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
      messages: newMessages,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveSessions();
    await _saveChatToBackend();
    notifyListeners();
  }

  Future<void> editMessage(int messageIndex, String newText) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
    newMessages[messageIndex] = newMessages[messageIndex].copyWith(content: newText);

    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
      messages: newMessages,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _saveSessions();
    await _saveChatToBackend();
    notifyListeners();
  }

  void likeMessage(int messageIndex, bool isLike) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
    if (isLike) {
      newMessages[messageIndex] = newMessages[messageIndex].copyWith(isLiked: true, isDisliked: false);
    } else {
      newMessages[messageIndex] = newMessages[messageIndex].copyWith(isLiked: false, isDisliked: true);
    }

    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(messages: newMessages);
    notifyListeners();
  }

  /// Send message - with backend sync
  Future<void> sendMessage(String text, {String? imageBase64}) async {
    if (text.trim().isEmpty || _isSending || _userId == null || _token == null) return;

    _lastUserMessage = text;
    
    final isFirstMessage = currentMessages.isEmpty;
    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text,
      imageBase64: imageBase64,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final newMessages = List<ChatMessage>.from(_sessions[sessionIndex].messages);
    newMessages.add(userMessage);

    _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
      messages: newMessages,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    await _saveSessions();
    await _saveChatToBackend();
    notifyListeners();

    if (isFirstMessage) {
      final newTitle = _generateTitleFromMessage(text);
      await renameSession(_activeSessionId, newTitle);
    }

    _isSending = true;
    notifyListeners();

    try {
      final mode = _detectMode(text, imageBase64 != null);
      
      final reply = await _chatService.sendMessage(
        text: text,
        userId: _userId!,
        sessionId: _activeSessionId,
        token: _token!,
        mode: mode,
      );

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: reply,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final finalSessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
      if (finalSessionIndex != -1) {
        final finalMessages = List<ChatMessage>.from(_sessions[finalSessionIndex].messages);
        finalMessages.add(botMessage);
        _sessions[finalSessionIndex] = _sessions[finalSessionIndex].copyWith(
          messages: finalMessages,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _saveSessions();
        await _saveChatToBackend();
      }

      notifyListeners();
    } catch (e) {
      print('❌ Chat error: $e');
      
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'Sorry, I encountered an error: ${e.toString().replaceFirst('Exception: ', '')}',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final finalSessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
      if (finalSessionIndex != -1) {
        final finalMessages = List<ChatMessage>.from(_sessions[finalSessionIndex].messages);
        finalMessages.add(errorMessage);
        _sessions[finalSessionIndex] = _sessions[finalSessionIndex].copyWith(
          messages: finalMessages,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _saveSessions();
        await _saveChatToBackend();
      }
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  String _generateTitleFromMessage(String text) {
    const maxLength = 30;
    final cleanText = text.trim();
    if (cleanText.length <= maxLength) return cleanText;
    return '${cleanText.substring(0, maxLength)}...';
  }

  String _detectMode(String text, bool hasImage) {
    if (hasImage) return 'cellar';
    
    final lowerText = text.toLowerCase();
    const wineKeywords = ['wine', 'vinho', 'red', 'white', 'sparkling', 
                          'cork', 'grape', 'uva', 'pairing', 'harmoniz', 
                          'cellar', 'adega', 'bottle', 'garrafa'];
    
    for (final keyword in wineKeywords) {
      if (lowerText.contains(keyword)) {
        return 'cellar';
      }
    }
    
    return 'general';
  }

  Future<void> refreshAfterLogin() async {
    await _loadUser();
    await _loadSessions();
  }

  @override
  void dispose() {
    super.dispose();
  }
}