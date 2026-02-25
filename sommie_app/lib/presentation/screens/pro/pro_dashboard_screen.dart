import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class ProDashboardScreen extends StatelessWidget {
  const ProDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'PRO Dashboard',
        showBackButton: true,
      ),
      body: const Center(
        child: Text(
          'PRO Dashboard - Coming Soon',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}