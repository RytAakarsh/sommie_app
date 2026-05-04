import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/storage_helper.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _error;
  int _countdown = 0;
  bool _success = false;

  String get otpCode => _otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _sendOTP();
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

  Future<void> _sendOTP() async {
    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      final flow = Provider.of<AuthFlowProvider>(context, listen: false);
      
      print('🔄 Sending OTP to: ${ApiEndpoints.sendOtp}');
      
      final response = await Dio().post(
        ApiEndpoints.sendOtp,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'email': flow.email,
          'name': flow.userData?['name'] ?? 'User',
        },
      );

      print('✅ Send OTP response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _startCountdown();
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Failed to send verification code';
        });
      }
    } on DioException catch (e) {
      print('❌ Send OTP error: ${e.message}');
      setState(() {
        if (e.response?.statusCode == 404) {
          _error = 'Backend endpoint not found. Please check if the server is running.';
        } else if (e.response?.statusCode == 503) {
          _error = 'Backend is starting up. Please wait a moment and try again.';
        } else {
          _error = 'Network error. Please check your connection.';
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
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
      
      final response = await Dio().post(
        ApiEndpoints.verifyOtp,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'email': flow.email,
          'otp': otpCode,
        },
      );

      print('✅ Verify OTP response status: ${response.statusCode}');
      print('✅ Verify OTP response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;
        
        // ✅ FIXED: Only use fields that exist in the response
        final user = UserModel(
          userId: userMap['userId'] ?? '',
          name: userMap['name'] ?? '',
          email: userMap['email'] ?? '',
          plan: userMap['plan'] ?? 'FREE',
          age: userMap['age'],
          country: userMap['country'],
          gender: userMap['gender'],
          role: null,      // Not in response
          avatar: null,    // Not in response
          token: token,
          photo: null,     // Not in response
          phone: null,     // Not in response
          cpf: null,       // Not in response
          address: null,   // Not in response
          dob: null,       // Not in response
        );
        
        print('✅ User created: ${user.name} (${user.userId})');
        print('✅ Plan: ${user.plan}');
        
        // Store token and user data
        await StorageHelper.saveToken(token);
        await StorageHelper.saveUser(user);
        
        // Save basic profile (only with fields that exist)
        await StorageHelper.saveUserProfile(user.userId, {
          'name': user.name,
          'email': user.email,
          'age': user.age,
          'country': user.country,
          'gender': user.gender,
        });
        
        setState(() {
          _success = true;
        });
        
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          flow.setStep(AuthStep.plans);
        }
      } else {
        setState(() {
          _error = response.data['message'] ?? 'Verification failed';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      print('❌ Verify OTP error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      setState(() {
        if (e.response?.statusCode == 404) {
          _error = 'Backend endpoint not found. Please check if the server is running.';
        } else if (e.response?.statusCode == 503) {
          _error = 'Backend is starting up. Please wait a moment and try again.';
        } else if (e.response?.statusCode == 400) {
          _error = e.response?.data['message'] ?? 'Invalid or expired OTP. Please try again.';
        } else {
          _error = 'Network error. Please check your connection.';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Verify OTP error: $e');
      setState(() {
        _error = e.toString();
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
    
    final translations = isPT ? {
      'title': 'Verifique seu E-mail',
      'checkInbox': 'Verifique sua caixa de entrada',
      'sentMessage': 'Enviamos um código de verificação de 6 dígitos para',
      'verifyEmail': 'Verificar E-mail',
      'verifying': 'Verificando...',
      'resendCode': 'Reenviar código de verificação',
      'sending': 'Enviando...',
      'resendIn': 'Reenviar código em',
      'seconds': 's',
      'emailVerified': 'E-mail Verificado!',
      'verifiedMessage': 'Seu e-mail foi verificado com sucesso. Redirecionando...',
      'invalidCode': 'Por favor, digite o código de verificação de 6 dígitos',
    } : {
      'title': 'Verify Your Email',
      'checkInbox': 'Check your inbox',
      'sentMessage': "We've sent a 6-digit verification code to",
      'verifyEmail': 'Verify Email',
      'verifying': 'Verifying...',
      'resendCode': 'Resend verification code',
      'sending': 'Sending...',
      'resendIn': 'Resend code in',
      'seconds': 's',
      'emailVerified': 'Email Verified!',
      'verifiedMessage': 'Your email has been successfully verified. Redirecting...',
      'invalidCode': 'Please enter the 6-digit verification code',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2B5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            final flowProvider = Provider.of<AuthFlowProvider>(context, listen: false);
            flowProvider.setStep(AuthStep.signup);
          },
        ),
        title: Text(
          translations['title']!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            if (!_success) ...[
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
                translations['checkInbox']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                translations['sentMessage']!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              Text(
                flow.email,
                style: const TextStyle(
                  color: Color(0xFF4B2B5F),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              Row(
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
                onPressed: _isLoading ? null : _verifyOTP,
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
                        translations['verifyEmail']!,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: (_isResending || _countdown > 0) ? null : _sendOTP,
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
                            ? '${translations['resendIn']} $_countdown${translations['seconds']}'
                            : translations['resendCode']!,
                        style: TextStyle(
                          color: _countdown > 0 ? Colors.grey : const Color(0xFF4B2B5F),
                        ),
                      ),
              ),
            ] else ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                translations['emailVerified']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                translations['verifiedMessage']!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}