import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/chat_session.dart';
import '../../../core/utils/speech_helper.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/services/payment_service.dart';
import '../../../routes/app_routes.dart';
import 'free_edit_profile_screen.dart';
import 'free_choose_avatar_screen.dart';
import 'free_cellar_screen.dart';
import 'free_add_wine_screen.dart';
import 'free_preview_wine_screen.dart';
import 'free_confirm_wine_screen.dart';

// ==================== TYPING ANIMATION WITH MARKDOWN ====================
class TypewriterMarkdown extends StatefulWidget {
  final String text;
  final Duration speed;

  const TypewriterMarkdown({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 12),
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
  String _displayed = '';
  int _index = 0;
  bool _isTyping = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    while (_index < widget.text.length && _isTyping && mounted) {
      await Future.delayed(widget.speed);
      if (!mounted) return;

      setState(() {
        _displayed += widget.text[_index];
        _index++;
      });
    }
  }

  @override
  void didUpdateWidget(covariant TypewriterMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayed = '';
      _index = 0;
      _isTyping = true;
      _startTyping();
    }
  }

  @override
  void dispose() {
    _isTyping = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayed,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        strong: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF4B2B5F)),
        listBullet: const TextStyle(fontSize: 14, color: Color(0xFF4B2B5F)),
        a: const TextStyle(
            color: Color(0xFF4B2B5F), decoration: TextDecoration.underline),
      ),
    );
  }
}

// ==================== SIMPLE TEXT BUBBLE ====================
class SimpleTextBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const SimpleTextBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isUser ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}

// ==================== MAIN CHAT SCREEN ====================
class FreemiumChatScreen extends StatefulWidget {
  const FreemiumChatScreen({super.key});

  @override
  State<FreemiumChatScreen> createState() => _FreemiumChatScreenState();
}

