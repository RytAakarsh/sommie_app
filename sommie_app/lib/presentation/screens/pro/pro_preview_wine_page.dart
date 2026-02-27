import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/services/wine_service.dart';
import '../../../core/utils/storage_helper.dart';

class ProPreviewWinePage extends StatefulWidget {
  const ProPreviewWinePage({super.key});

  @override
  State<ProPreviewWinePage> createState() => _ProPreviewWinePageState();
}

class _ProPreviewWinePageState extends State<ProPreviewWinePage> {
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
      _errorMessage = null;
    });

    try {
      final upload = await StorageHelper.getWineUpload();
      final user = await StorageHelper.getUser();
      
      if (upload == null || user == null) {
        throw Exception('Missing data');
      }

      final result = await _wineService.uploadWineLabel(
        userId: user.userId,
        planType: 'pro',
        fileName: upload['fileName'],
        fileBase64: upload['base64'],
      );

      await StorageHelper.saveWineResult(result);

      if (mounted) {
        Provider.of<ProViewProvider>(context, listen: false)
            .setView(ProView.cellarConfirm);
      }
    } catch (e) {
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
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => viewProvider.setView(ProView.cellarAdd),
        ),
        title: Text(
          isPT ? 'Pré-visualizar Rótulo' : 'Preview Label',
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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning...'),
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
                        ? 'Certifique-se de que o rótulo está claro'
                        : 'Make sure the label is clear',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
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
                    const SizedBox(height: 16),
                  ],
                  if (_previewImage != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
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
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
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
                      child: Text(
                        isPT ? 'Confirmar e Escanear' : 'Confirm & Scan',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => viewProvider.setView(ProView.cellarAdd),
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
                        style: const TextStyle(fontSize: 16),
                      ),
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
        final base64String = _previewImage!.split(',').last;
        return base64Decode(base64String);
      }
      return base64Decode(_previewImage!);
    } catch (e) {
      return Uint8List(0);
    }
  }
}
