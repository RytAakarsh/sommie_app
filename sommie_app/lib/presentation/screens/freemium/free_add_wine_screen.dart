import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_app_bar.dart';
import 'dart:convert';
import '../../../core/utils/storage_helper.dart';
import '../../translations/translations_extension.dart';

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

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        // Save to storage
        await StorageHelper.saveWineUpload({
          'fileName': image.name,
          'base64': base64Image,
          'preview': 'data:image/jpeg;base64,$base64Image',
        });

        if (mounted) {
          widget.setView('cellar-preview');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: CustomAppBar(
        title: 'Add Wine to Cellar',
        showBackButton: true,
        onBackPressed: () => widget.setView('cellar'),
        showLanguageToggle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Icon
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
                  
                  const Text(
                    'Add Wine to Cellar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B2B5F),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Take a photo of the wine label or upload from gallery',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Camera button
                  _buildOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo with Camera',
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Gallery button
                  _buildOptionButton(
                    icon: Icons.photo_library,
                    label: 'Upload from Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                    isSecondary: true,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: Make sure the wine label is clear and well-lit for best results',
                            style: TextStyle(fontSize: 14),
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
    bool isSecondary = false,
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


