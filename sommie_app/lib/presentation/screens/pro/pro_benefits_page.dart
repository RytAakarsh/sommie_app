import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';
import 'widgets/pro_benefit_card.dart';

class ProBenefitsPage extends StatelessWidget {
  const ProBenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    return Scaffold(
      backgroundColor: const Color(0xFFEFECEC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4E8FB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '23',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4B2B5F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPT
                                  ? 'Descontos ativos\ndisponíveis'
                                  : 'Active discounts\navailable',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B2B5F),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B2B5F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(120, 36),
                              ),
                              child: Text(
                                isPT ? 'Resgatar Agora' : 'Redeem Now',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            size: 45,
                            color: Color(0xFF4B2B5F),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                ProBenefitCard(
                  title: isPT ? 'E-commerce de Vinhos' : 'Wine E-commerce',
                  partners: '45 ${isPT ? 'Parceiros' : 'Partners'}',
                  icon: Icons.shopping_cart,
                  onAccess: () {},
                ),
                ProBenefitCard(
                  title: isPT ? 'Lojas Físicas' : 'Physical Stores',
                  partners: '12 ${isPT ? 'Parceiros' : 'Partners'}',
                  icon: Icons.store,
                  onAccess: () => viewProvider.setView(ProView.wineStores),
                ),
                ProBenefitCard(
                  title: isPT ? 'Restaurantes' : 'Restaurants',
                  partners: '8 ${isPT ? 'Parceiros' : 'Partners'}',
                  icon: Icons.restaurant,
                  onAccess: () => viewProvider.setView(ProView.restaurantPocket),
                ),
                ProBenefitCard(
                  title: isPT ? 'Recompensas do Jogo' : 'Game Rewards',
                  partners: '7 ${isPT ? 'Parceiros' : 'Partners'}',
                  icon: Icons.sports_esports,
                  onAccess: () => viewProvider.setView(ProView.game),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
