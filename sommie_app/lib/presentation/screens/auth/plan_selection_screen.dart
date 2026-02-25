import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../translations/translations_extension.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  String? _selectedPlan;
  bool _isLoading = false;

  void _handleContinue() {
    if (_selectedPlan != null) {
      _handlePlanSelection(_selectedPlan!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4B2B5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/pro-logo.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => 
              const Text('Sommie', style: TextStyle(color: Color(0xFF4B2B5F))),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                context.tr('plan.title'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B5F),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                context.tr('app.subtitle'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Freemium Plan Card
            _buildPlanCard(
              title: context.tr('plan.freemium'),
              description: context.tr('plan.freemiumDesc'),
              price: '€0',
              period: context.tr('plan.perMonth') ?? '/month',
              features: [
                context.tr('plan.feature1'),
                context.tr('plan.feature3'),
                context.tr('plan.feature5'),
              ],
              isSelected: _selectedPlan == 'freemium',
              onTap: () {
                setState(() {
                  _selectedPlan = 'freemium';
                });
              },
              onSelect: () => _handlePlanSelection('freemium'),
              isPro: false,
            ),
            
            const SizedBox(height: 16),
            
            // PRO Plan Card
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedPlan == 'pro'
                          ? const Color(0xFF6D3FA6)
                          : const Color(0xFF4B2B5F).withOpacity(0.3),
                      width: _selectedPlan == 'pro' ? 2 : 1,
                    ),
                  ),
                  child: _buildPlanCard(
                    title: context.tr('plan.pro'),
                    description: context.tr('plan.proDesc'),
                    price: '€29.90',
                    period: context.tr('plan.perMonth') ?? '/month',
                    features: [
                      context.tr('plan.feature2'),
                      context.tr('plan.feature4'),
                      context.tr('plan.feature6'),
                      context.tr('plan.feature7'),
                      context.tr('plan.feature8'),
                    ],
                    isSelected: _selectedPlan == 'pro',
                    onTap: () {
                      setState(() {
                        _selectedPlan = 'pro';
                      });
                    },
                    onSelect: () => _handlePlanSelection('pro'),
                    isPro: true,
                  ),
                ),
                // Recommended badge
                Positioned(
                  top: -10,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6D3FA6), Color(0xFF4B2B5F)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.tr('plan.recommended'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            CustomButton(
              text: _isLoading 
                  ? context.tr('common.loading')
                  : context.tr('plan.selectPlan'),
              onPressed: _selectedPlan != null ? _handleContinue : null,
              isPrimary: true,
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: context.tr('common.cancel'),
              onPressed: () => Navigator.pop(context),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String description,
    required String price,
    required String period,
    required List<String> features,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onSelect,
    required bool isPro,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: isSelected
              ? Border.all(color: const Color(0xFF4B2B5F), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2B5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2B5F),
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Features
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isPro ? Icons.bolt : Icons.check_circle,
                    size: 18,
                    color: isPro
                        ? const Color(0xFF6D3FA6)
                        : const Color(0xFF4B2B5F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            
            // Select button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPro
                      ? const Color(0xFF6D3FA6)
                      : const Color(0xFF4B2B5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(context.tr('plan.selectPlan')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlanSelection(String plan) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (plan == 'pro') {
      // Navigate to pro dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.proDashboard);
    } else {
      // Navigate to freemium chat
      Navigator.pushReplacementNamed(context, AppRoutes.freemiumChat);
    }

    setState(() {
      _isLoading = false;
    });
  }
}