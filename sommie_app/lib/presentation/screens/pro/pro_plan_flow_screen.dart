import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class ProPlanFlowScreen extends StatelessWidget {
  const ProPlanFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pro Plan',
        showBackButton: true,
      ),
      body: const Center(
        child: Text(
          'Pro Plan Flow - Coming Soon',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}