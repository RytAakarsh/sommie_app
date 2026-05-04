import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../data/providers/auth_flow_provider.dart';
import '../../../../data/providers/language_provider.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _error;
  int _countdown = 0;

  String get otpCode => _otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_countdown > 0) _countdown--;
        });
      }
      return _countdown > 0 && mounted;
    });
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      final flow = Provider.of<AuthFlowProvider>(context, listen: false);
      final language = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
      
      final response = await Dio().post(
        ApiEndpoints.forgotPassword,
        data: {
          'email': flow.forgotPasswordEmail,
          'language': language, // ✅ Add language parameter
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _startCountdown();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'pt' ? "Código reenviado!" : "Code resent!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Failed to resend code';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (otpCode.length != 6) {
      setState(() {
        _error = 'Please enter the 6-digit verification code';
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
      
      print('🔄 Verifying reset OTP at: ${ApiEndpoints.verifyResetOtp}');
      print('📝 Email: ${flow.forgotPasswordEmail}');
      print('📝 OTP: $otpCode');
      
      // ✅ FIXED: Use verifyResetOtp endpoint for password reset
      final response = await Dio().post(
        ApiEndpoints.verifyResetOtp, // ✅ CORRECT endpoint for password reset
        data: {
          'email': flow.forgotPasswordEmail,
          'otp': otpCode,
          'language': language,
        },
      );

      print('✅ Verify OTP response: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        
        if (data['success'] == true) {
          // OTP verified, move to reset password
          if (mounted) {
            flow.setStep(AuthStep.resetPassword);
          }
        } else {
          setState(() {
            _error = data['message'] ?? 'Invalid verification code';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Invalid verification code';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      print('❌ Verify OTP error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      String errorMessage = 'Invalid or expired verification code';
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        if (errorData != null && errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Backend endpoint not found';
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Verify OTP error: $e');
      setState(() {
        _error = 'Invalid or expired verification code';
        _isLoading = false;
      });
    }
  }

  void _handleOtpChange(int index, String value) {
    if (value.length > 1) return;
    if (!RegExp(r'^\d*$').hasMatch(value)) return;

    setState(() {
      _otpControllers[index].text = value;
    });

    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final flow = Provider.of<AuthFlowProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2B5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            flow.setStep(AuthStep.forgotEmail);
          },
        ),
        title: Text(
          isPT ? "Verificar Código" : "Verify Code",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: Color(0xFF4B2B5F),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                isPT ? "Verifique seu e-mail" : "Check your inbox",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                isPT 
                    ? "Enviamos um código de verificação de 6 dígitos para"
                    : "We've sent a 6-digit verification code to",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                flow.forgotPasswordEmail ?? '',
                style: const TextStyle(
                  color: Color(0xFF4B2B5F),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // ✅ FIXED: Wrap Row to prevent overflow
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4B2B5F), width: 2),
                          ),
                        ),
                        onChanged: (value) => _handleOtpChange(index, value),
                        onTap: () => _focusNodes[index].requestFocus(),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_error != null)
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
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2B5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        isPT ? "Verificar" : "Verify",
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: (_isResending || _countdown > 0) ? null : _resendCode,
                child: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4B2B5F),
                        ),
                      )
                    : Text(
                        _countdown > 0
                            ? (isPT ? "Reenviar código em $_countdown s" : "Resend code in $_countdown s")
                            : (isPT ? "Reenviar código" : "Resend code"),
                        style: TextStyle(
                          color: _countdown > 0 ? Colors.grey : const Color(0xFF4B2B5F),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
