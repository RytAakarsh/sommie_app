import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../routes/app_routes.dart';

class ProProfilePage extends StatelessWidget {
  const ProProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isPT = languageProvider.currentLanguage == 'pt';
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
              onPressed: () => viewProvider.setView(ProView.dashboard),
            ),
            title: Text(
              isPT ? 'Perfil' : 'Profile',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B2B5F),
              ),
            ),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
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
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4B2B5F),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Guest',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.role ?? (isPT ? 'Usuário' : 'User'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6D3FA6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user?.plan == 'PRO' 
                                    ? const Color(0xFF4B2B5F) 
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user?.plan ?? 'FREE',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Edit Profile Menu Item
                _buildMenuItem(
                  icon: Icons.person_outline,
                  label: isPT ? 'Editar Perfil' : 'Edit Profile',
                  subtitle: isPT ? 'Alterar informações pessoais' : 'Change personal info',
                  onTap: () {
                    print('📱 Navigating to Edit Profile');
                    viewProvider.setView(ProView.editProfile);
                  },
                ),
                const SizedBox(height: 8),

                // My Cellar Menu Item
                _buildMenuItem(
                  icon: Icons.wine_bar,
                  label: isPT ? 'Minha Adega' : 'My Cellar',
                  subtitle: isPT ? 'Gerenciar seus vinhos' : 'Manage your wines',
                  onTap: () {
                    print('📱 Navigating to Cellar');
                    viewProvider.setView(ProView.cellar);
                  },
                ),
                const SizedBox(height: 8),

                // Benefits Club Menu Item
                _buildMenuItem(
                  icon: Icons.card_giftcard,
                  label: isPT ? 'Clube de Benefícios' : 'Benefits Club',
                  subtitle: isPT ? 'Ver descontos disponíveis' : 'View available discounts',
                  onTap: () {
                    print('📱 Navigating to Benefits');
                    viewProvider.setView(ProView.benefits);
                  },
                ),
                const SizedBox(height: 8),

                // Notifications Menu Item
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  label: isPT ? 'Notificações' : 'Notifications',
                  subtitle: isPT ? 'Gerenciar preferências' : 'Manage preferences',
                ),
                const SizedBox(height: 8),

                // Privacy Menu Item
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  label: isPT ? 'Privacidade' : 'Privacy',
                  subtitle: isPT ? 'Configurações de privacidade' : 'Privacy settings',
                ),
                const SizedBox(height: 8),

                // Language Menu Item
                _buildMenuItem(
                  icon: Icons.language,
                  label: isPT ? 'Idioma' : 'Language',
                  subtitle: isPT ? 'Português / English' : 'Português / English',
                ),
                const SizedBox(height: 8),

                // Favorites Menu Item
                _buildMenuItem(
                  icon: Icons.favorite_outline,
                  label: isPT ? 'Favoritos' : 'Favorites',
                  subtitle: isPT ? 'Meus vinhos favoritos' : 'My favorite wines',
                ),
                const SizedBox(height: 8),

                // Support Menu Item
                _buildMenuItem(
                  icon: Icons.help_outline,
                  label: isPT ? 'Suporte' : 'Support',
                  subtitle: isPT ? 'Ajuda e FAQ' : 'Help & FAQ',
                ),
                
                const SizedBox(height: 24),
                
                // Logout Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, authProvider, isPT),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      isPT ? 'Sair da Conta' : 'Logout',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // App Version
                Center(
                  child: Text(
                    'Sommie PRO v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF4B2B5F), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, bool isPT) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isPT ? 'Confirmar Saída' : 'Confirm Logout',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B2B5F),
            ),
          ),
          content: Text(
            isPT
                ? 'Tem certeza que deseja sair da sua conta?'
                : 'Are you sure you want to logout of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isPT ? 'Cancelar' : 'Cancel',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(isPT ? 'Sair' : 'Logout'),
            ),
          ],
        );
      },
    );
  }
}