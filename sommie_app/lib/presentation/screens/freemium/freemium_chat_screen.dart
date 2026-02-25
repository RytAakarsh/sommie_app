import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../core/utils/speech_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import 'free_edit_profile_screen.dart';
import 'free_cellar_screen.dart';
import '../../../routes/app_routes.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../translations/translations_extension.dart';

class FreemiumChatScreen extends StatefulWidget {
  const FreemiumChatScreen({super.key});

  @override
  State<FreemiumChatScreen> createState() => _FreemiumChatScreenState();
}

class _FreemiumChatScreenState extends State<FreemiumChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isSidebarOpen = false;
  bool _isProfileMenuOpen = false;
  bool _isSearchOpen = false;
  String _searchQuery = '';
  
  // Speech recognition
  bool _isListening = false;
  String _speechError = '';
  final SpeechHelper _speechHelper = SpeechHelper();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speechHelper.initialize();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechHelper.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _speechError = '';
        _isListening = true;
      });

      await _speechHelper.startListening(
        onResult: (text) {
          setState(() {
            _inputController.text = text;
          });
        },
        onListening: () {},
        localeId: Provider.of<LanguageProvider>(context, listen: false)
                .currentLanguage == 'pt' 
            ? 'pt_BR' 
            : 'en_US',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: CustomAppBar(
        title: 'Sommie',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
              });
            },
          ),
          if (user?.plan != 'PRO')
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.proPlanFlow);
              },
              child: const Text(
                'Upgrade to PRO',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSidebarOpen ? 280 : 0,
                child: _isSidebarOpen
                    ? _buildSidebar(context, chatProvider, user)
                    : null,
              ),
              
              // Main Chat Area
              Expanded(
                child: Column(
                  children: [
                    // Search Bar (if open)
                    if (_isSearchOpen)
                      _buildSearchBar(),
                    
                    // Messages
                    Expanded(
                      child: _buildMessagesList(context, chatProvider),
                    ),
                    
                    // Input Bar
                    _buildInputBar(context, chatProvider),
                  ],
                ),
              ),
            ],
          ),
          
          // Mobile menu button
          if (!_isSidebarOpen)
            Positioned(
              left: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF4B2B5F)),
                onPressed: () {
                  setState(() {
                    _isSidebarOpen = true;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ChatProvider chatProvider, user) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // New Chat Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                chatProvider.createNewSession();
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B2B5F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(context.tr('chat.newChat')),
                ],
              ),
            ),
          ),
          
          // Chat History
          Expanded(
            child: ListView.builder(
              itemCount: chatProvider.sessions.length,
              itemBuilder: (context, index) {
                final session = chatProvider.sessions[index];
                final firstMessage = session.messages.isNotEmpty
                    ? session.messages.first.text
                    : 'New chat';
                    
                return ListTile(
                  selected: session.id == chatProvider.activeSessionId,
                  selectedTileColor: const Color(0xFFF3E8FF),
                  title: Text(
                    firstMessage.length > 30
                        ? '${firstMessage.substring(0, 30)}...'
                        : firstMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    chatProvider.switchSession(session.id);
                    setState(() {
                      _isSidebarOpen = false;
                    });
                  },
                  onLongPress: () {
                    _showDeleteDialog(context, session.id);
                  },
                );
              },
            ),
          ),
          
          // User Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user?.avatar != null
                      ? NetworkImage(user!.avatar!)
                      : const AssetImage('assets/images/avatar.webp') as ImageProvider,
                  child: user?.avatar == null
                      ? Text(user?.name?.substring(0, 1) ?? 'G')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.role ?? 'Free User',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreeEditProfileScreen(
                            onBack: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    } else if (value == 'cellar') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreeCellarScreen(
                            setView: (view) {
                              Navigator.pop(context);
                              if (view == 'chat') return;
                              // Handle other views
                            },
                          ),
                        ),
                      );
                    } else if (value == 'logout') {
                      await Provider.of<AuthProvider>(context, listen: false).logout();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('Edit Profile'),
                    ),
                    const PopupMenuItem(
                      value: 'cellar',
                      child: Text('Wine Cellar'),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: context.tr('chat.searchPlaceholder'),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatProvider chatProvider) {
    final messages = chatProvider.currentMessages;

    if (messages.isEmpty) {
      return SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFF3E8FF),
                child: const Icon(
                  Icons.wine_bar,
                  size: 60,
                  color: Color(0xFF4B2B5F),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('chat.welcome'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('chat.description'),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.type == 'user';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF4B2B5F),
                  child: Icon(Icons.wine_bar, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF7f488b)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message.text,
                          style: const TextStyle(color: Colors.white),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 14),
                          ),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar(BuildContext context, ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mic button
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening
                  ? Colors.red
                  : const Color(0xFF4B2B5F),
            ),
            onPressed: _toggleListening,
          ),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Listening...'
                    : context.tr('chat.placeholder'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(chatProvider),
            ),
          ),
          
          // Send button
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFF4B2B5F),
            onPressed: () => _sendMessage(chatProvider),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider chatProvider) {
    if (_inputController.text.trim().isEmpty) return;
    
    chatProvider.sendMessage(_inputController.text);
    _inputController.clear();
    _scrollToBottom();
    
    if (_isListening) {
      _toggleListening();
    }
  }

  void _showDeleteDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('chat.delete')),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false)
                  .deleteSession(sessionId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.tr('chat.delete')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _speechHelper.dispose();
    super.dispose();
  }
}