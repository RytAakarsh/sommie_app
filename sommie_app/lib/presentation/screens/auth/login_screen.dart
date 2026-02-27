import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF4B2B5F),
          elevation: 0,
          title: Text(
            context.tr('auth.login'),
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Sommie Avatar instead of wine glass
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4B2B5F).withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar.webp',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: const Color(0xFFF3E8FF),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF4B2B5F),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Email
                CustomTextField(
                  label: context.tr('auth.email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Password
                CustomTextField(
                  label: context.tr('auth.password'),
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                
                const SizedBox(height: 8),
                
                // Forgot Password
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       Navigator.pushNamed(context, AppRoutes.forgotPassword);
                //     },
                //     child: Text(
                //       context.tr('auth.forgotPassword') ?? 'Forgot Password?',
                //       style: const TextStyle(
                //         color: Color(0xFF4B2B5F),
                //         fontSize: 14,
                //       ),
                //     ),
                //   ),
                // ),
                
                const SizedBox(height: 24),
                
                // Login Button
                CustomButton(
                  text: context.tr('auth.submit'),
                  onPressed: _handleLogin,
                  isPrimary: true,
                ),
                
                const SizedBox(height: 16),
                
                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('auth.newUser'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.signup);
                      },
                      child: Text(
                        context.tr('auth.signup'),
                        style: const TextStyle(
                          color: Color(0xFF4B2B5F),
                          fontWeight: FontWeight.bold,
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _error = null;
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success && mounted) {
          print('✅ Login successful, refreshing providers...');
          
          try {
            final chatProvider = Provider.of<ChatProvider>(context, listen: false);
            final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
            
            await chatProvider.refreshAfterLogin();
            await cellarProvider.refreshAfterLogin();
            
            print('✅ Providers refreshed successfully');
          } catch (e) {
            print('❌ Error refreshing providers: $e');
          }
          
          final user = authProvider.currentUser;
          print('✅ User plan: ${user?.plan}');
          
          if (user?.plan == 'PRO') {
            Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.freemiumChat);
          }
        } else {
          setState(() {
            _error = context.tr('auth.invalidCredentials') ?? 'Invalid email or password';
          });
        }
      } catch (e) {
        print('❌ Login error: $e');
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
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
