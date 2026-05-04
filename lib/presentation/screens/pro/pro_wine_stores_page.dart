import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';

class ProWineStoresPage extends StatelessWidget {
  const ProWineStoresPage({super.key});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPT ? 'Lojas Físicas de Vinho' : 'Wine Physical Stores',
              style: const TextStyle(
                color: Color(0xFF4B2B5F),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              isPT ? '12 Parceiros disponíveis' : '12 Partners available',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4E8FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: 'popularity',
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'popularity',
                          child: Text(isPT ? 'Popularidade' : 'Popularity'),
                        ),
                        DropdownMenuItem(
                          value: 'discount',
                          child: Text(isPT ? 'Desconto' : 'Discount'),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text(isPT ? 'Nome' : 'Name'),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Bottom padding for nav
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildPartnerCard(isPT);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(bool isPT) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E8FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFE0D4EA),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'JH',
                style: TextStyle(
                  color: Color(0xFF4B2B5F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Glow Yoga Studio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2B5F),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPT
                      ? 'Aulas diárias de Flow Zen e Power Vinyasa'
                      : 'Daily Zen Flow and Power Vinyasa classes',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '20% ${isPT ? 'off' : 'off'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2B5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isPT ? 'Acessar' : 'Access',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
