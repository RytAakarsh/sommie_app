import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../data/providers/language_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "pt"; // Default to Portuguese

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<AuthFlowProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/pro-logo.png',
                  width: 220,
                  height: 220,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Sommie',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2B5F),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Language Selector Dropdown
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLanguage = selectedLanguage == "pt" ? "en" : "pt";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            selectedLanguage == "pt" ? "🇧🇷" : "🇺🇸",
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedLanguage == "pt" ? "Português" : "English",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Enter Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6a3a76),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Save selected language
                  languageProvider.setLanguage(selectedLanguage);
                  // Move to welcome screen
                  flow.setStep(AuthStep.welcome);
                },
                child: Text(
                  selectedLanguage == "pt" ? "Entrar" : "Enter",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "© 2026 Sommie. All rights reserved.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
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