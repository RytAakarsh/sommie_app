import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';

class ProGamePage extends StatelessWidget {
  const ProGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    return Scaffold(
      backgroundColor: const Color(0xFFEFECEC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
        title: Text(
          'VinophileVivian',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Score card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E8FB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isPT ? 'Pontuação Atual' : 'Current Score',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '12,450',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2B5F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPT
                            ? 'Pontos até o Nível 6: 2,550'
                            : 'Points until Level 6: 2,550',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.83,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPT ? 'Nv 5' : 'Lvl 5',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            isPT ? 'Nv 6 (15,000)' : 'Lvl 6 (15,000)',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B2B5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isPT ? 'Jogar Agora' : 'Play Now'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upcoming rewards
                _buildSection(
                  title: isPT ? 'Próximas Recompensas (Nv 6)' : 'Upcoming Rewards (Lvl 6)',
                  child: Column(
                    children: [
                      _buildRewardItem(
                        isPT
                            ? 'Desbloquear Crítico de Vinhos'
                            : 'Unlock Wine Critic Achievement',
                      ),
                      _buildRewardItem(
                        isPT
                            ? 'Módulo Avançado de Bordeaux'
                            : 'Advanced Bordeaux Module',
                      ),
                      _buildRewardItem(
                        isPT
                            ? '+500 Pontos no Próximo Jogo'
                            : '+500 Bonus Points Next Game',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Global ranking
                _buildSection(
                  title: isPT ? 'Ranking Global' : 'Global Ranking',
                  child: Column(
                    children: [
                      _buildRankingItem(
                        label: isPT ? 'Sua Posição' : 'Your Position',
                        value: '#14',
                        isHighlighted: true,
                      ),
                      _buildRankingItem(
                        label: 'MasterSomn',
                        value: '25,120',
                      ),
                      _buildRankingItem(
                        label: 'ChampagneCharlie',
                        value: '23,005',
                      ),
                      _buildRankingItem(
                        label: 'RieslingRider',
                        value: '20,500',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Action points
                _buildSection(
                  title: isPT ? 'Ações' : 'Actions',
                  child: Column(
                    children: [
                      _buildActionItem(
                        isPT ? 'Identificar uva' : 'Identify grape',
                        '+100',
                      ),
                      _buildActionItem(
                        isPT ? 'Identificar região' : 'Identify region',
                        '+50',
                      ),
                      _buildActionItem(
                        isPT ? 'Errar' : 'Wrong guess',
                        '-25',
                        isNegative: true,
                      ),
                      _buildActionItem(
                        isPT ? 'Completar degustação' : 'Complete tasting',
                        '+250',
                      ),
                      _buildActionItem(
                        isPT ? 'Pontuação perfeita' : 'Perfect score',
                        '+500',
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B2B5F),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildRewardItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFF4B2B5F)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildRankingItem({
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF4B2B5F) : Colors.grey.shade600,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF4B2B5F) : Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: isNegative ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
