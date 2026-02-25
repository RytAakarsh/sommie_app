import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../data/services/wine_service.dart';
import '../../../core/utils/storage_helper.dart';
import 'dart:convert';
import '../../translations/translations_extension.dart';

class FreePreviewWineScreen extends StatefulWidget {
  final Function(String) setView;

  const FreePreviewWineScreen({
    super.key,
    required this.setView,
  });

  @override
  State<FreePreviewWineScreen> createState() => _FreePreviewWineScreenState();
}

class _FreePreviewWineScreenState extends State<FreePreviewWineScreen> {
  bool _isLoading = false;
  String? _previewImage;
  final WineService _wineService = WineService();

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    final upload = await StorageHelper.getWineUpload();
    if (upload != null) {
      setState(() {
        _previewImage = upload['preview'];
      });
    }
  }

  Future<void> _confirmScan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final upload = await StorageHelper.getWineUpload();
      final user = await StorageHelper.getUser();
      
      if (upload == null || user == null) {
        throw Exception('Missing data');
      }

      final result = await _wineService.uploadWineLabel(
        userId: user.userId,
        planType: 'free',
        fileName: upload['fileName'],
        fileBase64: upload['base64'],
      );

      await StorageHelper.saveWineResult(result);

      if (mounted) {
        widget.setView('cellar-confirm');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
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
        title: 'Preview Wine Label',
        showBackButton: true,
        onBackPressed: () => widget.setView('cellar-add'),
        showLanguageToggle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Make sure the label is clear before scanning',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preview Image
                  if (_previewImage != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          base64Decode(
                            _previewImage!.split(',').last,
                          ),
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No image selected'),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B2B5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm & Scan Label',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Retake button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => widget.setView('cellar-add'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B2B5F),
                        side: const BorderSide(color: Color(0xFF4B2B5F)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retake Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF4B2B5F)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Our AI will analyze the label and extract wine details automatically',
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
}

