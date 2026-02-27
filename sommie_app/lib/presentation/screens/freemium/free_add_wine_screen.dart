import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/providers/language_provider.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/language_mixin.dart';

class FreeAddWineScreen extends StatefulWidget {
  final Function(String) setView;

  const FreeAddWineScreen({
    super.key,
    required this.setView,
  });

  @override
  State<FreeAddWineScreen> createState() => _FreeAddWineScreenState();
}

class _FreeAddWineScreenState extends State<FreeAddWineScreen> with LanguageMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;

  /// Check if free user has reached the 6 bottle limit
  Future<bool> _checkFreeLimit() async {
    try {
      final user = await StorageHelper.getUser();
      if (user == null) {
        _errorMessage = 'User not found. Please login again.';
        return false;
      }
      
      // PRO users have no limit
      if (user.plan == 'PRO') return true;
      
      final wines = await StorageHelper.getCellarWines(user.userId);
      if (wines.length >= 6) {
        _showUpgradeDialog();
        return false;
      }
      return true;
    } catch (e) {
      print('Error checking free limit: $e');
      _errorMessage = 'Error checking limit: $e';
      return false;
    }
  }

  /// Show upgrade dialog when limit reached
  void _showUpgradeDialog() {
    final isPT = isPortuguese(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isPT ? 'Limite do Plano Gratuito Atingido' : 'Free Plan Limit Reached',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isPT
              ? 'Você atingiu o máximo de 6 garrafas no plano gratuito. '
                'Faça upgrade para o PRO para adicionar garrafas ilimitadas à sua adega e ter acesso a:\n\n'
                '• Armazenamento ilimitado de vinhos\n'
                '• Análise avançada por IA\n'
                '• Harmonizações premium\n'
                '• Suporte prioritário'
              : 'You have reached the maximum of 6 bottles in the free plan. '
                'Upgrade to PRO to add unlimited wines to your cellar and get access to:\n\n'
                '• Unlimited wine storage\n'
                '• Advanced AI analysis\n'
                '• Premium pairings\n'
                '• Priority support',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isPT ? 'Depois' : 'Later',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.proPlanFlow);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B2B5F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isPT ? 'Upgrade para PRO' : 'Upgrade to PRO'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Check free plan limit first
    final canAdd = await _checkFreeLimit();
    if (!canAdd) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        // Read bytes
        final bytes = await image.readAsBytes();
        
        // Decode image
        img.Image? originalImage = img.decodeImage(bytes);
        if (originalImage != null) {
          // Compress image further
          final compressedBytes = img.encodeJpg(originalImage, quality: 60);
          
          // Convert to base64
          final base64Image = base64Encode(compressedBytes);
          
          // Check size
          final sizeInKB = compressedBytes.length / 1024;
          print('Compressed image size: ${sizeInKB.toStringAsFixed(2)} KB');
          
          Map<String, dynamic> uploadData;
          
          if (sizeInKB > 500) {
            // If still too large, compress more
            final moreCompressed = img.encodeJpg(originalImage, quality: 40);
            final smallerBase64 = base64Encode(moreCompressed);
            final smallerSize = moreCompressed.length / 1024;
            print('Further compressed size: ${smallerSize.toStringAsFixed(2)} KB');
            
            uploadData = {
              'fileName': image.name,
              'base64': smallerBase64,
              'preview': 'data:image/jpeg;base64,$smallerBase64',
              'size': smallerSize,
            };
          } else {
            uploadData = {
              'fileName': image.name,
              'base64': base64Image,
              'preview': 'data:image/jpeg;base64,$base64Image',
              'size': sizeInKB,
            };
          }
          
          // Save to storage
          await StorageHelper.saveWineUpload(uploadData);
          
          if (mounted) {
            // Navigate to preview screen
            widget.setView('cellar-preview');
          }
        } else {
          // Fallback to original compression
          final sizeInKB = bytes.length / 1024;
          print('Original image size: ${sizeInKB.toStringAsFixed(2)} KB');
          
          if (sizeInKB > 500) {
            setState(() {
              _errorMessage = isPortuguese(context) 
                  ? 'Imagem muito grande. Escolha uma imagem menor.'
                  : 'Image too large. Please choose a smaller image.';
              _isLoading = false;
            });
            return;
          }
          
          final base64Image = base64Encode(bytes);
          
          await StorageHelper.saveWineUpload({
            'fileName': image.name,
            'base64': base64Image,
            'preview': 'data:image/jpeg;base64,$base64Image',
            'size': sizeInKB,
          });
          
          if (mounted) {
            widget.setView('cellar-preview');
          }
        }
      } else {
        setState(() {
          _errorMessage = isPortuguese(context) 
              ? 'Nenhuma imagem selecionada'
              : 'No image selected';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPT = isPortuguese(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => widget.setView('cellar'),
        ),
        title: Text(
          isPT ? 'Adicionar Vinho à Adega' : 'Add Wine to Cellar',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPT ? 'Processando imagem...' : 'Processing image...',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 60,
                      color: Color(0xFF4B2B5F),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    isPT ? 'Adicionar Vinho à Adega' : 'Add Wine to Cellar',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B2B5F),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    isPT
                        ? 'Tire uma foto do rótulo do vinho ou carregue da galeria'
                        : 'Take a photo of the wine label or upload from gallery',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  _buildOptionButton(
                    icon: Icons.camera_alt,
                    label: isPT ? 'Tirar Foto com Câmera' : 'Take Photo with Camera',
                    onPressed: () => _pickImage(ImageSource.camera),
                    isSecondary: false,
                    isPT: isPT,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildOptionButton(
                    icon: Icons.photo_library,
                    label: isPT ? 'Carregar da Galeria' : 'Upload from Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                    isSecondary: true,
                    isPT: isPT,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isPT
                                ? 'Dica: Certifique-se de que o rótulo do vinho esteja claro e bem iluminado para melhores resultados'
                                : 'Tip: Make sure the wine label is clear and well-lit for best results',
                            style: const TextStyle(fontSize: 14),
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

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isSecondary,
    required bool isPT,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? Colors.white
              : const Color(0xFF4B2B5F),
          foregroundColor: isSecondary
              ? const Color(0xFF4B2B5F)
              : Colors.white,
          elevation: isSecondary ? 0 : 2,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