class _FreemiumChatScreenState extends State<FreemiumChatScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechHelper _speechHelper = SpeechHelper();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  bool _sidebarOpen = false;
  bool _isListening = false;
  String? _speechError;
  String? _imageUploadError;
  String? _selectedImage;
  bool _showImageOptions = false;
  String _searchQuery = '';

  // Edit message dialog
  String? _editingMessageId;
  String _editingMessageText = '';

  // Rename dialog
  String? _renamingSessionId;
  String _renamingSessionTitle = '';

  late AnimationController _sidebarController;
  late Animation<Offset> _sidebarAnimation;

  final Map<String, List<Map<String, String>>> _suggestions = {
    'en': [
      {'text': '', 'query': ''},
      {'text': '', 'query': ''},
      {'text': '', 'query': ''},
      {'text': '', 'query': ''},
    ],
    'pt': [
      {'text': '', 'query': ''},
      {'text': '', 'query': ''},
      {'text': '', 'query': ''},
      {'text': '', 'query': ''},
    ],
  };

  final Map<String, String> _avatarDisplayNames = {
    'assets/sommie_avatar/Avatar_Sommie_Lucia_Herrera.png': 'Lucía',
    'assets/sommie_avatar/Avatar_Sommie_LiWei.png': 'Li Wei',
    'assets/sommie_avatar/Avatar_Sommie_karim_Al-Nassir.png': 'Karim',
    'assets/sommie_avatar/Avatar_Sommie_Ama_Kumasi.png': 'Ama',
    'assets/sommie_avatar/Avatares_sommie_Dom_Aurelius.png': 'Miguel',
    'assets/sommie_avatar/Avatares_Sommie_Amelie.png': 'Amelie',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _sidebarAnimation = Tween(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _sidebarController, curve: Curves.easeOut));
    _initializeSpeech();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sidebarController.dispose();
    _speechHelper.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initializeSpeech() async {
    await _speechHelper.initialize();
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarOpen = !_sidebarOpen;
      _sidebarOpen
          ? _sidebarController.forward()
          : _sidebarController.reverse();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ✅ SEPARATE FUNCTIONS FOR PROFILE IMAGE AND AVATAR
  String? _getUserProfileImage(UserModel? user) {
    if (user?.photo != null &&
        user!.photo!.isNotEmpty &&
        user.photo != 'null') {
      return user.photo;
    }
    return null;
  }

  String _getUserAvatar(UserModel? user) {
    if (user?.avatar != null &&
        user!.avatar!.isNotEmpty &&
        user.avatar != 'null') {
      return user.avatar!;
    }
    return 'assets/sommie_avatar/Avatar_Sommie_Lucia_Herrera.png';
  }

  // ✅ Shorten long text for display
  String _shortenText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void _sendMessage(ChatProvider chat) async {
    final text = _inputController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    _inputController.clear();
    final imageToSend = _selectedImage;
    setState(() {
      _selectedImage = null;
    });

    await chat.sendMessage(text, imageBase64: imageToSend);
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        final preview = 'data:image/jpeg;base64,$base64Image';

        setState(() {
          _selectedImage = preview;
          _showImageOptions = false;
          _imageUploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _imageUploadError = 'Failed to load image';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _imageUploadError = null);
      });
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechHelper.stopListening();
      setState(() => _isListening = false);
    } else {
      final isAvailable = await _speechHelper.initialize();
      if (isAvailable) {
        _speechHelper.startListening(
          onResult: (text) {
            setState(() {
              _inputController.text += text + ' ';
            });
          },
          onListeningStart: () {
            setState(() => _isListening = true);
          },
          onListeningStop: () {
            setState(() => _isListening = false);
          },
          localeId: Provider.of<LanguageProvider>(context, listen: false)
                      .currentLanguage ==
                  'pt'
              ? 'pt_BR'
              : 'en_US',
        );
      } else {
        setState(() {
          _speechError = 'Speech recognition not available';
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _speechError = null);
        });
      }
    }
  }

  Future<void> _handleProUpgrade() async {
    final success = await PaymentService.initiateProUpgrade(context);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redirecting to complete your upgrade...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showEditMessageDialog(
      ChatProvider chat, int index, String currentText) {
    _editingMessageText = currentText;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTranslation('edit_message')),
        content: TextField(
          controller: TextEditingController(text: currentText),
          onChanged: (value) => _editingMessageText = value,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: _getTranslation('edit_message_hint'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTranslation('cancel')),
          ),
          TextButton(
            onPressed: () {
              chat.editMessage(index, _editingMessageText);
              Navigator.pop(context);
            },
            child: Text(_getTranslation('save')),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
      ChatProvider chat, String sessionId, String currentTitle) {
    _renamingSessionTitle = currentTitle;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTranslation('rename_chat')),
        content: TextField(
          controller: TextEditingController(text: currentTitle),
          onChanged: (value) => _renamingSessionTitle = value,
          decoration: InputDecoration(
            hintText: _getTranslation('rename_hint'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getTranslation('cancel')),
          ),
          TextButton(
            onPressed: () {
              chat.renameSession(sessionId, _renamingSessionTitle);
              Navigator.pop(context);
            },
            child: Text(_getTranslation('save')),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getTranslation('copied')),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getAvatarDisplayName(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return 'Sommie';
    return _avatarDisplayNames[avatarPath] ?? 'Sommie';
  }

  String _getTranslation(String key) {
    final isPT =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguage ==
            'pt';
    final translations = {
      'edit_message': isPT ? 'Editar mensagem' : 'Edit message',
      'edit_message_hint':
          isPT ? 'Digite sua mensagem...' : 'Type your message...',
      'rename_chat': isPT ? 'Renomear conversa' : 'Rename chat',
      'rename_hint': isPT ? 'Novo nome...' : 'New name...',
      'cancel': isPT ? 'Cancelar' : 'Cancel',
      'save': isPT ? 'Salvar' : 'Save',
      'delete': isPT ? 'Excluir' : 'Delete',
      'rename': isPT ? 'Renomear' : 'Rename',
      'copied': isPT ? 'Copiado!' : 'Copied!',
      'liked': isPT ? 'Votou positivo!' : 'Liked!',
      'disliked': isPT ? 'Votou negativo!' : 'Disliked!',
      'new_chat': isPT ? 'Nova Conversa' : 'New Chat',
      'search_chats': isPT ? 'Buscar conversas...' : 'Search chats...',
      'no_chats': isPT ? 'Nenhuma conversa ainda' : 'No chats yet',
      'start_chat':
          isPT ? 'Inicie uma nova conversa' : 'Start a new conversation',
      'edit_profile': isPT ? 'Editar Perfil' : 'Edit Profile',
      'choose_avatar': isPT ? 'Escolha seu Avatar' : 'Choose Your Avatar',
      'wine_cellar': isPT ? 'Adega Digital' : 'Wine Cellar',
      'explore_pro': isPT ? 'Explorar PRO' : 'Explore PRO',
      'logout': isPT ? 'Sair' : 'Logout',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.currentUser;
    final isPT = languageProvider.currentLanguage == 'pt';
    final avatarDisplayName = _getAvatarDisplayName(user?.avatar);
    final isSending = chatProvider.isSending;
    final suggestions = _suggestions[isPT ? 'pt' : 'en'] ?? _suggestions['en']!;
    final profileImage = _getUserProfileImage(user);
    final botAvatar = _getUserAvatar(user);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Main content - fills entire area
          Positioned.fill(
            child: Column(
              children: [
                _buildGlassNavBar(isPT, botAvatar),
                Expanded(
                  child: _buildMessagesArea(
                      chatProvider,
                      isPT,
                      avatarDisplayName,
                      suggestions,
                      isSending,
                      user,
                      profileImage,
                      botAvatar),
                ),
              ],
            ),
          ),

          // Composer at bottom - FIXED: Use Positioned instead of Align
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildComposer(chatProvider, isPT, isSending),
          ),

          // Dark overlay when sidebar is open - FIXED: Use Positioned.fill
          if (_sidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleSidebar,
                child: Container(color: Colors.black54),
              ),
            ),

          // Sidebar - FIXED: Use Positioned with constraints
          if (_sidebarOpen)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: SlideTransition(
                position: _sidebarAnimation,
                child: Material(
                  elevation: 12,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    color: Colors.white,
                    child: _buildSidebar(
                        chatProvider, authProvider, isPT, profileImage, user),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== GLASSMORPHISM NAVBAR ====================
  Widget _buildGlassNavBar(bool isPT, String botAvatar) {
    final isPTLang =
        Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleSidebar,
                  icon: const Icon(Icons.menu, color: Color(0xFF4B2B5F)),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(botAvatar),
                          backgroundColor: const Color(0xFFF3E8FF)),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/pro-logo.png',
                        height: 26,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            "Sommie",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2B5F),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E9FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageChip('EN', !isPTLang, () {
                        context.read<LanguageProvider>().setLanguage('en');
                      }),
                      _buildLanguageChip('PT', isPTLang, () {
                        context.read<LanguageProvider>().setLanguage('pt');
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _handleProUpgrade,
                  child: Image.asset(
                    'assets/images/crown.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.workspace_premium,
                        color: Color(0xFF7f488b),
                        size: 28,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChip(
      String text, bool isSelected, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B2B5F) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
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

  Widget _buildMessagesArea(
      ChatProvider chat,
      bool isPT,
      String avatarDisplayName,
      List<Map<String, String>> suggestions,
      bool isSending,
      UserModel? user,
      String? profileImage,
      String botAvatar) {
    final messages = chat.currentMessages;

    if (messages.isEmpty && !isSending) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(botAvatar),
                backgroundColor: const Color(0xFFF3E8FF),
              ),
              const SizedBox(height: 20),
              Text(
                isPT
                    ? 'Olá, eu sou $avatarDisplayName!'
                    : "Hi, I'm $avatarDisplayName!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              MarkdownBody(
                data: isPT
                    ? '''Sou uma IA apaixonada por vinhos — posso responder perguntas, sugerir harmonizações, compartilhar curiosidades sobre uvas, regiões, vinícolas e recomendar os melhores rótulos para o seu paladar.'''
                    : '''I'm an AI passionate about wines — I can answer questions, suggest pairings, share curiosities about grapes, regions, wineries, and recommend the best labels for your palate.''',
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                      fontSize: 15, height: 1.5, color: Colors.grey.shade700),
                  strong: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF4B2B5F)),
                  listBullet:
                      const TextStyle(fontSize: 14, color: Color(0xFF4B2B5F)),
                ),
              ),
              // const SizedBox(height: 32),
              // Wrap(
              //   spacing: 8,
              //   runSpacing: 8,
              //   alignment: WrapAlignment.center,
              //   children: suggestions.map((suggestion) {
              //     return ActionChip(
              //       label: Text(suggestion['text']!),
              //       onPressed: () {
              //         _inputController.text = suggestion['query']!;
              //         _sendMessage(chat);
              //       },
              //       backgroundColor: const Color(0xFFF3E8FF),
              //       labelStyle: const TextStyle(color: Color(0xFF4B2B5F)),
              //     );
              //   }).toList(),
              // ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: 140 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
        itemCount: messages.length + (isSending ? 1 : 0),
        itemBuilder: (context, index) {
          if (isSending && index == messages.length) {
            return _buildShimmerLoadingIndicator(botAvatar);
          }

          final message = messages[index];
          final isUser = message.role == 'user';

          // Shorten very long messages
          final displayText = isUser ? message.content : message.content;
          final shortenedText =
              _shortenText(displayText, maxLength: isUser ? 200 : 500);

          return _buildMessageBubble(
            shortenedText,
            message.imageBase64,
            index,
            isUser,
            isPT,
            chat,
            user,
            profileImage,
            botAvatar,
            message.isLiked,
            message.isDisliked,
          );
        },
      ),
    );
  }

  // ==================== SHIMMER LOADING BUBBLE ====================
  Widget _buildShimmerLoadingIndicator(String botAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(botAvatar),
            backgroundColor: const Color(0xFFF3E8FF),
          ),
          const SizedBox(width: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 120,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    String text,
    String? imageBase64,
    int index,
    bool isUser,
    bool isPT,
    ChatProvider chat,
    UserModel? user,
    String? profileImage,
    String botAvatar,
    bool? isLiked,
    bool? isDisliked,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.75;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(botAvatar),
              backgroundColor: const Color(0xFFF3E8FF),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            fit: FlexFit.loose,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: GestureDetector(
                onLongPress: isUser
                    ? () => _showEditMessageDialog(chat, index, text)
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF7f488b) : Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageBase64 != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: SizedBox(
                                      width: screenWidth * 0.9,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          base64Decode(
                                              imageBase64.split(',').last),
                                          fit: BoxFit.contain,
                                          gaplessPlayback: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(imageBase64.split(',').last),
                                  height: 150,
                                  width:
                                      maxWidth, // FIXED: removed double.infinity
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      width: maxWidth,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image,
                                          size: 50),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        if (text.isNotEmpty)
                          isUser
                              ? Text(
                                  text,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                )
                              : TypewriterMarkdown(
                                  text: text,
                                  speed: const Duration(milliseconds: 10),
                                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  profileImage != null && profileImage.contains(',')
                      ? MemoryImage(base64Decode(profileImage.split(',').last))
                      : null,
              backgroundColor: const Color(0xFFF3E8FF),
              child: profileImage == null
                  ? Center(
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2B5F),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComposer(ChatProvider chat, bool isPT, bool isSending) {
    final hasText =
        _inputController.text.trim().isNotEmpty || _selectedImage != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00FAF7FC), Color(0xFFFAF7FC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(_selectedImage!.split(',').last),
                      height: 80,
                      width:
                          80, // FIXED: use fixed width instead of double.infinity
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon:
                          const Icon(Icons.close, size: 18, color: Colors.red),
                      onPressed: () => setState(() => _selectedImage = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          if (_speechError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _speechError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          if (_imageUploadError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _imageUploadError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          if (_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPT ? 'Ouvindo...' : 'Listening...',
                    style: const TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'camera') {
                      _pickImage(ImageSource.camera);
                    } else if (value == 'gallery') {
                      _pickImage(ImageSource.gallery);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'camera',
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt, size: 20),
                          SizedBox(width: 12),
                          Text('Camera'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'gallery',
                      child: Row(
                        children: [
                          Icon(Icons.photo_library, size: 20),
                          SizedBox(width: 12),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: isSending ? Colors.grey : const Color(0xFF7f488b),
                    size: 28,
                  ),
                  enabled: !isSending,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.close : Icons.mic,
                    color: const Color(0xFF7f488b),
                    size: 22,
                  ),
                  onPressed: isSending ? null : _toggleListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: isSending
                          ? (isPT
                              ? 'Aguardando resposta...'
                              : 'Waiting for response...')
                          : (_isListening
                              ? (isPT ? 'Fale agora...' : 'Speak now...')
                              : (isPT
                                  ? 'Pergunte-me qualquer coisa...'
                                  : 'Ask me anything...')),
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _sendMessage(chat),
                    enabled: !isSending,
                  ),
                ),
                if (isSending)
                  GestureDetector(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: Colors.grey, shape: BoxShape.circle),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: hasText ? () => _sendMessage(chat) : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasText
                            ? const Color(0xFF7f488b)
                            : Colors.grey.shade300,
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
        ],
      ),
    );
  }

  Widget _buildSidebar(ChatProvider chat, AuthProvider auth, bool isPT,
      String? profileImage, UserModel? user) {
    final sessions = chat.sessions;
    final filteredSessions = _searchQuery.isEmpty
        ? sessions
        : sessions
            .where((s) =>
                s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.messages.any((m) => m.content
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
            .toList();

    return Column(
      children: [
        const SizedBox(height: 50),

        // FIXED NEW CHAT BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7f488b),
                foregroundColor: Colors.white,
                minimumSize:
                    const Size(0, 48), // FIXED: removed double.infinity
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                chat.createNewSession();
                _toggleSidebar();
              },
              child: Text(_getTranslation('new_chat')),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: _getTranslation('search_chats'),
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, size: 18, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        Expanded(
          child: filteredSessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        _getTranslation('no_chats'),
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      Text(
                        _getTranslation('start_chat'),
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredSessions.length,
                  itemBuilder: (_, i) {
                    final session = filteredSessions[i];
                    final title = session.title;
                    final isActive = session.id == chat.activeSessionId;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF7f488b).withOpacity(0.1)
                              : const Color(0xFFF3E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: isActive
                              ? const Color(0xFF7f488b)
                              : const Color(0xFF4B2B5F),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        title.length > 25
                            ? '${title.substring(0, 25)}...'
                            : title,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive
                              ? const Color(0xFF7f488b)
                              : Colors.black87,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'rename') {
                            _showRenameDialog(chat, session.id, title);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, session.id, isPT);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 12),
                                Text('Rename'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, size: 20),
                      ),
                      selected: isActive,
                      selectedTileColor: const Color(0xFFF3E8FF),
                      onTap: () {
                        chat.switchSession(session.id);
                        _toggleSidebar();
                      },
                    );
                  },
                ),
        ),

        Container(
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
                CircleAvatar(
                  radius: 24,
                  backgroundImage: profileImage != null &&
                          profileImage.contains(',')
                      ? MemoryImage(base64Decode(profileImage.split(',').last))
                      : null,
                  backgroundColor: const Color(0xFFF3E8FF),
                  child: profileImage == null
                      ? Center(
                          child: Text(
                            user?.name?.substring(0, 1).toUpperCase() ?? 'U',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'profile') {
                      // CLOSE SIDEBAR FIRST - CRITICAL FIX
                      if (_sidebarOpen) {
                        _toggleSidebar();
                        await Future.delayed(const Duration(milliseconds: 250));
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FreeEditProfileScreen(),
                        ),
                      );
                      await auth.refreshUser();
                      auth.notifyListeners();
                    } else if (value == 'choose_avatar') {
                      // CLOSE SIDEBAR FIRST
                      if (_sidebarOpen) {
                        _toggleSidebar();
                        await Future.delayed(const Duration(milliseconds: 250));
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreeChooseAvatarScreen(
                            onAvatarSelected: () {
                              auth.refreshUser();
                            },
                          ),
                        ),
                      );
                      auth.notifyListeners();
                    } else if (value == 'cellar') {
                      if (_sidebarOpen) _toggleSidebar();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreeCellarScreen(
                            setView: (view) => Navigator.pop(context),
                          ),
                        ),
                      );
                    } else if (value == 'upgrade') {
                      if (_sidebarOpen) _toggleSidebar();
                      await _handleProUpgrade();
                    } else if (value == 'logout') {
                      if (_sidebarOpen) _toggleSidebar();
                      _showLogoutDialog(context, auth, isPT);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 20, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Edit Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'choose_avatar',
                      child: Row(
                        children: [
                          Icon(Icons.style, size: 20, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Choose Your Avatar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cellar',
                      child: Row(
                        children: [
                          Icon(Icons.wine_bar, size: 20, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('Wine Cellar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'upgrade',
                      child: Row(
                        children: [
                          Icon(Icons.workspace_premium,
                              size: 20, color: Colors.amber),
                          SizedBox(width: 12),
                          Text('Explore PRO'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),
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
}
