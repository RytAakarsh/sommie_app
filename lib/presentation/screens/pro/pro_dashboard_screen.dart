// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../data/providers/pro_view_provider.dart';
// import '../../../data/providers/language_provider.dart';
// import 'pro_header.dart';
// import 'pro_bottom_nav.dart';
// import 'pro_profile_panel.dart';
// import 'widgets/pro_card.dart';
// import 'widgets/pro_highlight.dart';
// import 'pro_profile_page.dart';  // Make sure this import exists
// import 'pro_edit_profile_page.dart';  // Make sure this import exists
// import 'pro_chat_panel.dart';
// import 'pro_cellar_page.dart';
// import 'pro_add_wine_page.dart';
// import 'pro_preview_wine_page.dart';
// import 'pro_confirm_wine_page.dart';
// import 'pro_benefits_page.dart';
// import 'pro_game_page.dart';
// import 'pro_wine_stores_page.dart';
// import 'pro_restaurant_page.dart';


// class ProDashboardScreen extends StatelessWidget {
//   const ProDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF7FB),
//       body: Consumer<ProViewProvider>(
//         builder: (context, viewProvider, child) {
//           return Stack(
//             children: [
//               Column(
//                 children: [
//                   const ProHeader(),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         // Left panel (visible on larger screens)
//                         if (MediaQuery.of(context).size.width > 1200)
//                           const ProProfilePanel(),

//                         // Main content
//                         Expanded(
//                           child: _buildMainContent(viewProvider.currentView),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               // Bottom navigation (visible on mobile)
//               if (MediaQuery.of(context).size.width <= 1200 &&
//                   viewProvider.currentView != ProView.chat)
//                 const ProBottomNav(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildMainContent(ProView view) {
//     switch (view) {
//       case ProView.dashboard:
//         return const _DashboardContent();
//       case ProView.profile:
//       print('📱 Showing Profile Page');
//       return const ProProfilePage();
//     // case ProView.editProfile:
//     //   print('📱 Showing Edit Profile Page');
//     //   return const ProEditProfilePage();
//       case ProView.chat:
//         return const ProChatPanel();
//       case ProView.cellar:
//         return const ProCellarPage();
//       case ProView.cellarAdd:
//         return const ProAddWinePage();
//       // case ProView.cellarPreview:
//       //   return const ProPreviewWinePage();
//       // case ProView.cellarConfirm:
//       //   return const ProConfirmWinePage();
//       case ProView.benefits:
//         return const ProBenefitsPage();
//       case ProView.game:
//         return const ProGamePage();
//       case ProView.wineStores:
//         return const ProWineStoresPage();
//       case ProView.restaurantPocket:
//         return const ProRestaurantPage();
//       default:
//         return const _DashboardContent();
//     }
//   }
// }

// class _DashboardContent extends StatelessWidget {
//   const _DashboardContent();

//   @override
//   Widget build(BuildContext context) {
//     final viewProvider = Provider.of<ProViewProvider>(context, listen: false);
//     final languageProvider = Provider.of<LanguageProvider>(context);
//     final isPT = languageProvider.currentLanguage == 'pt';
//     final screenWidth = MediaQuery.of(context).size.width;
//     final crossAxisCount = screenWidth > 800 ? 4 : 2;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
//       child: Column(
//         children: [
//           // Cards grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: crossAxisCount,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: 1.4,
//             children: [
//               ProCard(
//                 title: isPT ? 'Planejamento de Enoturismo' : 'Wine Tourism Planning',
//                 value: 3,
//                 subtitle: isPT ? 'Viagens Planejadas' : 'Trips Planned',
//                 icon: Icons.flight_takeoff,
//                 onTap: () => viewProvider.setView(ProView.chat),
//               ),
//               ProCard(
//                 title: isPT ? 'Sommelier de Restaurante' : 'Restaurant Sommelier',
//                 value: 'AI',
//                 subtitle: isPT ? 'Guia de Harmonização' : 'Pairing Guide',
//                 icon: Icons.restaurant,
//                 onTap: () => viewProvider.setView(ProView.restaurantPocket),
//               ),
//               ProCard(
//                 title: isPT ? 'Adega Virtual' : 'Virtual Wine Cellar',
//                 value: 145,
//                 subtitle: isPT ? 'Vinhos Rastreados' : 'Wines Tracked',
//                 icon: Icons.wine_bar,
//                 onTap: () => viewProvider.setView(ProView.cellar),
//               ),
//               ProCard(
//                 title: isPT ? 'Clube de Benefícios' : 'Benefits Club',
//                 value: 2,
//                 subtitle: isPT ? 'Cupons Disponíveis' : 'Available Coupons',
//                 icon: Icons.card_giftcard,
//                 onTap: () => viewProvider.setView(ProView.benefits),
//               ),
//               ProCard(
//                 title: isPT ? 'Jogo Sommie' : 'Sommie Game',
//                 value: '8,345',
//                 subtitle: isPT ? 'Pontuação' : 'Score',
//                 icon: Icons.games,
//                 onTap: () => viewProvider.setView(ProView.game),
//               ),
//               ProCard(
//   title: isPT ? 'Perfil' : 'Profile',
//   value: isPT ? 'Gerenciar' : 'Manage',
//   subtitle: isPT ? 'Pessoal' : 'Personal',
//   icon: Icons.person,
//   onTap: () => viewProvider.setView(ProView.profile), // This should go to profile page
// ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Highlights
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: ProHighlight(
//                   title: isPT ? 'Seus Destaques' : 'Your Highlights',
//                   items: const [
//                     {
//                       'title': 'Château Margaux 2018',
//                       'subtitle': 'Bordeaux, France • Added 2 days ago',
//                     },
//                     {
//                       'title': 'Screaming Eagle 2017',
//                       'subtitle': 'Napa Valley, USA • Added 1 week ago',
//                     },
//                   ],
//                   onSeeAll: () {},
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ProHighlight(
//                   title: isPT ? 'Últimas Viagens' : 'Latest Tourism',
//                   items: const [
//                     {
//                       'title': 'Tuscany Vineyard Tour',
//                       'subtitle': 'Italy • Completed Oct 2025',
//                     },
//                     {
//                       'title': 'Willamette Valley Pinots',
//                       'subtitle': 'Upcoming Dec 15th',
//                     },
//                   ],
//                   onSeeAll: () {},
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';

class ProDashboardScreen extends StatefulWidget {
  const ProDashboardScreen({super.key});

  @override
  State<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends State<ProDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        title: const Text('PRO Dashboard'),
        backgroundColor: const Color(0xFF4B2B5F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium,
                size: 80,
                color: Color(0xFF7f488b),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to PRO!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You now have access to all PRO features.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.chat, color: Color(0xFF7f488b)),
                        title: const Text('Advanced AI Chat'),
                        subtitle: const Text('Get personalized wine recommendations'),
                        onTap: () {
                          // Navigate to PRO chat
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.wine_bar, color: Color(0xFF7f488b)),
                        title: const Text('Expanded Cellar'),
                        subtitle: const Text('Store up to 60 wines'),
                        onTap: () {
                          // Navigate to PRO cellar
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.emoji_events, color: Color(0xFF7f488b)),
                        title: const Text('Advanced Gamification'),
                        subtitle: const Text('Earn points and compete'),
                        onTap: () {
                          // Navigate to PRO game
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}