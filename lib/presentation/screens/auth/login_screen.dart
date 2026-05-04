import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../routes/app_routes.dart';
import '../../translations/translations_extension.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final flow = Provider.of<AuthFlowProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/pro-logo.png',
                    width: 180,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Sommie',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2B5F),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Error message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Email field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: isPT ? "E-mail" : "Email",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isPT ? "E-mail é obrigatório" : "Email is required";
                      }
                      // Basic email validation
                      if (!value.contains('@') || !value.contains('.')) {
                        return isPT ? "E-mail inválido" : "Invalid email";
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: isPT ? "Senha" : "Password",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isPT ? "Senha é obrigatória" : "Password is required";
                      }
                      if (value.length < 6) {
                        return isPT ? "Senha deve ter no mínimo 6 caracteres" : "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      flow.setStep(AuthStep.forgotEmail);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      isPT ? "Esqueceu a senha?" : "Forgot Password?",
                      style: const TextStyle(
                        color: Color(0xFF6a3a76),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6a3a76),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isPT ? "Entrar" : "Login",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                
                const SizedBox(height: 20),
                
                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isPT ? "Não possui conta?" : "Don't have an account?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        flow.setStep(AuthStep.signup);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        isPT ? "Cadastre-se" : "Sign up",
                        style: const TextStyle(
                          color: Color(0xFF6a3a76),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    print("🔵 LOGIN BUTTON CLICKED"); // Debug log
    
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _error = null;
        _isLoading = true;
      });

      print("🔵 Form validated, attempting login...");

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        print("🔵 Login result: $success");

        if (success && mounted) {
          try {
            final chatProvider = Provider.of<ChatProvider>(context, listen: false);
            final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
            
            await chatProvider.refreshAfterLogin();
            await cellarProvider.refreshAfterLogin();
          } catch (e) {
            print('Error refreshing providers: $e');
          }
          
          final user = authProvider.currentUser;
          print("🔵 User plan: ${user?.plan}");
          
          if (user?.plan == 'PRO') {
            Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.freemiumChat);
          }
        } else {
          print("🔵 Login failed - setting error message");
          setState(() {
            _error = "Invalid email or password";
          });
        }
      } catch (e) {
        print("🔵 Login exception: $e");
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print("🔵 Form validation failed");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
