import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../onboarding/language_screen.dart';
import '../onboarding/welcome_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'email_verification_screen.dart';
import 'plan_selection_screen.dart';
import 'ai_terms_screen.dart';
import 'forgot_password/forgot_password_email_screen.dart';
import 'forgot_password/forgot_password_otp_screen.dart';
import 'forgot_password/forgot_password_reset_screen.dart';

class AuthFlowScreen extends StatelessWidget {
  const AuthFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<AuthFlowProvider>(context);

    switch (flow.currentStep) {
      case AuthStep.language:
        return const LanguageScreen();
        
      case AuthStep.welcome:
        return const WelcomeScreen();
        
      case AuthStep.login:
        return const LoginScreen();
        
      case AuthStep.signup:
        return const SignupScreen();
        
      case AuthStep.verification:
        return const EmailVerificationScreen();
        
      case AuthStep.plans:
        return const PlanSelectionScreen();
        
      case AuthStep.aiTerms:
        return const AITermsScreen();
        
      case AuthStep.forgotEmail:
        return const ForgotPasswordEmailScreen();
        
      case AuthStep.forgotOtp:
        return const ForgotPasswordOtpScreen();
        
      case AuthStep.resetPassword:
        return const ForgotPasswordResetScreen();
        
      case AuthStep.freemium:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/freemium-chat');
        });
        return const SizedBox.shrink();
        
      case AuthStep.proFlow:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/pro-payment');
        });
        return const SizedBox.shrink();
        
      default:
        return const LanguageScreen();
    }
  }
}
