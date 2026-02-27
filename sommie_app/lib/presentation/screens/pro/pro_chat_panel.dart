import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../core/utils/speech_helper.dart';
import '../../../routes/app_routes.dart';

class ProChatPanel extends StatefulWidget {
  const ProChatPanel({super.key});

  @override
  State<ProChatPanel> createState() => _ProChatPanelState();
}

class _ProChatPanelState extends State<ProChatPanel> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechHelper _speech = SpeechHelper();
  final FocusNode _focusNode = FocusNode();

  bool _isSidebarOpen = false;
  bool _isListening = false;
  bool _isAiTyping = false;
  String _searchQuery = '';

  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarAnim;

  @override
  void initState() {
    super.initState();
    _speech.initialize();

    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _sidebarAnim = Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeOut),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      _isSidebarOpen ? _sidebarController.forward() : _sidebarController.reverse();
    });
  }

  void _closeSidebar() {
    if (_isSidebarOpen) {
      setState(() {
        _isSidebarOpen = false;
        _sidebarController.reverse();
      });
    }
  }

  void _sendMessage(ChatProvider chat) async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() => _isAiTyping = true);

    await chat.sendMessage(_inputController.text);
    _inputController.clear();
    _focusNode.unfocus();

    setState(() => _isAiTyping = false);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final isPT = languageProvider.currentLanguage == 'pt';

    return GestureDetector(
      onTap: _closeSidebar,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7FC),
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Single header for chat
                Container(
                  height: 70,
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Menu icon
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF4B2B5F), size: 28),
                        onPressed: _toggleSidebar,
                      ),
                      const Spacer(),
                      // Centered Logo
                      Image.asset(
                        'assets/images/pro-logo.png',
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => const Text(
                          'SOMMIE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7f488b),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Language toggle on right
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4E9FF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageChip(
                              'EN',
                              !isPT,
                              () => languageProvider.setLanguage('en'),
                            ),
                            _buildLanguageChip(
                              'PT',
                              isPT,
                              () => languageProvider.setLanguage('pt'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildMessages(chatProvider, isPT, user),
                            ),
                            // Input bar positioned above bottom nav
                            _buildInputBar(chatProvider, isPT),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom Navigation
                _buildBottomNav(viewProvider, isPT),
              ],
            ),

            // Sidebar overlay
            if (_isSidebarOpen)
              GestureDetector(
                onTap: _closeSidebar,
                child: Container(color: Colors.black26),
              ),

            // Sidebar
            if (_isSidebarOpen)
              SlideTransition(
                position: _sidebarAnim,
                child: Material(
                  elevation: 12,
                  child: Container(
                    width: 300,
                    color: Colors.white,
                    child: _buildSidebar(chatProvider, user, isPT, authProvider, viewProvider),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(ProViewProvider viewProvider, bool isPT) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: isPT ? 'Início' : 'Home',
            isSelected: viewProvider.currentView == ProView.dashboard,
            onTap: () {
              viewProvider.setView(ProView.dashboard);
            },
          ),
          _buildNavItem(
            icon: Icons.wine_bar,
            label: isPT ? 'Adega' : 'Cellar',
            isSelected: viewProvider.currentView == ProView.cellar,
            onTap: () {
              viewProvider.setView(ProView.cellar);
            },
          ),
          _buildNavItem(
            icon: Icons.chat,
            label: isPT ? 'Chat' : 'Chat',
            isSelected: viewProvider.currentView == ProView.chat,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.card_giftcard,
            label: isPT ? 'Benefícios' : 'Benefits',
            isSelected: viewProvider.currentView == ProView.benefits,
            onTap: () {
              viewProvider.setView(ProView.benefits);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isSelected ? const Color(0xFF4B2B5F) : Colors.grey, 
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4B2B5F) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String text, bool isSelected, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B2B5F) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4B2B5F),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(ChatProvider chat, user, bool isPT, AuthProvider auth, ProViewProvider viewProvider) {
    return Column(
      children: [
        const SizedBox(height: 50),
        
        // Profile section
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                  image: user?.avatar != null && user!.avatar!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(user.avatar!), fit: BoxFit.cover)
                      : null,
                ),
                child: user?.avatar == null || user!.avatar!.isEmpty
                    ? Center(
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'A',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B2B5F)),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isPT ? 'Usuário PRO' : 'PRO User',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6D3FA6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // New Chat Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              chat.createNewSession();
              _closeSidebar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7f488b),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(isPT ? 'Nova Conversa' : 'New Chat'),
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: isPT ? 'Buscar conversas...' : 'Search chats...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),

        // Chat History
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chat.sessions.length,
            itemBuilder: (context, index) {
              final session = chat.sessions[index];
              final firstMsg = session.messages.isNotEmpty
                  ? session.messages.first.text
                  : (isPT ? 'Nova conversa' : 'New chat');
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF4B2B5F)),
                ),
                selected: session.id == chat.activeSessionId,
                selectedTileColor: const Color(0xFFF3E8FF),
                title: Text(
                  firstMsg.length > 25 ? '${firstMsg.substring(0, 25)}...' : firstMsg,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: session.id == chat.activeSessionId ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  chat.switchSession(session.id);
                  _closeSidebar();
                },
                onLongPress: () => _showDeleteDialog(context, session.id, isPT),
              );
            },
          ),
        ),

        // Logout button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                  label: Text(
                    isPT ? 'Sair' : 'Logout',
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessages(ChatProvider chat, bool isPT, user) {
    if (chat.currentMessages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/avatar.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPT
                    ? 'Olá, sou a Sommie, sua sommelière virtual!'
                    : "Hi, I'm Sommie, your virtual sommelier!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4B2B5F)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isPT
                    ? 'Sou uma IA apaixonada por vinhos — posso responder perguntas, sugerir harmonizações, compartilhar curiosidades sobre uvas, regiões, vinícolas e recomendar os melhores rótulos para o seu paladar.'
                    : "I'm an AI passionate about wines — I can answer questions, suggest pairings, share curiosities about grapes, regions, wineries, and recommend the best labels for your palate.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 80, // Space for input bar and bottom nav
      ),
      itemCount: chat.currentMessages.length + (_isAiTyping ? 1 : 0),
      itemBuilder: (context, i) {
        if (_isAiTyping && i == chat.currentMessages.length) {
          return _buildTypingIndicator();
        }

        final message = chat.currentMessages[i];
        final isUser = message.type == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                // AI Avatar (Amelie)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/avatar.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF7f488b) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: isUser
                      ? Row(
                          children: [
                            Expanded(
                              child: Text(
                                message.text,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // User Avatar next to user message
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                shape: BoxShape.circle,
                                image: user?.avatar != null && user!.avatar!.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(user.avatar!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: user?.avatar == null || user!.avatar!.isEmpty
                                  ? Center(
                                      child: Text(
                                        user?.name?.substring(0, 1).toUpperCase() ?? 'A',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B2B5F)),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 15, color: Colors.black87),
                            strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B2B5F)),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                _buildTypingDot(150),
                _buildTypingDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF7f488b),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(ChatProvider chat, bool isPT) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.close : Icons.mic, color: const Color(0xFF7f488b), size: 24),
            onPressed: () async {
              if (_isListening) {
                await _speech.stopListening();
                setState(() => _isListening = false);
              } else {
                await _speech.startListening(
                  onResult: (txt) => setState(() => _inputController.text += txt),
                  onListening: () => setState(() => _isListening = true),
                );
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: isPT ? 'Pergunte-me qualquer coisa...' : 'Ask me anything...',
                hintStyle: const TextStyle(fontSize: 15),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _sendMessage(chat),
            ),
          ),
          GestureDetector(
            onTap: _inputController.text.trim().isEmpty ? null : () => _sendMessage(chat),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _inputController.text.trim().isEmpty
                    ? Colors.grey.shade300
                    : const Color(0xFF7f488b),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: _inputController.text.trim().isEmpty ? Colors.grey.shade500 : Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String sessionId, bool isPT) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPT ? 'Excluir conversa' : 'Delete chat'),
        content: Text(isPT
            ? 'Tem certeza que deseja excluir esta conversa?'
            : 'Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isPT ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).deleteSession(sessionId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isPT ? 'Excluir' : 'Delete'),
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
    _sidebarController.dispose();
    _speech.dispose();
    super.dispose();
  }
}
