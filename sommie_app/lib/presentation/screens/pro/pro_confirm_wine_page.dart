import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/models/wine_model.dart';
import '../../../core/utils/storage_helper.dart';

class ProConfirmWinePage extends StatefulWidget {
  const ProConfirmWinePage({super.key});

  @override
  State<ProConfirmWinePage> createState() => _ProConfirmWinePageState();
}

class _ProConfirmWinePageState extends State<ProConfirmWinePage> {
  WineModel? _wine;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _loadWineData();
  }

  Future<void> _loadWineData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await StorageHelper.getWineResult();
      final upload = await StorageHelper.getWineUpload();

      if (result == null || upload == null) return;

      if (result.containsKey('duplicate') && result['duplicate'] == true) {
        setState(() {
          _isDuplicate = true;
          _wine = WineModel(
            id: result['wine_id']?.toString() ?? '',
            name: 'Duplicate Wine',
            grape: '',
            year: '',
            country: '',
            region: '',
            bottles: 1,
            notes: '',
            image: upload['preview'] ?? '',
          );
        });
        return;
      }

      final registerResult = result['register_result'] as Map<String, dynamic>? ?? {};
      final parsed = registerResult['parsed'] as Map<String, dynamic>? ?? {};

      setState(() {
        _wine = WineModel(
          id: registerResult['wine_id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: parsed['wine_name']?.toString() ?? '',
          grape: parsed['grape']?.toString() ?? '',
          year: parsed['year']?.toString() ?? '',
          country: parsed['country']?.toString() ?? '',
          region: parsed['region']?.toString() ?? '',
          bottles: 1,
          notes: '',
          image: upload['preview'] ?? '',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToCellar() async {
    if (_wine == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
      
      if (_isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This wine already exists in your cellar'),
            backgroundColor: Colors.orange,
          ),
        );
        Provider.of<ProViewProvider>(context, listen: false)
            .setView(ProView.cellar);
        return;
      }

      await cellarProvider.addWine(_wine!);

      if (mounted) {
       await StorageHelper.saveWineResult({});
        await StorageHelper.saveWineUpload({});
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wine added to cellar!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Provider.of<ProViewProvider>(context, listen: false)
            .setView(ProView.cellar);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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

    if (_isLoading || _wine == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
            onPressed: () => viewProvider.setView(ProView.cellarPreview),
          ),
          title: Text(
            isPT ? 'Confirmar Detalhes' : 'Confirm Details',
            style: const TextStyle(
              color: Color(0xFF4B2B5F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => viewProvider.setView(ProView.cellarPreview),
        ),
        title: Text(
          isPT ? 'Confirmar Detalhes do Vinho' : 'Confirm Wine Details',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),
            ],
            if (_isDuplicate) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPT
                      ? 'Este vinho já existe na sua adega'
                      : 'This wine already exists',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Center(
              child: _buildWineImage(),
            ),
            const SizedBox(height: 24),
            Text(
              isPT
                  ? 'Revise e edite as informações'
                  : 'Review and edit the information',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: isPT ? 'Nome do Vinho' : 'Wine Name',
              value: _wine!.name,
              onChanged: (value) => setState(() => _wine = _wine!.copyWith(name: value)),
            ),
            _buildEditableField(
              label: isPT ? 'Uva' : 'Grape',
              value: _wine!.grape,
              onChanged: (value) => setState(() => _wine = _wine!.copyWith(grape: value)),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildEditableField(
                    label: isPT ? 'Ano' : 'Year',
                    value: _wine!.year,
                    onChanged: (value) => setState(() => _wine = _wine!.copyWith(year: value)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEditableField(
                    label: isPT ? 'País' : 'Country',
                    value: _wine!.country,
                    onChanged: (value) => setState(() => _wine = _wine!.copyWith(country: value)),
                  ),
                ),
              ],
            ),
            _buildEditableField(
              label: isPT ? 'Região' : 'Region',
              value: _wine!.region,
              onChanged: (value) => setState(() => _wine = _wine!.copyWith(region: value)),
            ),
            const SizedBox(height: 24),
            if (!_isDuplicate)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveToCellar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2B5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isPT ? 'Adicionar à Adega' : 'Add to Cellar'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWineImage() {
    try {
      if (_wine!.image.startsWith('data:image')) {
        final base64String = _wine!.image.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          height: 200,
          fit: BoxFit.contain,
        );
      }
      return Image.network(
        _wine!.image,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: const Color(0xFFF3E8FF),
            child: const Icon(Icons.wine_bar, size: 80, color: Color(0xFF4B2B5F)),
          );
        },
      );
    } catch (e) {
      return Container(
        height: 200,
        color: const Color(0xFFF3E8FF),
        child: const Icon(Icons.wine_bar, size: 80, color: Color(0xFF4B2B5F)),
      );
    }
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
