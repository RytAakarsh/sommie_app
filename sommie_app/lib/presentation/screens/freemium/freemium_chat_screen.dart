import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../core/utils/speech_helper.dart';
import '../../../routes/app_routes.dart';
import 'free_edit_profile_screen.dart';
import 'free_cellar_screen.dart';
import 'free_add_wine_screen.dart';
import 'free_preview_wine_screen.dart';
import 'free_confirm_wine_screen.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FreemiumChatScreen extends StatefulWidget {
  const FreemiumChatScreen({super.key});

  @override
  State<FreemiumChatScreen> createState() => _FreemiumChatScreenState();
}

class _FreemiumChatScreenState extends State<FreemiumChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final SpeechHelper _speech = SpeechHelper();
  final FocusNode _focusNode = FocusNode();

  bool sidebar = false;
  bool listening = false;
  bool _isAiTyping = false;

  late AnimationController sidebarController;
  late Animation<Offset> sidebarAnim;

  @override
  void initState() {
    super.initState();
    _speech.initialize();

    sidebarController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 280));

    sidebarAnim = Tween(begin: const Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: sidebarController, curve: Curves.easeOut),
    );
  }

  void toggleSidebar() {
    setState(() {
      sidebar = !sidebar;
      sidebar ? sidebarController.forward() : sidebarController.reverse();
    });
  }

  void send(ChatProvider chat) async {
    if (_input.text.trim().isEmpty) return;
    
    // Show AI typing indicator
    setState(() => _isAiTyping = true);
    
    // Send message
    await chat.sendMessage(_input.text);
    _input.clear();
    _focusNode.unfocus();
    
    // Hide AI typing indicator
    setState(() => _isAiTyping = false);
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _navigateToPro() {
    Navigator.pushNamed(context, AppRoutes.proPlanFlow);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    final isPT = lang.currentLanguage == 'pt';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      body: Stack(
        children: [
          Column(
            children: [
              _mobileNavbar(lang, isPT),
              Expanded(child: _messages(chat, isPT, user)),
            ],
          ),

          /// Bottom input
          Align(alignment: Alignment.bottomCenter, child: _composer(chat, isPT)),

          /// overlay
          if (sidebar)
            GestureDetector(
              onTap: toggleSidebar,
              child: Container(color: Colors.black26),
            ),

          /// sidebar
          if (sidebar)
            SlideTransition(
              position: sidebarAnim,
              child: Material(
                elevation: 12,
                child: Container(
                  width: 320,
                  color: Colors.white,
                  child: _sidebar(chat, isPT, auth, lang),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ---------------- NAVBAR (WITH PRO LOGO)
  Widget _mobileNavbar(LanguageProvider lang, bool isPT) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu icon (left)
            IconButton(
              onPressed: toggleSidebar,
              icon: const Icon(Icons.menu, color: Color(0xFF4B2B5F)),
            ),
            
            // PRO Logo (centered)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/pro-logo.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    "SOMMIE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF7f488b),
                    ),
                  ),
                ),
              ],
            ),
            
            // Language + Upgrade (right)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language Toggle
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E9FF),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageChip('EN', !isPT, () => lang.setLanguage('en')),
                      _buildLanguageChip('PT', isPT, () => lang.setLanguage('pt')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Upgrade Button with Crown Icon
                GestureDetector(
                  onTap: _navigateToPro,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7f488b), Color(0xFF4B2B5F)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPT ? 'PRO' : 'PRO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String text, bool isSelected, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B2B5F) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4B2B5F),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// ---------------- WELCOME + MESSAGES
  Widget _messages(ChatProvider chat, bool isPT, UserModel? user) {
    if (chat.currentMessages.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Amelie Avatar
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/avatar.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Welcome Text
              Text(
                isPT
                    ? 'Olá, sou a Sommie, sua sommelière virtual!'
                    : "Hi, I'm Sommie, your virtual sommelier!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description with proper line breaks
              Text(
                isPT
                    ? 'Sou uma IA apaixonada por vinhos —\nposso responder perguntas, sugerir\nharmonizações, compartilhar\ncuriosidades sobre uvas, regiões,\nvinícolas e recomendar os melhores\nrótulos para o seu paladar.'
                    : "I'm an AI passionate about wines —\nI can answer questions, suggest\npairings, share curiosities about\ngrapes, regions, wineries, and\nrecommend the best labels for\nyour palate.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      itemCount: chat.currentMessages.length + (_isAiTyping ? 1 : 0),
      itemBuilder: (_, i) {
        // If this is the typing indicator
        if (_isAiTyping && i == chat.currentMessages.length) {
          return _buildTypingIndicator(isPT);
        }
        
        final m = chat.currentMessages[i];
        final isUser = m.type == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                // Bot Avatar (Amelie)
                Container(
                  width: 36,
                  height: 36,
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
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: isUser
                      ? Text(
                          m.text,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        )
                      : MarkdownBody(
                          data: m.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2B5F),
                            ),
                            listBullet: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4B2B5F),
                            ),
                          ),
                        ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                // User Avatar
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    final currentUser = auth.currentUser;
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        shape: BoxShape.circle,
                        image: currentUser?.avatar != null && currentUser!.avatar!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(currentUser.avatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: currentUser?.avatar == null || currentUser!.avatar!.isEmpty
                          ? Center(
                              child: Text(
                                currentUser?.name?.substring(0, 1).toUpperCase() ?? 'A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B2B5F),
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isPT) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Typing Bubbles
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1.0,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF7f488b).withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          duration: Duration(milliseconds: 600 + delay),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7f488b),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// ---------------- COMPOSER (with user avatar and purple send button)
  Widget _composer(ChatProvider chat, bool isPT) {
    final hasText = _input.text.trim().isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00FAF7FC), Color(0xFFFAF7FC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            // User Avatar
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final currentUser = auth.currentUser;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                    image: currentUser?.avatar != null && currentUser!.avatar!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(currentUser.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentUser?.avatar == null || currentUser!.avatar!.isEmpty
                      ? Center(
                          child: Text(
                            currentUser?.name?.substring(0, 1).toUpperCase() ?? 'A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2B5F),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
            const SizedBox(width: 8),
            
            // Mic button
            IconButton(
              icon: Icon(
                listening ? Icons.close : Icons.mic,
                color: const Color(0xFF7f488b),
                size: 22,
              ),
              onPressed: () async {
                if (listening) {
                  await _speech.stopListening();
                  setState(() => listening = false);
                } else {
                  await _speech.startListening(
                    onResult: (txt) {
                      setState(() => _input.text += txt);
                    },
                    onListening: () {
                      setState(() => listening = !listening);
                    },
                  );
                }
              },
            ),
            
            // Text input
            Expanded(
              child: TextField(
                controller: _input,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: isPT
                      ? 'Pergunte-me qualquer coisa...'
                      : 'Ask me anything...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => send(chat),
              ),
            ),
            
            // Send button (purple when has text)
            GestureDetector(
              onTap: hasText ? () => send(chat) : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasText ? const Color(0xFF7f488b) : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: hasText ? Colors.white : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- SIDEBAR (Profile at Bottom)
  Widget _sidebar(ChatProvider chat, bool isPT, AuthProvider auth, LanguageProvider lang) {
    return Column(
      children: [
        // Top Space
        const SizedBox(height: 50),
        
        // New Chat Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7f488b),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              chat.createNewSession();
              toggleSidebar();
            },
            child: Text(isPT ? 'Nova Conversa' : 'New Chat'),
          ),
        ),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: isPT ? 'Buscar conversas...' : 'Search chats...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
        ),
        
        // Chat History (Expands to fill space above profile)
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: chat.sessions.length,
            itemBuilder: (_, i) {
              final s = chat.sessions[i];
              final firstMsg = s.messages.isNotEmpty ? s.messages.first.text : 
                  (isPT ? 'Nova conversa' : 'New chat');
              
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF4B2B5F),
                    size: 20,
                  ),
                ),
                title: Text(
                  firstMsg.length > 25 ? '${firstMsg.substring(0, 25)}...' : firstMsg,
                  style: TextStyle(
                    fontWeight: s.id == chat.activeSessionId
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: s.id == chat.activeSessionId
                        ? const Color(0xFF4B2B5F)
                        : Colors.black87,
                  ),
                ),
                selected: s.id == chat.activeSessionId,
                selectedTileColor: const Color(0xFFF3E8FF),
                onTap: () {
                  chat.switchSession(s.id);
                  toggleSidebar();
                },
                onLongPress: () => _showDeleteDialog(context, s.id, isPT),
              );
            },
          ),
        ),
        
        // Profile Section at Bottom (Fixed)
        Consumer<AuthProvider>(
          builder: (context, auth, child) {
            final currentUser = auth.currentUser;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        shape: BoxShape.circle,
                        image: currentUser?.avatar != null && currentUser!.avatar!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(currentUser.avatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: currentUser?.avatar == null || currentUser!.avatar!.isEmpty
                          ? Center(
                              child: Text(
                                currentUser?.name?.substring(0, 1).toUpperCase() ?? 'A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B2B5F),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Name and Role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.name ?? 'Guest',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPT ? 'Usuário Gratuito' : 'Free User',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Three-dot menu
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'profile') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FreeEditProfileScreen(
                                onBack: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                          // Force refresh when returning
                          auth.notifyListeners();
                        } else if (value == 'cellar') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FreeCellarScreen(
                                setView: (view) => Navigator.pop(context),
                              ),
                            ),
                          );
                        } else if (value == 'logout') {
                          _showLogoutDialog(context, auth, isPT);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, color: Colors.grey.shade700, size: 20),
                              const SizedBox(width: 12),
                              Text(isPT ? 'Editar Perfil' : 'Edit Profile'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'cellar',
                          child: Row(
                            children: [
                              Icon(Icons.wine_bar, color: Colors.grey.shade700, size: 20),
                              const SizedBox(width: 12),
                              Text(isPT ? 'Adega' : 'Cellar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: Colors.red, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                isPT ? 'Sair' : 'Logout',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
              context.read<ChatProvider>().deleteSession(sessionId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isPT ? 'Excluir' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth, bool isPT) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPT ? 'Sair' : 'Logout'),
        content: Text(isPT
            ? 'Tem certeza que deseja sair?'
            : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isPT ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isPT ? 'Sair' : 'Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _speech.dispose();
    _input.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}