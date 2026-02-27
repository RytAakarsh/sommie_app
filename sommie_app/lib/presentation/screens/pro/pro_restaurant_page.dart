import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';

class ProRestaurantPage extends StatelessWidget {
  const ProRestaurantPage({super.key});

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
          isPT ? 'Sommelier de Bolso' : 'Pocket Sommelier',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                // Tips card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E8FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPT ? 'Dicas para fotografar' : 'Tips for capturing',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2B5F),
                              fontSize: 16,
                            ),
                          ),
                          Container(), // Empty container to maintain spacing
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip(
                        isPT
                            ? 'Certifique-se de que o menu está plano e bem iluminado'
                            : 'Ensure the menu is flat and well-lit',
                      ),
                      _buildTip(
                        isPT
                            ? 'Segure o telefone firme para evitar borrões'
                            : 'Hold the phone steady to avoid blur',
                      ),
                      _buildTip(
                        isPT
                            ? 'Fotografe o menu e indique o prato escolhido'
                            : 'Take menu photo and indicate chosen dish',
                      ),
                      _buildTip(
                        isPT
                            ? 'A carta de vinhos deve estar plana e bem iluminada'
                            : 'Wine list should be flat and well-lit',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButton(
                  icon: Icons.camera_alt,
                  label: isPT ? 'Foto do Menu' : 'Take Menu Photo',
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.camera_alt,
                  label: isPT ? 'Foto do Prato' : 'Take Dish Photo',
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    isPT ? 'Ou' : 'Or',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.photo_library,
                  label: isPT ? 'Carregar imagens' : 'Upload images',
                  isSecondary: true,
                ),
                const SizedBox(height: 32),

                // Footer buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => viewProvider.setView(ProView.benefits),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4B2B5F),
                          side: const BorderSide(color: Color(0xFF4B2B5F)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isPT ? 'Cancelar' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                        child: Text(isPT ? 'Analisar' : 'Analyze'),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF4B2B5F), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : const Color(0xFFF4E8FB),
          foregroundColor: const Color(0xFF4B2B5F),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
