import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../services/chat_service.dart';
import '../../core/utils/storage_helper.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  String _activeSessionId = '';
  bool _isLoading = false;
  String? _userId;

  final ChatService _chatService = ChatService();

  List<ChatSession> get sessions => _sessions;
  String get activeSessionId => _activeSessionId;
  bool get isLoading => _isLoading;
  List<ChatMessage> get currentMessages {
    final session = _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => ChatSession(id: '', messages: []),
    );
    return session.messages;
  }

  ChatProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user.userId;
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    if (_userId == null) return;
    final sessions = await StorageHelper.getChatSessions(_userId!);
    _sessions = sessions;
    
    if (_sessions.isEmpty) {
      _createNewSession();
    } else {
      _activeSessionId = _sessions.first.id;
    }
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    if (_userId == null) return;
    await StorageHelper.saveChatSessions(_userId!, _sessions);
  }

  Future<void> _createNewSession() async {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messages: [],
    );
    _sessions.insert(0, newSession);
    _activeSessionId = newSession.id;
    await _saveSessions();
    notifyListeners();
  }

  Future<void> createNewSession() async {
    await _createNewSession();
  }

  Future<void> switchSession(String sessionId) async {
    if (_sessions.any((s) => s.id == sessionId)) {
      _activeSessionId = sessionId;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _userId == null) return;

    // Add user message
    await _addMessage('user', text);

    _setLoading(true);

    try {
      final token = await StorageHelper.getToken();
      if (token == null) throw Exception('No authentication token');

      final reply = await _chatService.sendMessage(
        text: text,
        userId: _userId!,
        sessionId: _activeSessionId,
        token: token,
      );

      // Add bot reply
      await _addMessage('bot', reply);
    } catch (e) {
      String errorMessage = '⚠️ Sorry, I couldn\'t process your request. Please try again.';
      
      if (e.toString().contains('Unauthorized') || e.toString().contains('authentication')) {
        errorMessage = '⚠️ Your session has expired. Please login again.';
      } else if (e.toString().contains('failed')) {
        errorMessage = '⚠️ The chat service is currently unavailable. Please try again later.';
      }

      await _addMessage('bot', errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _addMessage(String type, String text) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (sessionIndex == -1) return;

    final updatedSession = ChatSession(
      id: _sessions[sessionIndex].id,
      messages: [
        ..._sessions[sessionIndex].messages,
        ChatMessage(type: type, text: text),
      ],
    );

    _sessions[sessionIndex] = updatedSession;
    await _saveSessions();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    
    if (_sessions.isEmpty) {
      await _createNewSession();
    } else if (sessionId == _activeSessionId) {
      _activeSessionId = _sessions.first.id;
    }
    
    await _saveSessions();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}