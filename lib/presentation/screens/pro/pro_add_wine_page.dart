import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../core/utils/storage_helper.dart';

class ProAddWinePage extends StatefulWidget {
  const ProAddWinePage({super.key});

  @override
  State<ProAddWinePage> createState() => _ProAddWinePageState();
}

class _ProAddWinePageState extends State<ProAddWinePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        
        // Decode and compress image
        img.Image? originalImage = img.decodeImage(bytes);
        if (originalImage != null) {
          final compressedBytes = img.encodeJpg(originalImage, quality: 70);
          final base64Image = base64Encode(compressedBytes);
          
          await StorageHelper.saveWineUpload({
            'fileName': image.name,
            'base64': base64Image,
            'preview': 'data:image/jpeg;base64,$base64Image',
          });
        } else {
          final base64Image = base64Encode(bytes);
          await StorageHelper.saveWineUpload({
            'fileName': image.name,
            'base64': base64Image,
            'preview': 'data:image/jpeg;base64,$base64Image',
          });
        }

        if (mounted) {
          Provider.of<ProViewProvider>(context, listen: false)
              .setView(ProView.cellarPreview);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
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
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => viewProvider.setView(ProView.cellar),
        ),
        title: Text(
          isPT ? 'Adicionar Vinho' : 'Add Wine',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
                  ),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
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
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2B5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt),
                          const SizedBox(width: 12),
                          Text(
                            isPT ? 'Tirar Foto' : 'Take Photo',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B2B5F),
                        side: const BorderSide(color: Color(0xFF4B2B5F)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_library),
                          const SizedBox(width: 12),
                          Text(
                            isPT ? 'Carregar da Galeria' : 'Upload from Gallery',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
