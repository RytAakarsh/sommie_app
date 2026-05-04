
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../data/providers/auth_flow_provider.dart';
// import '../../../data/providers/language_provider.dart';
// import '../../translations/translations_extension.dart';

// class PlanSelectionScreen extends StatefulWidget {
//   const PlanSelectionScreen({super.key});

//   @override
//   State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
// }

// class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
//   String? _selectedPlan;

//   @override
//   Widget build(BuildContext context) {
//     final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF7FB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
//           onPressed: () {
//             final flow = Provider.of<AuthFlowProvider>(context, listen: false);
//             flow.setStep(AuthStep.verification);
//           },
//         ),
//         title: Image.asset(
//           'assets/images/pro-logo.png',
//           height: 40,
//           errorBuilder: (context, error, stackTrace) => 
//               const Text('Sommie', style: TextStyle(color: Color(0xFF4B2B5F))),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             Center(
//               child: Text(
//                 context.tr('plan.title'),
//                 style: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF4B2B5F),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             Center(
//               child: Text(
//                 context.tr('app.subtitle'),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
            
//             const SizedBox(height: 32),
            
//             // Freemium Plan Card
//             _buildPlanCard(
//               title: context.tr('plan.freemium'),
//               badge: isPT ? 'GRATUITO' : 'FREE',
//               subtitle: isPT ? 'Gratuito, para sempre.' : 'Free, forever.',
//               description: isPT 
//                   ? 'Perfeito para quem está começando sua jornada no mundo do vinho.'
//                   : 'Perfect for those starting their journey in the wine world.',
//               features: [
//                 {'text': context.tr('plan.feature1'), 'included': true},
//                 {'text': context.tr('plan.feature3'), 'included': true},
//                 {'text': context.tr('plan.feature5'), 'included': true, 'limited': true, 'limit': '6'},
//                 {'text': isPT ? 'Agente Digital de Viagens' : 'Digital Travel Agent', 'included': false},
//                 {'text': isPT ? 'Sommelier de Bolso' : 'Pocket Sommelier', 'included': false},
//                 {'text': isPT ? 'Clube de Benefícios' : 'Benefits Club', 'included': false},
//               ],
//               isSelected: _selectedPlan == 'freemium',
//               isPro: false,
//               onTap: () {
//                 setState(() {
//                   _selectedPlan = 'freemium';
//                 });
//               },
//               onSelect: () => _handlePlanSelection('freemium'),
//             ),
            
//             const SizedBox(height: 16),
            
//             // PRO Plan Card
//             Stack(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: _selectedPlan == 'pro'
//                           ? const Color(0xFF6D3FA6)
//                           : const Color(0xFF4B2B5F).withOpacity(0.3),
//                       width: _selectedPlan == 'pro' ? 2 : 1,
//                     ),
//                   ),
//                   child: _buildPlanCard(
//                     title: context.tr('plan.pro'),
//                     badge: 'PRO',
//                     subtitle: isPT ? 'Assinatura Mensal ou Anual' : 'Monthly or Annual Subscription',
//                     description: isPT 
//                         ? 'Para quem deseja avançar no mundo do vinho.'
//                         : 'For those who want to advance in the wine world.',
//                     features: [
//                       {'text': context.tr('plan.feature2'), 'included': true, 'expanded': true},
//                       {'text': context.tr('plan.feature4'), 'included': true, 'expanded': true},
//                       {'text': context.tr('plan.feature6'), 'included': true},
//                       {'text': context.tr('plan.feature7'), 'included': true},
//                       {'text': context.tr('plan.feature8'), 'included': true},
//                     ],
//                     isSelected: _selectedPlan == 'pro',
//                     isPro: true,
//                     onTap: () {
//                       setState(() {
//                         _selectedPlan = 'pro';
//                       });
//                     },
//                     onSelect: () => _handlePlanSelection('pro'),
//                   ),
//                 ),
//                 // Recommended badge
//                 Positioned(
//                   top: -10,
//                   right: 20,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF6D3FA6), Color(0xFF4B2B5F)],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       context.tr('plan.recommended'),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlanCard({
//     required String title,
//     required String badge,
//     required String subtitle,
//     required String description,
//     required List<Map<String, dynamic>> features,
//     required bool isSelected,
//     required bool isPro,
//     required VoidCallback onTap,
//     required VoidCallback onSelect,
//   }) {
//     final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//           border: isSelected
//               ? Border.all(color: const Color(0xFF4B2B5F), width: 2)
//               : null,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF4B2B5F),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: isPro ? const Color(0xFF6D3FA6) : Colors.green,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             badge,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       isPro ? '€29.90' : '€0',
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF4B2B5F),
//                       ),
//                     ),
//                     Text(
//                       isPT ? '/mês' : '/month',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 12),
            
