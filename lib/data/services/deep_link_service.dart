import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_links/app_links.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/api_endpoints.dart';

class DeepLinkService {
  static bool _isInitialized = false;
  static AppLinks? _appLinks;
  
  static Future<void> init(BuildContext context) async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Web platform check
    if (kIsWeb) {
      print("🌐 Web platform detected - Deep links not supported");
      return;
    }
    
    print("📱 Initializing deep link service with app_links");
    
    try {
      // Initialize AppLinks instance
      _appLinks = AppLinks();
      
      // ✅ Get initial link (app opened from link)
      final Uri? initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        print("🔗 Initial deep link: $initialUri");
        _handleUri(context, initialUri);
      }
    } catch (e) {
      print('❌ Error getting initial URI: $e');
    }
    
    try {
      // ✅ Listen for incoming links while app is running
      _appLinks!.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          print("🔗 Deep link received: $uri");
          _handleUri(context, uri);
        }
      }).onError((error) {
        print("❌ Deep link stream error: $error");
      });
    } catch (e) {
      print("❌ Failed to listen for deep links: $e");
    }
  }
  
  static Future<void> _handleUri(BuildContext context, Uri uri) async {
    print("🔗 Processing deep link: $uri");
    
    // ✅ Support both custom scheme AND app links (https://)
    if (uri.scheme == 'sommie' || uri.scheme == 'https') {
      String host = uri.host;
      
      // Handle app links (yourdomain.com)
      if (uri.scheme == 'https') {
        // Extract path from https://yourdomain.com/payment-success
        String path = uri.path.substring(1); // Remove leading slash
        
        switch (path) {
          case 'payment-success':
            await _handlePaymentSuccess(context, uri);
            break;
          case 'payment-cancel':
            _handlePaymentCancel(context);
            break;
          default:
            print("Unknown app link path: $path");
        }
      } 
      // Handle custom scheme (sommie://)
      else if (uri.scheme == 'sommie') {
        switch (uri.host) {
          case 'payment-success':
            await _handlePaymentSuccess(context, uri);
            break;
          case 'payment-cancel':
            _handlePaymentCancel(context);
            break;
          default:
            print("Unknown deep link host: ${uri.host}");
        }
      }
    } else {
      print("Unknown link scheme: ${uri.scheme}");
    }
  }
  
  static Future<void> _handlePaymentSuccess(BuildContext context, Uri uri) async {
    print("✅ Payment success deep link received");
    
    // Extract session ID from URI (works for both schemes)
    final sessionId = uri.queryParameters['session_id'];
    
    if (!context.mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
        ),
      ),
    );
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      if (sessionId != null) {
        // ✅ Validate session and force upgrade
        final response = await Dio().post(
          '${ApiEndpoints.websiteBackend}/api/payments/validate-mobile-session',
          data: {'sessionId': sessionId},
        );
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          print("✅ Session validated - user upgraded to PRO");
        }
      }
      
      // Poll for PRO status (up to 6 attempts = 12 seconds)
      bool isPro = false;
      int attempts = 0;
      const maxAttempts = 6;
      
      while (attempts < maxAttempts && !isPro) {
        attempts++;
        print("🔄 Checking PRO status - Attempt $attempts/$maxAttempts");
        
        await Future.delayed(const Duration(seconds: 2));
        await authProvider.refreshUser();
        
        final user = authProvider.currentUser;
        print("📦 User plan: ${user?.plan}");
        
        if (user?.plan == 'PRO' || user?.plan == 'pro') {
          isPro = true;
          break;
        }
      }
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        
        if (isPro) {
          print("🎉 User is now PRO! Navigating to Pro Dashboard...");
          Navigator.pushReplacementNamed(context, '/pro-dashboard');
        } else {
          print("⚠️ User still not PRO");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment confirmed. Please log in again to see your PRO status.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          // Force logout to refresh data on next login
          await authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (error) {
      print("❌ Error handling payment success: $error");
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying payment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  static void _handlePaymentCancel(BuildContext context) {
    print("❌ Payment cancelled");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment was cancelled. You can try again anytime.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  /// Optional: Manual link handling for testing
  static Future<bool> handleLink(String link) async {
    try {
      final uri = Uri.parse(link);
      // This would need a valid BuildContext - call from widget
      print("Manually handling link: $link");
      return true;
    } catch (e) {
      print("Error parsing link: $e");
      return false;
    }
  }
}