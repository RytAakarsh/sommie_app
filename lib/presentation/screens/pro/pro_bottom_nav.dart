import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/pro_view_provider.dart';

class ProBottomNav extends StatelessWidget {
  const ProBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final viewProvider = Provider.of<ProViewProvider>(context);
    final isPT = languageProvider.currentLanguage == 'pt';

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B2B5F), Color(0xFF4B2B5F)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
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
              onTap: () => viewProvider.setView(ProView.dashboard),
            ),
            _buildNavItem(
              icon: Icons.wine_bar,
              label: isPT ? 'Adega' : 'Cellar',
              isSelected: viewProvider.currentView == ProView.cellar,
              onTap: () => viewProvider.setView(ProView.cellar),
            ),
            _buildNavItem(
              icon: Icons.chat,
              label: isPT ? 'Chat' : 'Chat',
              isSelected: viewProvider.currentView == ProView.chat,
              onTap: () => viewProvider.setView(ProView.chat),
            ),
            _buildNavItem(
              icon: Icons.card_giftcard,
              label: isPT ? 'Benefícios' : 'Benefits',
              isSelected: viewProvider.currentView == ProView.benefits,
              onTap: () => viewProvider.setView(ProView.benefits),
            ),
          ],
        ),
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
            color: isSelected ? Colors.amber : Colors.white, 
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.amber : Colors.white,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