//             Text(
//               description,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey,
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             const Divider(),
            
//             const SizedBox(height: 16),
            
//             // Features
//             Text(
//               isPT ? 'Funcionalidades Incluídas' : 'Included Features',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF4B2B5F),
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             ...features.map((feature) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 children: [
//                   Icon(
//                     feature['included'] == true 
//                         ? (isPro ? Icons.bolt : Icons.check_circle)
//                         : Icons.block,
//                     size: 20,
//                     color: feature['included'] == true
//                         ? (isPro ? const Color(0xFF6D3FA6) : const Color(0xFF4B2B5F))
//                         : Colors.grey.shade400,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       feature['text'],
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: feature['included'] == true ? Colors.black87 : Colors.grey,
//                         decoration: feature['included'] == true ? null : TextDecoration.lineThrough,
//                       ),
//                     ),
//                   ),
//                   if (feature['limited'] == true)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF4B2B5F).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         isPT ? 'Limitado a ${feature['limit']} rótulos' : 'Limited to ${feature['limit']} bottles',
//                         style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF4B2B5F),
//                         ),
//                       ),
//                     ),
//                   if (feature['expanded'] == true)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF6D3FA6).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         isPT ? 'Limitado a ${feature['limit'] ?? '60'} rótulos' : 'Limited to ${feature['limit'] ?? '60'} bottles',
//                         style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF6D3FA6),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             )).toList(),
            
//             const SizedBox(height: 24),
            
//             // Select button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: onSelect,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isPro
//                       ? const Color(0xFF6D3FA6)
//                       : const Color(0xFF4B2B5F),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   isPT ? 'Começar' : 'Start',
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _handlePlanSelection(String plan) async {
//     final flow = Provider.of<AuthFlowProvider>(context, listen: false);
    
//     // Store selected plan
//     flow.setSelectedPlan(plan);
    
//     // Go to AI Terms
//     flow.setStep(AuthStep.aiTerms);
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../data/providers/auth_flow_provider.dart';
// import '../../../data/providers/language_provider.dart';
// import '../../translations/translations_extension.dart';

// class PlanSelectionScreen extends StatefulWidget {
//   const PlanSelectionScreen({super.key});

//   @override
//   State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
// }

// class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
//   String? _selectedPlan;
//   bool _isLoading = false;

//   // Translations matching web version
//   Map<String, dynamic> _getTranslations(String language) {
//     final isPT = language == 'pt';
    
//     return {
//       'freeBadge': isPT ? 'GRATUITO' : 'FREE',
//       'freeSubtitle': isPT ? 'Gratuito, para sempre.' : 'Free, forever.',
//       'freeDesc': isPT 
//           ? 'Perfeito para quem está começando sua jornada no mundo do vinho.'
//           : 'Perfect for those starting their journey in the wine world.',
//       'includedFeatures': isPT ? 'Funcionalidades Incluídas' : 'Included Features',
//       'proExclusive': isPT ? 'EXCLUSIVO DO PRO' : 'PRO EXCLUSIVE',
//       'blocked': isPT ? 'BLOQUEADO' : 'LOCKED',
//       'startFree': isPT ? 'Começar Gratuitamente' : 'Start Free',
//       'proBadge': 'PRO',
//       'proSubtitle': isPT ? '' : '',
//       'proDesc': isPT 
//           ? 'Para quem deseja avançar no mundo do vinho.'
//           : 'For those who want to advance in the wine world.',
//       'everythingInFreemium': isPT ? 'TUDO DO FREEMIUM, MAIS:' : 'EVERYTHING IN FREEMIUM, PLUS:',
//       'proExclusives': isPT ? 'EXCLUSIVIDADES PRO' : 'PRO EXCLUSIVES',
//       'subscribeNow': isPT ? 'Descubra o Sommie Pro' : 'Discover Sommie Pro',
//       'educationalContent': isPT ? 'Conteúdo Educativo sobre vinhos' : 'Educational Wine Content',
//       'smartPairing': isPT ? 'Harmonização Inteligente personalizada' : 'Smart Personalized Pairing',
//       'virtualCellar': isPT ? 'Adega Virtual' : 'Virtual Cellar',
//       'basicGamification': isPT ? 'Gamificação Básica com pontos e conquistas' : 'Basic Gamification with points and achievements',
//       'expandedCellar': isPT ? 'Adega Virtual Expandida para até 60 rótulos' : 'Expanded Virtual Cellar up to 60 labels',
//       'advancedGamification': isPT ? 'Gamificação Avançada com rankings, eventos e prêmios' : 'Advanced Gamification with rankings, events & prizes',
//       'travelAgent': isPT ? 'Agente Digital de Viagens para explorar regiões vinícolas' : 'Digital Travel Agent to explore wine regions',
//       'pocketSommelier': isPT ? 'Sommelier de Bolso em restaurantes em tempo real' : 'Real-time Restaurant Pocket Sommelier',
//       'benefitsClub': isPT ? 'Clube de Benefícios com descontos exclusivos em parceiros' : 'Benefits Club with exclusive partner discounts',
//       'limitedTo': isPT ? '' : '',
//       'bottles': isPT ? '' : '',
//       'priceFree': '',
//       'pricePro': '',
//       'perMonth': isPT ? '' : '',
//       'recommended': isPT ? 'RECOMENDADO' : 'RECOMMENDED',
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context);
//     final isPT = languageProvider.currentLanguage == 'pt';
//     final t = _getTranslations(languageProvider.currentLanguage);

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.white, Color(0xFFF3E8FF)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.95),
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade200),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
//                     onPressed: _isLoading ? null : () {
//                       final flow = Provider.of<AuthFlowProvider>(context, listen: false);
//                       flow.setStep(AuthStep.verification);
//                     },
//                   ),
//                   Expanded(
//                     child: Image.asset(
//                       'assets/images/pro-logo.png',
//                       height: 40,
//                       errorBuilder: (context, error, stackTrace) => 
//                           const Text('Sommie', style: TextStyle(color: Color(0xFF4B2B5F), fontSize: 20)),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Spacer for alignment
//                 ],
//               ),
//             ),

