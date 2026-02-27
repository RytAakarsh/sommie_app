import 'package:flutter/material.dart';
import '../../../data/services/wine_service.dart';
import '../../../core/utils/storage_helper.dart';
import 'dart:convert';
import 'dart:typed_data';
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
  String? _errorMessage;
  final WineService _wineService = WineService();

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final upload = await StorageHelper.getWineUpload();
      if (upload != null) {
        setState(() {
          _previewImage = upload['preview'];
        });
      } else {
        setState(() {
          _errorMessage = 'No image found. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading image: $e';
      });
    }
  }

  Future<void> _confirmScan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final upload = await StorageHelper.getWineUpload();
      final user = await StorageHelper.getUser();
      
      if (upload == null) {
        throw Exception('Upload data not found');
      }
      
      if (user == null) {
        throw Exception('User not found. Please login again.');
      }

      print('Calling uploadWineLabel with:');
      print('userId: ${user.userId}');
      print('fileName: ${upload['fileName']}');
      print('planType: free');

      final result = await _wineService.uploadWineLabel(
        userId: user.userId,
        planType: 'free',
        fileName: upload['fileName'],
        fileBase64: upload['base64'],
      );

      print('Upload result: $result');

      // Save the result
      await StorageHelper.saveWineResult(result);

      if (mounted) {
        widget.setView('cellar-confirm');
      }
    } catch (e) {
      print('Scan failed error: $e');
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => widget.setView('cellar-add'),
        ),
        title: const Text(
          'Preview Wine Label',
          style: TextStyle(
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
                  Text(
                    'Scanning wine label...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
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
                  
                  // Error message if any
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
                    const SizedBox(height: 24),
                  ],
                  
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
                          _getImageBytes(),
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Text('Failed to load image'),
                              ),
                            );
                          },
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
                      onPressed: _previewImage != null ? _confirmScan : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7f488b),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
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

  Uint8List _getImageBytes() {
    try {
      if (_previewImage!.startsWith('data:image')) {
        // Remove the data URL prefix
        final base64String = _previewImage!.split(',').last;
        return base64Decode(base64String);
      } else {
        return base64Decode(_previewImage!);
      }
    } catch (e) {
      print('Error decoding image: $e');
      return Uint8List(0);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}