// import 'package:flutter/material.dart';

// enum AuthStep {
//   login,
//   signup,
//   verification,
//   plans,
//   aiTerms,
//   freemium,
//   proFlow,
// }

// class AuthFlowProvider extends ChangeNotifier {
//   AuthStep _currentStep = AuthStep.login;
  
//   String email = '';
//   String selectedPlan = ''; // freemium / pro
//   Map<String, dynamic>? userData;
  
//   AuthStep get currentStep => _currentStep;
  
//   void setStep(AuthStep step) {
//     _currentStep = step;
//     notifyListeners();
//   }
  
//   void setSelectedPlan(String plan) {
//     selectedPlan = plan;
//     notifyListeners();
//   }
  
//   void reset() {
//     _currentStep = AuthStep.login;
//     email = '';
//     selectedPlan = '';
//     userData = null;
//     notifyListeners();
//   }
// }



import 'package:flutter/material.dart';

enum AuthStep {
  language,      // NEW - Language selection
  welcome,       // NEW - Welcome slides
  login,
  signup,
  verification,
  plans,
  aiTerms,
  freemium,
  proFlow,
  forgotEmail,   // NEW - Forgot password email
  forgotOtp,     // NEW - Forgot password OTP verification
  resetPassword, // NEW - Reset password
}

class AuthFlowProvider extends ChangeNotifier {
  AuthStep _currentStep = AuthStep.language; // CHANGED: Start with language
  
  String email = '';
  String selectedPlan = ''; // freemium / pro
  Map<String, dynamic>? userData;
  String? forgotPasswordEmail; // Store email for forgot flow
  
  AuthStep get currentStep => _currentStep;
  
  void setStep(AuthStep step) {
    _currentStep = step;
    notifyListeners();
  }
  
  void setSelectedPlan(String plan) {
    selectedPlan = plan;
    notifyListeners();
  }
  
  void setForgotPasswordEmail(String email) {
    forgotPasswordEmail = email;
    this.email = email;
    notifyListeners();
  }
  
  void reset() {
    _currentStep = AuthStep.language;
    email = '';
    selectedPlan = '';
    userData = null;
    forgotPasswordEmail = null;
    notifyListeners();
  }
}