//             // Main Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     // Section Title
//                     const SizedBox(height: 20),
//                     Text(
//                       context.tr('plan.title'),
//                       style: const TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF4B2B5F),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       context.tr('cta.desc'),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 40),

//                     // Freemium Plan Card
//                     _buildFreemiumCard(t, _selectedPlan == 'freemium', () {
//                       if (!_isLoading) {
//                         setState(() => _selectedPlan = 'freemium');
//                         _handlePlanSelection('freemium');
//                       }
//                     }),

//                     const SizedBox(height: 20),

//                     // PRO Plan Card
//                     _buildProCard(t, _selectedPlan == 'pro', () {
//                       if (!_isLoading) {
//                         setState(() => _selectedPlan = 'pro');
//                         _handlePlanSelection('pro');
//                       }
//                     }),

//                     const SizedBox(height: 40),

//                     // Footer note
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                       child: Text(
//                         isPT 
//                           ? ''
//                           : '',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFreemiumCard(Map<String, dynamic> t, bool isSelected, VoidCallback onSelect) {
//     final features = [
//       {'key': 'educationalContent', 'included': true, 'icon': Icons.auto_awesome},
//       {'key': 'smartPairing', 'included': true, 'icon': Icons.bolt},
//       {'key': 'virtualCellar', 'included': true, 'limited': true, 'limit': '6', 'icon': Icons.layers},
//       {'key': 'basicGamification', 'included': true, 'icon': Icons.emoji_events},
//       {'key': 'travelAgent', 'included': false, 'icon': Icons.public},
//       {'key': 'pocketSommelier', 'included': false, 'icon': Icons.wine_bar},
//       {'key': 'benefitsClub', 'included': false, 'icon': Icons.card_giftcard},
//     ];

//     return AnimatedScale(
//       scale: isSelected ? 1.02 : 1.0,
//       duration: const Duration(milliseconds: 200),
//       child: GestureDetector(
//         onTap: onSelect,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//             border: Border.all(
//               color: isSelected ? const Color(0xFF4B2B5F) : Colors.grey.shade200,
//               width: isSelected ? 2 : 1,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header with Icon
//                 Row(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: const Color(0xFF4B2B5F),
//                       ),
//                       child: const Icon(Icons.layers, color: Colors.white, size: 28),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 context.tr('plan.freemium'),
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF4B2B5F),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   t['freeBadge'],
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             t['freeSubtitle'],
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           t['priceFree'],
//                           style: const TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF4B2B5F),
//                           ),
//                         ),
//                         Text(
//                           t['perMonth'],
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Description
//                 Text(
//                   t['freeDesc'],
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey,
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 const Divider(),

