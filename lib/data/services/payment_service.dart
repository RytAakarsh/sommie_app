import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../providers/auth_provider.dart';

class PaymentService {
  static Dio _dio = Dio();
  
  /// Step 1: Create checkout session and open browser
  static Future<bool> initiateProUpgrade(BuildContext context) async {
    try {
      // ✅ Get auth provider and verify user is logged in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final token = authProvider.token;
      
      print("🔍 DEBUG - Current User: $currentUser");
      print("🔍 DEBUG - Token: $token");
      
      // ✅ Validate user is authenticated
      if (currentUser == null || token == null) {
        print("❌ ERROR: User not authenticated!");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in again to upgrade to PRO'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
          ),
        ),
      );
      
      print("🔄 Creating checkout session for user: ${currentUser.userId}");
      
      // ✅ Call app backend to create checkout session
      final response = await _dio.post(
        ApiEndpoints.createCheckoutSession,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      Navigator.pop(context); // Close loading
      
      print("✅ Checkout session response: ${response.statusCode}");
      print("📦 Response data: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final authToken = data['auth_token'];
        
        if (authToken == null || authToken.isEmpty) {
          throw Exception('No auth token received from backend');
        }
        
        // ✅ Open website with auto-login
        final url = Uri.parse('https://pro.sommie.io/auto-login?auth_token=$authToken');
        
        print("🌐 Opening URL: $url");
        
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
          return true;
        } else {
          throw Exception('Could not launch URL');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create checkout session');
      }
    } catch (e) {
      print("❌ PaymentService error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate upgrade: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
  
  /// Step 2: Verify PRO status after returning from payment
  static Future<bool> verifyProStatus(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (token == null) return false;
      
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
            ),
          ),
        );
      }
      
      // Retry up to 6 times (12 seconds) for webhook to process
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(seconds: 2));
        
        print("🔄 Verifying PRO status - Attempt ${i + 1}/6");
        
        final response = await _dio.get(
          ApiEndpoints.getProfile,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        
        if (response.statusCode == 200) {
          final userData = response.data;
          final plan = userData['plan'];
          print("📦 Current plan: $plan");
          
          if (plan == 'PRO' || plan == 'pro') {
            // ✅ Update local user data
            await authProvider.refreshUser();
            
            if (context.mounted) {
              Navigator.pop(context); // Close loading
            }
            return true;
          }
        }
      }
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
      }
      return false;
    } catch (e) {
      print("❌ Error verifying PRO status: $e");
      if (context.mounted) {
        Navigator.pop(context); // Close loading
      }
      return false;
    }
  }
}