import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/pro_view_provider.dart';

class ProHeader extends StatelessWidget {
  const ProHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final viewProvider = Provider.of<ProViewProvider>(context);
    final user = authProvider.currentUser;
    final isPT = languageProvider.currentLanguage == 'pt';

    // Return empty container for chat page (handled by chat panel)
    if (viewProvider.currentView == ProView.chat) {
      return const SizedBox.shrink();
    }

    // Regular header for other pages
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (only when not on dashboard)
                if (viewProvider.currentView != ProView.dashboard)
                  IconButton(
                    onPressed: viewProvider.goBack,
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F), size: 28),
                  )
                else
                  const SizedBox(width: 48),

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

                // Language toggle
                Container(
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

          // Progress bar (only on dashboard)
          if (viewProvider.currentView == ProView.dashboard) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.33,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B2B5F),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Greeting
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                isPT
                    ? 'Olá ${user?.name ?? 'Convidado'}! Bem-vindo ao PRO'
                    : 'Hello ${user?.name ?? 'Guest'}! Welcome to PRO',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B2B5F),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String text, bool isSelected, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B2B5F) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4B2B5F),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