//                 const SizedBox(height: 16),

//                 // Features Title
//                 Text(
//                   t['includedFeatures'],
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF4B2B5F),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Features List
//                 ...features.map((feature) => Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         (feature['included'] as bool) ? Icons.check_circle : Icons.lock,
//                         size: 20,
//                         color: (feature['included'] as bool) 
//                             ? const Color(0xFF4B2B5F)
//                             : Colors.grey.shade400,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     t[feature['key']],
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: (feature['included'] as bool)
//                                           ? Colors.black87 
//                                           : Colors.grey,
//                                       decoration: (feature['included'] as bool)
//                                           ? null 
//                                           : TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (feature['limited'] == true && feature['included'] == true)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF4B2B5F).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     '${t['limitedTo']} ${feature['limit']} ${t['bottles']}',
//                                     style: const TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFF4B2B5F),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             if (feature['included'] == false)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade200,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     '🔒 ${t['proExclusive']}',
//                                     style: const TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )).toList(),

//                 const SizedBox(height: 24),

//                 // CTA Button
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF4B2B5F),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: onSelect,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           t['startFree'],
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProCard(Map<String, dynamic> t, bool isSelected, VoidCallback onSelect) {
//     final freemiumPlusFeatures = [
//       {'key': 'educationalContent', 'icon': Icons.auto_awesome},
//       {'key': 'smartPairing', 'icon': Icons.bolt},
//       {'key': 'expandedCellar', 'icon': Icons.layers, 'expanded': true, 'limit': '60'},
//       {'key': 'advancedGamification', 'icon': Icons.emoji_events},
//     ];

//     const proExclusiveFeatures = [
//       {'key': 'travelAgent', 'icon': Icons.public},
//       {'key': 'pocketSommelier', 'icon': Icons.wine_bar},
//       {'key': 'benefitsClub', 'icon': Icons.card_giftcard},
//     ];

//     return AnimatedScale(
//       scale: isSelected ? 1.02 : 1.0,
//       duration: const Duration(milliseconds: 200),
//       child: GestureDetector(
//         onTap: onSelect,
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF6D3FA6), Color(0xFF4B2B5F)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     blurRadius: 25,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: isSelected ? Colors.white : Colors.transparent,
//                   width: isSelected ? 2 : 0,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header with Icon
//                     Row(
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: Colors.white.withOpacity(0.2),
//                           ),
//                           child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     context.tr('plan.pro'),
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: Colors.amber,
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Text(
//                                       t['proBadge'],
//                                       style: const TextStyle(
//                                         color: Color(0xFF4B2B5F),
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 t['proSubtitle'],
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               t['pricePro'],
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Text(
//                               t['perMonth'],
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white70,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Description
//                     Text(
//                       t['proDesc'],
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.white70,
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     const Divider(color: Colors.white24),

//                     const SizedBox(height: 16),

//                     // Everything in Freemium Plus
//                     Row(
//                       children: [
//                         const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
//                         const SizedBox(width: 8),
//                         Text(
//                           t['everythingInFreemium'],
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     // Freemium Plus Features
//                     ...freemiumPlusFeatures.map((feature) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.check_circle, color: Colors.amber, size: 20),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   t[feature['key']],
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 if (feature['expanded'] == true)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 4),
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                       decoration: BoxDecoration(
//                                         color: Colors.amber.withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Text(
//                                         '${t['limitedTo']} ${feature['limit']} ${t['bottles']}',
//                                         style: const TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.amber,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     )).toList(),

//                     const SizedBox(height: 16),

//                     // PRO Exclusives
//                     Row(
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 16),
//                         const SizedBox(width: 8),
//                         Text(
//                           t['proExclusives'],
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     // Pro Exclusive Features
//                     ...proExclusiveFeatures.map((feature) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.bolt, color: Colors.amber, size: 20),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               t[feature['key']],
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )).toList(),

