import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../data/providers/auth_flow_provider.dart';
import '../../../../data/providers/language_provider.dart';

class ForgotPasswordResetScreen extends StatefulWidget {
  const ForgotPasswordResetScreen({super.key});

  @override
  State<ForgotPasswordResetScreen> createState() => _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState extends State<ForgotPasswordResetScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final flow = Provider.of<AuthFlowProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2B5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            flow.setStep(AuthStep.forgotOtp);
          },
        ),
        title: Text(
          isPT ? "Nova Senha" : "New Password",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: Color(0xFF4B2B5F),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                isPT ? "Criar Nova Senha" : "Create New Password",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                isPT 
                    ? "Digite sua nova senha abaixo"
                    : "Enter your new password below",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
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
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: isPT ? "Nova Senha" : "New Password",
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
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: isPT ? "Confirmar Nova Senha" : "Confirm New Password",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPT ? "Requisitos da senha:" : "Password requirements:",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B2B5F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementText(
                      _passwordController.text.length >= 8,
                      isPT ? "Pelo menos 8 caracteres" : "At least 8 characters",
                    ),
                    _buildRequirementText(
                      RegExp(r'[A-Z]').hasMatch(_passwordController.text),
                      isPT ? "Uma letra maiúscula" : "One uppercase letter",
                    ),
                    _buildRequirementText(
                      RegExp(r'[0-9]').hasMatch(_passwordController.text),
                      isPT ? "Um número" : "One number",
                    ),
                    _buildRequirementText(
                      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text),
                      isPT ? "Um caractere especial" : "One special character",
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                        isPT ? "Salvar Senha" : "Save Password",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementText(bool isValid, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isValid ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    final isPT = Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'pt';
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _error = isPT ? "As senhas não coincidem" : "Passwords do not match";
      });
      return;
    }

    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      setState(() {
        _error = isPT ? "A senha não atende aos requisitos" : "Password does not meet requirements";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final flow = Provider.of<AuthFlowProvider>(context, listen: false);
      final language = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
      
      final response = await Dio().post(
        ApiEndpoints.resetPassword,
        data: {
          'email': flow.forgotPasswordEmail,
          'newPassword': password,
          'language': language,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPT ? "Senha redefinida com sucesso!" : "Password reset successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          flow.setStep(AuthStep.login);
        }
      } else {
        setState(() {
          _error = response.data['message'] ?? (isPT ? "Falha ao redefinir senha" : "Failed to reset password");
        });
      }
    } catch (e) {
      setState(() {
        _error = isPT ? "Erro de rede. Tente novamente." : "Network error. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
