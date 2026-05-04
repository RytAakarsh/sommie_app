import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../routes/app_routes.dart';
import '../../translations/translations_extension.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedCountry = '';
  String _selectedGender = '';
  bool _acceptTerms = false;
  String? _error;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _termsError;
  
  final List<String> _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'France',
    'Spain',
    'Italy',
    'Germany',
    'Portugal',
    'Brazil',
    'Argentina',
    'Mexico',
    'Japan',
    'China',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () {
                    final flow = Provider.of<AuthFlowProvider>(context, listen: false);
                    flow.setStep(AuthStep.login);
                  },
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF4B2B5F),
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  isPT ? 'Criar Conta' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2B5F),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  isPT 
                      ? 'Comece sua jornada no mundo do vinho' 
                      : 'Start your journey in the wine world',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 32),
                
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
                
                // Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPT ? 'Nome Completo' : 'Full Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: isPT ? "Digite seu nome completo" : "Enter your full name",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                        ),
                        validator: Validators.validateName,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Age and Gender Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPT ? 'Idade' : 'Age',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: isPT ? "18+" : "18+",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18),
                                prefixIcon: Icon(Icons.cake_outlined, color: Colors.grey.shade400),
                              ),
                              validator: Validators.validateAge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPT ? 'Gênero' : 'Gender',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender.isEmpty ? null : _selectedGender,
                              decoration: InputDecoration(
                                hintText: isPT ? "Selecione" : "Select",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18),
                                prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'male',
                                  child: Text(isPT ? 'Masculino' : 'Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'female',
                                  child: Text(isPT ? 'Feminino' : 'Female'),
                                ),
                                DropdownMenuItem(
                                  value: 'other',
                                  child: Text(isPT ? 'Outro' : 'Other'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value ?? '';
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return isPT ? 'Gênero é obrigatório' : 'Gender is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: isPT ? "exemplo@email.com" : "example@email.com",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400),
                        ),
                        validator: Validators.validateEmail,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPT ? 'Senha' : 'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: isPT ? "Digite sua senha" : "Enter your password",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: Validators.validatePassword,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPT ? 'Confirmar Senha' : 'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: isPT ? "Confirme sua senha" : "Confirm your password",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isPT ? 'Por favor, confirme sua senha' : 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return isPT ? 'As senhas não coincidem' : 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Country Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPT ? 'País' : 'Country',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry.isEmpty ? null : _selectedCountry,
                        decoration: InputDecoration(
                          hintText: isPT ? "Selecione seu país" : "Select your country",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          prefixIcon: Icon(Icons.public_outlined, color: Colors.grey.shade400),
                        ),
                        items: _countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isPT ? 'País é obrigatório' : 'Country is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Terms & Policy Acceptance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom Checkbox Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                              if (_acceptTerms) {
                                _termsError = null;
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: _acceptTerms
                                ? const Icon(
                                    Icons.check_box,
                                    color: Color(0xFF4B2B5F),
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: isPT 
                                      ? 'Eu concordo com os ' 
                                      : 'I agree to the ',
                                ),
                                TextSpan(
                                  text: isPT ? 'Termos de Uso' : 'Terms of Use',
                                  style: const TextStyle(
                                    color: Color(0xFF4B2B5F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: (TapGestureRecognizer()..onTap = () {
                                    _launchURL('https://sommie.io/Politica-de-Privacidade/index.html');
                                  }),
                                ),
                                TextSpan(
                                  text: isPT ? ' e ' : ' and ',
                                ),
                                TextSpan(
                                  text: isPT ? 'Política de Privacidade' : 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xFF4B2B5F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: (TapGestureRecognizer()..onTap = () {
                                    _launchURL('https://sommie.io/Politica-de-Privacidade/index.html');
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 32),
                        child: Text(
                          _termsError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
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
                          isPT ? "Cadastrar" : "Sign Up",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                
                const SizedBox(height: 20),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isPT ? "Já tem uma conta?" : "Already have an account?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        final flow = Provider.of<AuthFlowProvider>(context, listen: false);
                        flow.setStep(AuthStep.login);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        isPT ? "Entrar" : "Login",
                        style: const TextStyle(
                          color: Color(0xFF6a3a76),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSignup() async {
    // Clear previous error
    setState(() {
      _termsError = null;
    });
    
    // Check if terms are accepted
    if (!_acceptTerms) {
      setState(() {
        _termsError = isPT ? 'Você deve aceitar os Termos de Uso e Política de Privacidade para continuar' : 'You must accept the Terms of Use and Privacy Policy to continue';
      });
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final flow = Provider.of<AuthFlowProvider>(context, listen: false);
        
        final success = await authProvider.signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          age: int.parse(_ageController.text),
          country: _selectedCountry,
          gender: _selectedGender,
        );

        if (success && mounted) {
          // ✅ FIX: Store email and user data for verification, NOT token
          flow.email = _emailController.text.trim();
          flow.userData = {
            'name': _nameController.text.trim(),
            'age': int.parse(_ageController.text),
            'country': _selectedCountry,
            'gender': _selectedGender,
          };
          
          // Go to email verification (NOT directly logged in)
          flow.setStep(AuthStep.verification);
        } else {
          setState(() {
            _error = isPT ? 'Falha no cadastro. Tente novamente.' : 'Signup failed. Please try again.';
          });
        }
      } catch (e) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        
        // Handle duplicate email error
        if (errorMsg.contains('409') || errorMsg.contains('already exists')) {
          errorMsg = isPT 
              ? 'Este email já está cadastrado. Faça login ou use outro email.'
              : 'This email is already registered. Please login or use another email.';
        }
        
        setState(() {
          _error = errorMsg;
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

  bool get isPT => Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'pt';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}