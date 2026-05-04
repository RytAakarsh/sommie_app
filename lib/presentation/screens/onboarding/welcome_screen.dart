import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../data/providers/language_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Slides content matching web exactly
  Map<String, List<Map<String, String>>> getSlides(String language) {
    final isPT = language == 'pt';
    return {
      'slides': [
        {
          'title': isPT 
              ? 'Sua jornada no mundo do vinho começa aqui.'
              : 'Your journey into the world of wine starts here.',
          'desc': isPT
              ? 'Aprenda sobre uvas, estilos e regiões com a ajuda da nossa IA especialista.'
              : 'Learn about grapes, styles, and regions with our expert AI assistant.',
        },
        {
          'title': isPT
              ? 'Descubra combinações perfeitas.'
              : 'Discover perfect pairings.',
          'desc': isPT
              ? 'Receba recomendações inteligentes de harmonização para qualquer ocasião.'
              : 'Get smart wine pairing recommendations for any occasion.',
        },
        {
          'title': isPT
              ? 'Sua adega digital pessoal.'
              : 'Your personal digital cellar.',
          'desc': isPT
              ? 'Organize seus vinhos, avalie e compartilhe com amigos.'
              : 'Organize your wines, rate them, and share with friends.',
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isPT = languageProvider.currentLanguage == 'pt';
    final slides = getSlides(languageProvider.currentLanguage)['slides']!;
    final flow = Provider.of<AuthFlowProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: _currentIndex == index ? 32 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF6a3a76)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image/Logo
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wine_bar,
                            size: 80,
                            color: Color(0xFF4B2B5F),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          slide['title']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B2B5F),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          slide['desc']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6a3a76),
                          side: const BorderSide(color: Color(0xFF6a3a76), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 18),
                            const SizedBox(width: 8),
                            Text(isPT ? "Voltar" : "Back"),
                          ],
                        ),
                      ),
                    ),
                  
                  if (_currentIndex > 0) const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Last slide - go to login
                          flow.setStep(AuthStep.login);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6a3a76),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex < slides.length - 1
                                ? (isPT ? "Próximo" : "Next")
                                : (isPT ? "Começar" : "Get Started"),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}