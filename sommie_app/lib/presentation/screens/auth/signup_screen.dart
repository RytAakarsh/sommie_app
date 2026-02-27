import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/validators.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../translations/translations_extension.dart';
import '../../../core/utils/connectivity_helper.dart';

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
    bool _isLoading = false;
  String? _errorMessage;
  String _selectedCountry = '';
  String _selectedGender = '';
  
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
    final authProvider = Provider.of<AuthProvider>(context);
    
    return LoadingOverlay(
      isLoading: authProvider.isLoading,
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
            context.tr('auth.signup'),
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
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Name
                CustomTextField(
                  label: context.tr('signup.name'),
                  controller: _nameController,
                  validator: Validators.validateName,
                ),
                
                const SizedBox(height: 16),
                
                // Age
                CustomTextField(
                  label: context.tr('signup.age'),
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAge,
                ),
                
                const SizedBox(height: 16),
                
                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender.isEmpty ? null : _selectedGender,
                  decoration: InputDecoration(
                    labelText: context.tr('signup.gender'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFBF7FB),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(context.tr('signup.male')),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(context.tr('signup.female')),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.tr('signup.other')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('signup.genderRequired') ?? 'Gender is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
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
                  label: context.tr('signup.password'),
                  controller: _passwordController,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password
                CustomTextField(
                  label: context.tr('signup.confirmPassword'),
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('signup.confirmPasswordRequired') ?? 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return context.tr('signup.passwordMismatch');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Country
                DropdownButtonFormField<String>(
                  value: _selectedCountry.isEmpty ? null : _selectedCountry,
                  decoration: InputDecoration(
                    labelText: context.tr('signup.country'),
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
                      return context.tr('signup.countryRequired') ?? 'Country is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Signup Button
                CustomButton(
                  text: context.tr('signup.nextStep'),
                  onPressed: _handleSignup,
                  isPrimary: true,
                ),
                
                const SizedBox(height: 16),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('auth.existingUser'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        context.tr('auth.login'),
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
      _errorMessage = null;
    });

    try {
      // Check internet first
      await ConnectivityHelper.checkConnection();
      
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
        Navigator.pushReplacementNamed(context, AppRoutes.planSelection);
      }
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      
      if (errorMsg.contains('Connection timeout') || 
          errorMsg.contains('O servidor não está respondendo')) {
        errorMsg = '⏱️ O servidor está demorando para responder. Tente novamente em alguns instantes.\n\n'
                  '⏱️ The server is taking too long to respond. Please try again in a few moments.';
      }
      
      setState(() {
        _errorMessage = errorMsg;
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
