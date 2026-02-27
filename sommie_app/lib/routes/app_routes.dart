import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/auth/plan_selection_screen.dart';
import '../presentation/screens/auth/forgot_password/forgot_password_email.dart';
import '../presentation/screens/auth/forgot_password/forgot_password_otp.dart';
import '../presentation/screens/auth/forgot_password/forgot_password_reset.dart';
import '../presentation/screens/freemium/freemium_chat_screen.dart';
import '../presentation/screens/freemium/free_edit_profile_screen.dart';
import '../presentation/screens/freemium/free_cellar_screen.dart';
import '../presentation/screens/freemium/free_add_wine_screen.dart';
import '../presentation/screens/freemium/free_preview_wine_screen.dart';
import '../presentation/screens/freemium/free_confirm_wine_screen.dart';

// PRO Screens
import '../presentation/screens/pro/pro_dashboard_screen.dart';
import '../presentation/screens/pro/pro_plan_flow_screen.dart';
import '../presentation/screens/pro/pro_profile_page.dart';
// import '../presentation/screens/pro/pro_profile_page.dart';
import '../presentation/screens/pro/pro_chat_panel.dart';
import '../presentation/screens/pro/pro_cellar_page.dart';
import '../presentation/screens/pro/pro_add_wine_page.dart';
import '../presentation/screens/pro/pro_preview_wine_page.dart';
import '../presentation/screens/pro/pro_confirm_wine_page.dart';
import '../presentation/screens/pro/pro_benefits_page.dart';
import '../presentation/screens/pro/pro_game_page.dart';
import '../presentation/screens/pro/pro_wine_stores_page.dart';
import '../presentation/screens/pro/pro_restaurant_page.dart';

class AppRoutes {
  // Splash
  static const String splash = '/';
  
  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String planSelection = '/plan-selection';
  
  // Forgot Password
  static const String forgotPassword = '/forgot-password';
  static const String forgotOtp = '/forgot-otp';
  static const String forgotReset = '/forgot-reset';
  
  // Freemium
  static const String freemiumChat = '/freemium-chat';
  static const String freeEditProfile = '/free-edit-profile';
  static const String freeCellar = '/free-cellar';
  static const String freeAddWine = '/free-add-wine';
  static const String freePreviewWine = '/free-preview-wine';
  static const String freeConfirmWine = '/free-confirm-wine';
  
  // Pro
  static const String proDashboard = '/pro-dashboard';
  static const String proPlanFlow = '/pro-plan-flow';
  static const String proProfile = '/pro-profile';
  static const String proEditProfile = '/pro-edit-profile';
  static const String proChat = '/pro-chat';
  static const String proCellar = '/pro-cellar';
  static const String proAddWine = '/pro-add-wine';
  static const String proPreviewWine = '/pro-preview-wine';
  static const String proConfirmWine = '/pro-confirm-wine';
  static const String proBenefits = '/pro-benefits';
  static const String proGame = '/pro-game';
  static const String proWineStores = '/pro-wine-stores';
  static const String proRestaurant = '/pro-restaurant';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      // Auth
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case planSelection:
        return MaterialPageRoute(builder: (_) => const PlanSelectionScreen());
      
      // Forgot Password
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordEmailScreen());
      case forgotOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordOtpScreen(
            email: args?['email'] ?? '',
          ),
        );
      case forgotReset:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordResetScreen(
            email: args?['email'] ?? '',
            otp: args?['otp'] ?? '',
          ),
        );
      
      // Freemium
      case freemiumChat:
        return MaterialPageRoute(builder: (_) => const FreemiumChatScreen());
      case freeEditProfile:
        return MaterialPageRoute(
          builder: (_) => FreeEditProfileScreen(
            onBack: () => Navigator.pop(_),
          ),
        );
      case freeCellar:
        return MaterialPageRoute(
          builder: (_) => FreeCellarScreen(
            setView: (view) {
              Navigator.pop(_);
            },
          ),
        );
      case freeAddWine:
        return MaterialPageRoute(
          builder: (_) => FreeAddWineScreen(
            setView: (view) {
              Navigator.pop(_);
            },
          ),
        );
      case freePreviewWine:
        return MaterialPageRoute(
          builder: (_) => FreePreviewWineScreen(
            setView: (view) {
              Navigator.pop(_);
            },
          ),
        );
      case freeConfirmWine:
        return MaterialPageRoute(
          builder: (_) => FreeConfirmWineScreen(
            setView: (view) {
              Navigator.pop(_);
            },
          ),
        );
      
      // Pro
      case proDashboard:
        return MaterialPageRoute(builder: (_) => const ProDashboardScreen());
      case proPlanFlow:
        return MaterialPageRoute(builder: (_) => const ProPlanFlowScreen());
      // case proProfile:
      //   return MaterialPageRoute(builder: (_) => const ProProfilePage());
      case proEditProfile:
        return MaterialPageRoute(builder: (_) => const ProProfilePage());
      case proChat:
        return MaterialPageRoute(builder: (_) => const ProChatPanel());
      case proCellar:
        return MaterialPageRoute(builder: (_) => const ProCellarPage());
      case proAddWine:
        return MaterialPageRoute(builder: (_) => const ProAddWinePage());
      case proPreviewWine:
        return MaterialPageRoute(builder: (_) => const ProPreviewWinePage());
      case proConfirmWine:
        return MaterialPageRoute(builder: (_) => const ProConfirmWinePage());
      case proBenefits:
        return MaterialPageRoute(builder: (_) => const ProBenefitsPage());
      case proGame:
        return MaterialPageRoute(builder: (_) => const ProGamePage());
      case proWineStores:
        return MaterialPageRoute(builder: (_) => const ProWineStoresPage());
      case proRestaurant:
        return MaterialPageRoute(builder: (_) => const ProRestaurantPage());
      
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
