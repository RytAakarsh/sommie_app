import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/providers/language_provider.dart';

class FreeAddWineScreen extends StatefulWidget {
  final Function(String) setView;

  const FreeAddWineScreen({
    super.key,
    required this.setView,
  });

  @override
  State<FreeAddWineScreen> createState() => _FreeAddWineScreenState();
}

class _FreeAddWineScreenState extends State<FreeAddWineScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;

  /// Universal image compression - works on Web, iOS, Android
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final original = img.decodeImage(bytes);
      
      if (original == null) return bytes;
      
      // Resize to optimal size for wine label analysis
      final resized = img.copyResize(
        original,
        width: 800, // Optimal for wine label recognition
      );
      
      // Compress JPEG with 70% quality
      final compressed = img.encodeJpg(resized, quality: 70);
      
      print('📸 Compressed: ${bytes.length ~/ 1024}KB → ${compressed.length ~/ 1024}KB');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      print('Compression error: $e, using original');
      return bytes;
    }
  }

  /// Process image bytes - cross-platform compatible
  Future<void> _processBytes(Uint8List bytes, String fileName) async {
    try {
      // Compress the image
      final compressedBytes = await _compressImage(bytes);
      
      // Check size limit (5MB)
      if (compressedBytes.length > 5 * 1024 * 1024) {
        setState(() {
          _errorMessage = 'Image too large. Please choose a smaller image.';
          _isLoading = false;
        });
        return;
      }
      
      final base64Image = base64Encode(compressedBytes);
      final preview = 'data:image/jpeg;base64,$base64Image';
      
      // Determine content type
      String contentType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      }
      
      final imageData = {
        'fileName': fileName,
        'base64': base64Image,
        'preview': preview,
        'size': compressedBytes.length / 1024,
        'contentType': contentType,
      };
      
      print('✅ Image ready: $fileName, ${compressedBytes.length ~/ 1024}KB');
      
      await StorageHelper.saveWineUpload(imageData);
      
      if (mounted) {
        widget.setView('cellar-preview');
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      setState(() {
        _errorMessage = 'Error processing image. Please try again.';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cross-platform image picker (works on Web + Mobile)
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _errorMessage = 'No image selected';
          _isLoading = false;
        });
        return;
      }

      Uint8List bytes;
      
      if (kIsWeb) {
        // ✅ Web: read directly from XFile
        bytes = await image.readAsBytes();
      } else {
        // ✅ Mobile: read from file
        bytes = await image.readAsBytes();
      }
      
      await _processBytes(bytes, image.name);
      
    } catch (e) {
      print('❌ Error picking image: $e');
      setState(() {
        _errorMessage = 'Error picking image: ${e.toString()}';
        _isLoading = false;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    
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
                  const SizedBox(height: 8),
                  Text(
                    isPT ? 'Isso pode levar alguns segundos' : 'This may take a few seconds',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
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
                  
                  const SizedBox(height: 32),
                  
                  _buildOptionButton(
                    icon: Icons.camera_alt,
                    label: isPT ? 'Tirar Foto com Câmera' : 'Take Photo with Camera',
                    onPressed: () => _pickImage(ImageSource.camera),
                    isSecondary: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildOptionButton(
                    icon: Icons.photo_library,
                    label: isPT ? 'Carregar da Galeria' : 'Upload from Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                    isSecondary: true,
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
                                ? 'Dica: Certifique-se de que o rótulo do vinho esteja claro e bem iluminado para melhores resultados.'
                                : 'Tip: Make sure the wine label is clear and well-lit for best results.',
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