//                     const SizedBox(height: 24),

//                     // CTA Button
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Colors.white, Colors.white],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: ElevatedButton(
//                         onPressed: onSelect,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: const Color(0xFF4B2B5F),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               t['subscribeNow'],
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             const Icon(Icons.arrow_upward, size: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // Recommended Badge
//             Positioned(
//               top: -10,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF6D3FA6), Color(0xFF4B2B5F)],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.workspace_premium, size: 12, color: Colors.white),
//                     const SizedBox(width: 4),
//                     Text(
//                       t['recommended'],
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _handlePlanSelection(String plan) async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(
//         child: Material(
//           color: Colors.transparent,
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
//           ),
//         ),
//       ),
//     );

//     try {
//       final flow = Provider.of<AuthFlowProvider>(context, listen: false);
      
//       // Store selected plan
//       flow.setSelectedPlan(plan);
      
//       // Wait a moment for UX
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       if (mounted) {
//         Navigator.pop(context); // Close loading dialog
//         // Go to AI Terms
//         flow.setStep(AuthStep.aiTerms);
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.pop(context); // Close loading dialog
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../translations/translations_extension.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  String? _selectedPlan;
  bool _isLoading = false;

  // Translations matching web version
  Map<String, dynamic> _getTranslations(String language) {
    final isPT = language == 'pt';
    
    return {
      'freeBadge': isPT ? 'GRATUITO' : 'FREE',
      'freeSubtitle': isPT ? 'Gratuito, para sempre.' : 'Free, forever.',
      'freeDesc': isPT 
          ? 'Perfeito para quem está começando sua jornada no mundo do vinho.'
          : 'Perfect for those starting their journey in the wine world.',
      'includedFeatures': isPT ? 'Funcionalidades Incluídas' : 'Included Features',
      'proExclusive': isPT ? 'EXCLUSIVO DO PRO' : 'PRO EXCLUSIVE',
      'blocked': isPT ? 'BLOQUEADO' : 'LOCKED',
      'startFree': isPT ? 'Começar Gratuitamente' : 'Start Free',
      'proBadge': 'PRO',
      'proSubtitle': isPT ? '' : '',
      'proDesc': isPT 
          ? 'Para quem deseja avançar no mundo do vinho.'
          : 'For those who want to advance in the wine world.',
      'everythingInFreemium': isPT ? 'TUDO DO FREEMIUM, MAIS:' : 'EVERYTHING IN FREEMIUM, PLUS:',
      'proExclusives': isPT ? 'EXCLUSIVIDADES PRO' : 'PRO EXCLUSIVES',
      'subscribeNow': isPT ? 'Descubra o Sommie Pro' : 'Discover Sommie Pro ↑',
      'educationalContent': isPT ? 'Conteúdo Educativo sobre vinhos' : 'Educational Wine Content',
      'smartPairing': isPT ? 'Harmonização Inteligente personalizada' : 'Smart Personalized Pairing',
      'virtualCellar': isPT ? 'Adega Virtual' : 'Virtual Cellar',
      'basicGamification': isPT ? 'Gamificação Básica com pontos e conquistas' : 'Basic Gamification with points and achievements',
      'expandedCellar': isPT ? 'Adega Virtual Expandida' : 'Expanded Virtual Cellar',
      'advancedGamification': isPT ? 'Gamificação Avançada com rankings, eventos e prêmios' : 'Advanced Gamification with rankings, events & prizes',
      'travelAgent': isPT ? 'Agente Digital de Viagens para explorar regiões vinícolas' : 'Digital Travel Agent to explore wine regions',
      'pocketSommelier': isPT ? 'Sommelier de Bolso em restaurantes em tempo real' : 'Real-time Restaurant Pocket Sommelier',
      'benefitsClub': isPT ? 'Clube de Benefícios com descontos exclusivos em parceiros' : 'Benefits Club with exclusive partner discounts',
      'limitedTo': isPT ? '' : '',
      'bottles': isPT ? '' : '',
      'priceFree': '',
      'pricePro': '',
      'perMonth': isPT ? '' : '',
      'recommended': isPT ? 'RECOMENDADO' : 'RECOMMENDED',
    };
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isPT = languageProvider.currentLanguage == 'pt';
    final t = _getTranslations(languageProvider.currentLanguage);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF3E8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
                    onPressed: _isLoading ? null : () {
                      final flow = Provider.of<AuthFlowProvider>(context, listen: false);
                      flow.setStep(AuthStep.verification);
                    },
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/pro-logo.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => 
                          const Text('Sommie', style: TextStyle(color: Color(0xFF4B2B5F), fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Section Title
                    const SizedBox(height: 20),
                    Text(
                      context.tr('plan.title'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2B5F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('cta.desc'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Freemium Plan Card
                    _buildFreemiumCard(t, _selectedPlan == 'freemium', () {
                      if (!_isLoading) {
                        setState(() => _selectedPlan = 'freemium');
                        _handlePlanSelection('freemium');
                      }
                    }),

                    const SizedBox(height: 20),

                    // PRO Plan Card
                    _buildProCard(t, _selectedPlan == 'pro', () {
                      if (!_isLoading) {
                        setState(() => _selectedPlan = 'pro');
                        _handlePlanSelection('pro');
                      }
                    }),

                    const SizedBox(height: 40),

                    // Footer note
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Text(
                        isPT 
                          ? ''
                          : '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreemiumCard(Map<String, dynamic> t, bool isSelected, VoidCallback onSelect) {
    final features = [
      {'key': 'educationalContent', 'included': true, 'icon': Icons.auto_awesome},
      {'key': 'smartPairing', 'included': true, 'icon': Icons.bolt},
      {'key': 'virtualCellar', 'included': true, 'limited': true, 'limit': 'Upto 6 bottles', 'icon': Icons.layers},
      {'key': 'basicGamification', 'included': true, 'icon': Icons.emoji_events},
      {'key': 'travelAgent', 'included': false, 'icon': Icons.public},
      {'key': 'pocketSommelier', 'included': false, 'icon': Icons.wine_bar},
      {'key': 'benefitsClub', 'included': false, 'icon': Icons.card_giftcard},
    ];

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFF4B2B5F) : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF4B2B5F),
                      ),
                      child: const Icon(Icons.layers, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                context.tr('plan.freemium'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B2B5F),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  t['freeBadge'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            t['freeSubtitle'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          t['priceFree'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B2B5F),
                          ),
                        ),
                        Text(
                          t['perMonth'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  t['freeDesc'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 16),

                // Features Title
                Text(
                  t['includedFeatures'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2B5F),
                  ),
                ),

                const SizedBox(height: 16),

                // Features List
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        (feature['included'] as bool) ? Icons.check_circle : Icons.lock,
                        size: 20,
                        color: (feature['included'] as bool) 
                            ? const Color(0xFF4B2B5F)
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t[feature['key']],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: (feature['included'] as bool)
                                          ? Colors.black87 
                                          : Colors.grey,
                                      decoration: (feature['included'] as bool)
                                          ? null 
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (feature['limited'] == true && feature['included'] == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4B2B5F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${t['limitedTo']} ${feature['limit']} ${t['bottles']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B2B5F),
                                    ),
                                  ),
                                ),
                              ),
                            if (feature['included'] == false)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '🔒 ${t['proExclusive']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),

                const SizedBox(height: 24),

                // CTA Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B2B5F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t['startFree'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(Map<String, dynamic> t, bool isSelected, VoidCallback onSelect) {
    final freemiumPlusFeatures = [
      {'key': 'educationalContent', 'icon': Icons.auto_awesome},
      {'key': 'smartPairing', 'icon': Icons.bolt},
      {'key': 'expandedCellar', 'icon': Icons.layers, 'expanded': true}, 
      {'key': 'advancedGamification', 'icon': Icons.emoji_events},
    ];

    const proExclusiveFeatures = [
      {'key': 'travelAgent', 'icon': Icons.public},
      {'key': 'pocketSommelier', 'icon': Icons.wine_bar},
      {'key': 'benefitsClub', 'icon': Icons.card_giftcard},
    ];

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onSelect,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D3FA6), Color(0xFF4B2B5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: isSelected ? 2 : 0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with PRO Icon (Updated with pro-icon.png in square box)
                    Row(
                      children: [
                        // Square box with PRO icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/pro-icon.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row with PRO text and crown icon (replaced golden badge)
                              Row(
                                children: [
                                  Text(
                                    context.tr('plan.pro'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/images/crown.png',
                                    width: 18,
                                    height: 18,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                                  ),
                                ],
                              ),
                              Text(
                                t['proSubtitle'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              t['pricePro'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              t['perMonth'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      t['proDesc'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Divider(color: Colors.white24),

                    const SizedBox(height: 16),

                    // Everything in Freemium Plus
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          t['everythingInFreemium'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Freemium Plus Features
                    ...freemiumPlusFeatures.map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.amber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t[feature['key']],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),

                    const SizedBox(height: 16),

                    // PRO Exclusives
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          t['proExclusives'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Pro Exclusive Features
                    ...proExclusiveFeatures.map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t[feature['key']],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),

                    const SizedBox(height: 24),

                    // CTA Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4B2B5F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t['subscribeNow'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_upward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Recommended Badge
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D3FA6), Color(0xFF4B2B5F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      t['recommended'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlanSelection(String plan) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Material(
          color: Colors.transparent,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
          ),
        ),
      ),
    );

    try {
      final flow = Provider.of<AuthFlowProvider>(context, listen: false);
      
      // Store selected plan
      flow.setSelectedPlan(plan);
      
      // Wait a moment for UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        // Go to AI Terms
        flow.setStep(AuthStep.aiTerms);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}