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
import '../presentation/screens/pro/pro_dashboard_screen.dart';
import '../presentation/screens/pro/pro_plan_flow_screen.dart';

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
        return MaterialPageRoute(builder: (_) => const Scaffold(
          body: Center(child: Text('Pro Plan Flow - Coming Soon')),
        ));
      
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}