import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../core/utils/storage_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final upload = await StorageHelper.getWineUpload();
      if (upload != null && upload['preview'] != null) {
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

  Future<void> _uploadAndAnalyze() async {
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

      final base64Image = upload['base64'] as String;
      final fileName = upload['fileName'] as String;
      
      // Convert base64 to bytes for upload
      final fileBytes = base64Decode(base64Image);
      final contentType = upload['contentType'] as String? ?? 'image/jpeg';

      print('📸 Uploading and analyzing wine...');
      print('User ID: ${user.userId}');
      print('File name: $fileName');

      final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
      
      final result = await cellarProvider.uploadAndAnalyzeWine(
        filename: fileName,
        fileBytes: fileBytes,
        contentType: contentType,
      );

      print('📊 Upload result: success=${result.success}');
      
      if (result.success) {
        // Save analysis result
        await StorageHelper.saveWineResult({
          'wine': result.wineData,
          'message': result.message,
          'wine_id': result.wineId,
          'file_key': result.fileKey,
        });
        
        if (mounted) {
          widget.setView('cellar-confirm');
        }
      } else {
        throw Exception(result.error ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ Upload failed: $e');
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

  void _handleManualEntry() {
    final manualResult = {
      'handler': 'manual_entry',
      'wine_id': 'manual-${DateTime.now().millisecondsSinceEpoch}',
      'wine': {
        'wine_name': '',
        'grape': '',
        'year': '',
        'country': '',
        'region': '',
        'wine_type': '',
      }
    };
    StorageHelper.saveWineResult(manualResult);
    widget.setView('cellar-confirm');
  }

  Uint8List _getImageBytes() {
    try {
      if (_previewImage!.startsWith('data:image')) {
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
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => widget.setView('cellar-add'),
        ),
        title: Text(
          isPT ? 'Pré-visualizar Rótulo' : 'Preview Wine Label',
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
                  Text(
                    'Uploading and analyzing wine label...',
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
                  
                  Text(
                    isPT 
                        ? 'Certifique-se de que o rótulo está claro antes de escanear'
                        : 'Make sure the label is clear before scanning',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _handleManualEntry,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4B2B5F),
                                side: const BorderSide(color: Color(0xFF4B2B5F)),
                              ),
                              child: Text(isPT ? 'Inserir Manualmente' : 'Enter Manually'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  if (_previewImage != null && _errorMessage == null) ...[
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
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _uploadAndAnalyze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7f488b),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isPT ? 'Analisar Rótulo' : 'Analyze Label',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
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
                        child: Text(
                          isPT ? 'Tirar Nova Foto' : 'Retake Photo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
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
                  ] else if (_errorMessage == null) ...[
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
                ],
              ),
            ),
    );
  }
}