import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../translations/translations_extension.dart';
import '../../../data/providers/language_provider.dart';

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
  String? _error;
  bool _isLoading = false;
  
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

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF4B2B5F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isPT ? 'Cadastro' : 'Sign Up',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                
                // Name
                CustomTextField(
                  label: isPT ? 'Nome Completo' : 'Full Name',
                  controller: _nameController,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                // Age
                CustomTextField(
                  label: isPT ? 'Idade' : 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAge,
                ),
                const SizedBox(height: 16),
                
                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender.isEmpty ? null : _selectedGender,
                  decoration: InputDecoration(
                    labelText: isPT ? 'Gênero' : 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFBF7FB),
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
                const SizedBox(height: 16),
                
                // Email
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Password
                CustomTextField(
                  label: isPT ? 'Senha' : 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                
                // Confirm Password
                CustomTextField(
                  label: isPT ? 'Confirmar Senha' : 'Confirm Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
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
                const SizedBox(height: 16),
                
                // Country
                DropdownButtonFormField<String>(
                  value: _selectedCountry.isEmpty ? null : _selectedCountry,
                  decoration: InputDecoration(
                    labelText: isPT ? 'País' : 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFBF7FB),
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
                const SizedBox(height: 24),
                
                // Signup Button
                CustomButton(
                  text: isPT ? 'Cadastrar' : 'Sign Up',
                  onPressed: _handleSignup,
                  isPrimary: true,
                ),
                
                const SizedBox(height: 16),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isPT ? 'Já tem uma conta?' : 'Already have an account?',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        isPT ? 'Entrar' : 'Login',
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

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final success = await authProvider.signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          age: int.parse(_ageController.text),
          country: _selectedCountry,
          gender: _selectedGender,
        );

        if (success && mounted) {
          // Go to plan selection page after successful signup
          Navigator.pushReplacementNamed(context, AppRoutes.planSelection);
        }
      } catch (e) {
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
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
