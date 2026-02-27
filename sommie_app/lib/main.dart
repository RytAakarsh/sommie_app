import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'data/providers/language_provider.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/chat_provider.dart';
import 'data/providers/cellar_provider.dart';
import 'data/providers/pro_view_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'routes/app_routes.dart';
import 'presentation/translations/translations_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString(AppConstants.languageKey) ?? 'en';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider(savedLanguage)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CellarProvider()),
        ChangeNotifierProvider(create: (_) => ProViewProvider()), // Added ProViewProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          locale: Locale(languageProvider.currentLanguage),
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}

// AppLocalizations class for translations
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static const delegate = _AppLocalizationsDelegate();
  
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app.title': 'Sommie',
      'app.subtitle': 'Your Personal Sommelier with AI',
      'auth.login': 'Login',
      'auth.signup': 'Sign Up',
      'auth.email': 'Email',
      'auth.password': 'Password',
      'auth.submit': 'Submit',
      'auth.cancel': 'Cancel',
      'auth.newUser': 'New User?',
      'auth.existingUser': 'Already have an account?',
      'auth.forgotPassword': 'Forgot Password?',
      'auth.invalidCredentials': 'Invalid email or password',
      'signup.name': 'Full Name',
      'signup.age': 'Age',
      'signup.ageError': 'Must be 18 or older',
      'signup.password': 'Password',
      'signup.passwordError': 'Must include uppercase, number, and special character',
      'signup.confirmPassword': 'Confirm Password',
      'signup.passwordMismatch': 'Passwords do not match',
      'signup.country': 'Country',
      'signup.selectCountry': 'Select your country',
      'signup.gender': 'Gender',
      'signup.male': 'Male',
      'signup.female': 'Female',
      'signup.other': 'Other',
      'signup.genderRequired': 'Gender is required',
      'signup.confirmPasswordRequired': 'Please confirm your password',
      'signup.countryRequired': 'Country is required',
      'signup.nextStep': 'Next: Choose Your Plan',
      'signup.error': 'Signup failed',
      
      // Plans
      'plan.title': 'Choose Your Plan',
      'plan.freemium': 'Freemium',
      'plan.pro': 'PRO',
      'plan.freemiumDesc': 'Basic analysis',
      'plan.proDesc': 'Advanced analysis',
      'plan.selectPlan': 'Select Plan',
      'plan.upgradeLater': 'Upgrade Later',
      'plan.recommended': 'RECOMMENDED',
      'plan.perMonth': '/month',
      'plan.feature1': 'Personalized wine recommendations',
      'plan.feature2': 'Advanced AI wine analysis',
      'plan.feature3': 'Basic food pairing suggestions',
      'plan.feature4': 'Premium food & wine pairings',
      'plan.feature5': 'Wine knowledge & tasting tips',
      'plan.feature6': 'Conversation history & memory',
      'plan.feature7': 'Personalized sommelier experience',
      'plan.feature8': 'Priority access to new features',
      
      // Chat
      'chat.welcome': "Hi, I'm Sommie, your virtual sommelier!",
      'chat.description': "I'm an AI passionate about wines — I can answer questions, suggest pairings, share curiosities about grapes, regions, wineries, and recommend the best labels for your palate.",
      'chat.typing': 'Sommie is typing...',
      'chat.placeholder': 'Ask me anything...',
      'chat.newChat': 'New Chat',
      'chat.noChats': 'No matching chats',
      'chat.tryKeyword': 'Try a different keyword',
      'chat.searchPlaceholder': 'Search chats...',
      'chat.delete': 'Delete chat',
      
      // PRO Dashboard
      'pro.welcome': 'Welcome to PRO',
      'pro.wineTourism': 'Wine Tourism Planning',
      'pro.tripsPlanned': 'Trips Planned',
      'pro.restaurantSommelier': 'Restaurant Sommelier',
      'pro.pairingGuide': 'Pairing Guide',
      'pro.virtualCellar': 'Virtual Wine Cellar',
      'pro.wineTracked': 'Wines Tracked',
      'pro.benefitsClub': 'Benefits Club',
      'pro.availableCoupons': 'Available Coupons',
      'pro.sommieGame': 'Sommie Game',
      'pro.score': 'Score',
      'pro.profile': 'Profile',
      'pro.manage': 'Manage',
      'pro.personal': 'Personal',
      'pro.yourHighlights': 'Your Highlights',
      'pro.seeAll': 'See all',
      'pro.latestTrips': 'Latest Tourism Trips',
      
      // PRO Benefits
      'benefits.club': 'Benefits Club',
      'benefits.activeDiscounts': 'Active discounts available',
      'benefits.redeemNow': 'Redeem Now',
      'benefits.wineEcommerce': 'Wine E-commerce',
      'benefits.partners': 'Partners',
      'benefits.wineStores': 'Wine Stores',
      'benefits.restaurants': 'Restaurants',
      'benefits.gameRewards': 'Game Rewards',
      'benefits.accessCategory': 'Access category',
      
      // PRO Game
      'game.currentScore': 'Current Score',
      'game.pointsUntilLevel': 'Points until Level 6',
      'game.levelStart': 'Lvl 5',
      'game.levelTarget': 'Lvl 6',
      'game.playNow': 'Play Now',
      'game.upcomingRewards': 'Upcoming Rewards',
      'game.globalRanking': 'Global Ranking',
      'game.yourPosition': 'Your Position',
      'game.action': 'Action',
      
      // Common
      'common.back': 'Back',
      'common.cancel': 'Cancel',
      'common.continue': 'Continue',
      'common.loading': 'Loading...',
      'common.error': 'Error',
      'common.success': 'Success',
    },
    'pt': {
      'app.title': 'Sommie',
      'app.subtitle': 'Seu Sommelier Pessoal com IA',
      'auth.login': 'Entrar',
      'auth.signup': 'Cadastrar',
      'auth.email': 'Email',
      'auth.password': 'Senha',
      'auth.submit': 'Enviar',
      'auth.cancel': 'Cancelar',
      'auth.newUser': 'Novo Usuário?',
      'auth.existingUser': 'Já tem uma conta?',
      'auth.forgotPassword': 'Esqueceu a senha?',
      'auth.invalidCredentials': 'Email ou senha inválidos',
      'signup.name': 'Nome Completo',
      'signup.age': 'Idade',
      'signup.ageError': 'Deve ter 18 anos ou mais',
      'signup.password': 'Senha',
      'signup.passwordError': 'Deve incluir letra maiúscula, número e caractere especial',
      'signup.confirmPassword': 'Confirmar Senha',
      'signup.passwordMismatch': 'As senhas não coincidem',
      'signup.country': 'País',
      'signup.selectCountry': 'Selecione seu país',
      'signup.gender': 'Gênero',
      'signup.male': 'Masculino',
      'signup.female': 'Feminino',
      'signup.other': 'Outro',
      'signup.genderRequired': 'Gênero é obrigatório',
      'signup.confirmPasswordRequired': 'Por favor, confirme sua senha',
      'signup.countryRequired': 'País é obrigatório',
      'signup.nextStep': 'Próximo: Escolha Seu Plano',
      'signup.error': 'Falha no cadastro',
      
      // Plans
      'plan.title': 'Escolha Seu Plano',
      'plan.freemium': 'Freemium',
      'plan.pro': 'PRO',
      'plan.freemiumDesc': 'Análise básica',
      'plan.proDesc': 'Análise avançada',
      'plan.selectPlan': 'Selecionar Plano',
      'plan.upgradeLater': 'Fazer upgrade depois',
      'plan.recommended': 'RECOMENDADO',
      'plan.perMonth': '/mês',
      'plan.feature1': 'Recomendações personalizadas de vinho',
      'plan.feature2': 'Análise avançada de vinhos com IA',
      'plan.feature3': 'Sugestões básicas de harmonização',
      'plan.feature4': 'Harmonizações premium de comida e vinho',
      'plan.feature5': 'Conhecimento sobre vinhos e dicas de degustação',
      'plan.feature6': 'Histórico de conversas e memória',
      'plan.feature7': 'Experiência personalizada de sommelier',
      'plan.feature8': 'Acesso prioritário a novos recursos',
      
      // Chat
      'chat.welcome': 'Olá, sou a Sommie, sua sommelière virtual!',
      'chat.description': 'Sou uma IA apaixonada por vinhos — posso responder perguntas, sugerir harmonizações, compartilhar curiosidades sobre uvas, regiões, vinícolas e recomendar os melhores rótulos para o seu paladar.',
      'chat.typing': 'Sommie está digitando...',
      'chat.placeholder': 'Pergunte-me qualquer coisa...',
      'chat.newChat': 'Nova Conversa',
      'chat.noChats': 'Nenhuma conversa encontrada',
      'chat.tryKeyword': 'Tente uma palavra-chave diferente',
      'chat.searchPlaceholder': 'Buscar conversas...',
      'chat.delete': 'Excluir conversa',
      
      // PRO Dashboard
      'pro.welcome': 'Bem-vindo ao PRO',
      'pro.wineTourism': 'Planejamento de Enoturismo',
      'pro.tripsPlanned': 'Viagens Planejadas',
      'pro.restaurantSommelier': 'Sommelier de Restaurante',
      'pro.pairingGuide': 'Guia de Harmonização',
      'pro.virtualCellar': 'Adega Virtual',
      'pro.wineTracked': 'Vinhos Rastreados',
      'pro.benefitsClub': 'Clube de Benefícios',
      'pro.availableCoupons': 'Cupons Disponíveis',
      'pro.sommieGame': 'Jogo Sommie',
      'pro.score': 'Pontuação',
      'pro.profile': 'Perfil',
      'pro.manage': 'Gerenciar',
      'pro.personal': 'Pessoal',
      'pro.yourHighlights': 'Seus Destaques',
      'pro.seeAll': 'Ver todos',
      'pro.latestTrips': 'Últimas Viagens Turísticas',
      
      // PRO Benefits
      'benefits.club': 'Clube de Benefícios',
      'benefits.activeDiscounts': 'Descontos ativos disponíveis',
      'benefits.redeemNow': 'Resgatar Agora',
      'benefits.wineEcommerce': 'E-commerce de Vinhos',
      'benefits.partners': 'Parceiros',
      'benefits.wineStores': 'Lojas de Vinho',
      'benefits.restaurants': 'Restaurantes',
      'benefits.gameRewards': 'Recompensas do Jogo',
      'benefits.accessCategory': 'Acessar categoria',
      
      // PRO Game
      'game.currentScore': 'Pontuação Atual',
      'game.pointsUntilLevel': 'Pontos até o Nível 6',
      'game.levelStart': 'Nv 5',
      'game.levelTarget': 'Nv 6',
      'game.playNow': 'Jogar Agora',
      'game.upcomingRewards': 'Próximas Recompensas',
      'game.globalRanking': 'Ranking Global',
      'game.yourPosition': 'Sua Posição',
      'game.action': 'Ação',
      
      // Common
      'common.back': 'Voltar',
      'common.cancel': 'Cancelar',
      'common.continue': 'Continuar',
      'common.loading': 'Carregando...',
      'common.error': 'Erro',
      'common.success': 'Sucesso',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) => ['en', 'pt'].contains(locale.languageCode);
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
