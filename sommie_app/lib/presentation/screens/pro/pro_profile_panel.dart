import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../routes/app_routes.dart';

class ProProfilePanel extends StatelessWidget {
  const ProProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final viewProvider = Provider.of<ProViewProvider>(context);
    final user = authProvider.currentUser;
    final isPT = languageProvider.currentLanguage == 'pt';

    return Container(
      width: 280,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                  image: user?.avatar != null && user!.avatar!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user?.avatar == null || user!.avatar!.isEmpty
                    ? Center(
                        child: Text(
                          user?.name?.substring(0, 1).toUpperCase() ?? 'A',
                          style: const TextStyle(
                            fontSize: 20,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.role ?? (isPT ? 'Usuário PRO' : 'PRO User'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6D3FA6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu items
          _buildMenuItem(
            icon: Icons.person_outline,
            label: isPT ? 'Perfil' : 'Profile',
            onTap: () => viewProvider.setView(ProView.profile),
          ),
          _buildMenuItem(
            icon: Icons.wine_bar,
            label: isPT ? 'Adega' : 'Cellar',
            onTap: () => viewProvider.setView(ProView.cellar),
          ),
          _buildMenuItem(
            icon: Icons.card_giftcard,
            label: isPT ? 'Benefícios' : 'Benefits',
            onTap: () => viewProvider.setView(ProView.benefits),
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            label: isPT ? 'Notificações' : 'Notifications',
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            label: isPT ? 'Privacidade' : 'Privacy',
          ),
          _buildMenuItem(
            icon: Icons.language,
            label: isPT ? 'Idioma' : 'Language',
          ),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            label: isPT ? 'Favoritos' : 'Favorites',
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            label: isPT ? 'Suporte' : 'Support',
          ),
          const Spacer(),

          // Logout button
          _buildMenuItem(
            icon: Icons.logout,
            label: isPT ? 'Sair' : 'Logout',
            color: Colors.red,
            onTap: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
