import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_flow_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../translations/translations_extension.dart';

class AITermsScreen extends StatefulWidget {
  const AITermsScreen({super.key});

  @override
  State<AITermsScreen> createState() => _AITermsScreenState();
}

class _AITermsScreenState extends State<AITermsScreen> {
  bool _isAccepting = false;

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final flow = Provider.of<AuthFlowProvider>(context);
    
    final translations = isPT ? {
      'title': 'Uso de Inteligência Artificial',
      'description': 'Para oferecer o melhor serviço, suas mensagens de texto e áudio são processadas por tecnologias de Inteligência Artificial de parceiros (como Anthropic e AWS). Ao continuar, você concorda com o envio desses dados para fins de interação no chat e melhoria da experiência.',
      'privacyNote': 'Seus dados são tratados com segurança e de acordo com nossa Política de Privacidade.',
      'partners': 'Parceiros de IA',
      'acceptAndContinue': 'Aceitar e Continuar',
      'rejectAndExit': 'Recusar e Sair',
      'processing': 'Processando...',
    } : {
      'title': 'Artificial Intelligence Usage',
      'description': 'To provide the best service, your text and audio messages are processed by Artificial Intelligence technologies from partners (such as Anthropic and AWS). By continuing, you agree to the submission of this data for chat interaction and experience improvement purposes.',
      'privacyNote': 'Your data is handled securely and in accordance with our Privacy Policy.',
      'partners': 'AI Partners',
      'acceptAndContinue': 'Accept and Continue',
      'rejectAndExit': 'Reject and Exit',
      'processing': 'Processing...',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2B5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            flow.setStep(AuthStep.plans);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Shield Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 40,
                  color: Color(0xFF4B2B5F),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              translations['description']!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Privacy Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0CFF5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF4B2B5F),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      translations['privacyNote']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B2B5F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Partners
            Text(
              translations['partners']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B2B5F),
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Anthropic',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AWS',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isAccepting ? null : () {
                      flow.setStep(AuthStep.plans);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(translations['rejectAndExit']!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isAccepting ? null : () async {
                      setState(() {
                        _isAccepting = true;
                      });
                      
                      // Store AI terms acceptance
                      // TODO: Save to storage
                      // await StorageHelper.setAITermsAccepted(true);
                      
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      if (mounted) {
                        if (flow.selectedPlan == 'pro') {
                          flow.setStep(AuthStep.proFlow);
                        } else {
                          flow.setStep(AuthStep.freemium);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B2B5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAccepting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(translations['processing']!),
                            ],
                          )
                        : Text(translations['acceptAndContinue']!),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}