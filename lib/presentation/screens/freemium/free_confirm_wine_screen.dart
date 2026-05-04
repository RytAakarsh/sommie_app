import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/wine_model.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/utils/translations.dart';
import '../../../routes/app_routes.dart';

class FreeConfirmWineScreen extends StatefulWidget {
  final Function(String) setView;

  const FreeConfirmWineScreen({
    super.key,
    required this.setView,
  });

  @override
  State<FreeConfirmWineScreen> createState() => _FreeConfirmWineScreenState();
}

class _FreeConfirmWineScreenState extends State<FreeConfirmWineScreen> {
  WineModel? _wine;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isDuplicate = false;
  bool _isManualMode = false;
  bool _isLoading = true;
  
  final _formKey = GlobalKey<FormState>();
  
  final List<Map<String, String>> _wineTypeOptions = [
    {'value': 'red', 'label_en': 'Red', 'label_pt': 'Tinto'},
    {'value': 'white', 'label_en': 'White', 'label_pt': 'Branco'},
    {'value': 'rose', 'label_en': 'Rosé', 'label_pt': 'Rosé'},
    {'value': 'sparkling', 'label_en': 'Sparkling', 'label_pt': 'Espumante'},
  ];

  @override
  void initState() {
    super.initState();
    _loadWineData();
  }

  Future<void> _loadWineData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await StorageHelper.getWineResult();
      final upload = await StorageHelper.getWineUpload();

      print('📦 Loading wine data...');

      if (result == null) {
        throw Exception('No scan result found');
      }

      final isManual = result['handler'] == 'manual_entry';
      
      // Check for duplicate
      if (result.containsKey('duplicate') && result['duplicate'] == true) {
        setState(() {
          _isDuplicate = true;
          _isLoading = false;
        });
        return;
      }

      // Extract wine data from result
      String wineName = '';
      String grape = '';
      String year = '';
      String country = '';
      String region = '';
      String wineType = '';
      String imageUrl = upload?['preview'] ?? '';

      if (isManual) {
        _isManualMode = true;
        print('📝 Manual entry mode');
      } else if (result.containsKey('wine')) {
        final wine = result['wine'];
        wineName = wine?['wine_name']?.toString() ?? '';
        grape = wine?['grape']?.toString() ?? '';
        year = wine?['year']?.toString() ?? '';
        country = wine?['country']?.toString() ?? '';
        region = wine?['region']?.toString() ?? '';
        wineType = wine?['wine_type']?.toString() ?? '';
        print('✅ Wine data extracted: $wineName');
      } else {
        // Try alternate path for wine data
        if (result.containsKey('data')) {
          final data = result['data'];
          if (data is Map) {
            final stateSummary = data['state_summary'];
            if (stateSummary != null && stateSummary is Map) {
              final pendingWine = stateSummary['pending_wine'];
              if (pendingWine != null && pendingWine is Map) {
                final fields = pendingWine['current_fields'];
                if (fields != null && fields is Map) {
                  wineName = fields['wine_name']?.toString() ?? '';
                  grape = fields['grape']?.toString() ?? '';
                  year = fields['year']?.toString() ?? fields['vintage_year']?.toString() ?? '';
                  country = fields['country']?.toString() ?? '';
                  region = fields['region']?.toString() ?? '';
                  wineType = fields['wine_type']?.toString() ?? '';
                  print('✅ Wine data extracted from state_summary: $wineName');
                }
              }
            }
          }
        }
      }

      final wineId = 'wine_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';

      setState(() {
        _wine = WineModel(
          id: wineId,
          name: wineName.isNotEmpty ? wineName : '',
          grape: grape,
          year: year,
          country: country,
          region: region,
          wineType: wineType,
          bottles: 1,
          notes: '',
          image: imageUrl,
          alcohol: null,
          volume: null,
        );
        _isLoading = false;
      });
      
      print('🎯 Wine model created: ${_wine?.name}');
    } catch (e) {
      print('❌ Error loading wine data: $e');
      setState(() {
        _errorMessage = 'Error loading wine data: $e';
        _isLoading = false;
      });
    }
  }

  /// ✅ DIRECT SAVE TO YOUR BACKEND - THIS IS THE CORRECT APPROACH
  Future<void> _saveToCellar() async {
    if (_wine == null) return;
    
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
        
        if (_isDuplicate) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTranslations.t(context, 'wine_already_exists')),
                backgroundColor: Colors.orange,
              ),
            );
          }
          widget.setView('cellar');
          return;
        }
        
        // ✅ SAVE TO YOUR BACKEND - THIS IS THE CRITICAL STEP
        print('💾 Saving wine to your backend: ${_wine!.name}');
        await cellarProvider.addWine(_wine!);
        
        // ✅ Clear temporary data
        await StorageHelper.clearWineTempData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.t(context, 'wine_added')),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // ✅ Refresh cellar and navigate back
          await cellarProvider.loadWines();
          widget.setView('cellar');
        }
      } catch (e) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        print('❌ Error saving wine: $errorMsg');
        
        if (errorMsg.contains('PLAN_LIMIT_EXCEEDED')) {
          errorMsg = AppTranslations.t(context, 'plan_limit_reached');
          _showUpgradeDialog();
        }
        
        setState(() {
          _errorMessage = errorMsg;
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppTranslations.t(context, 'plan_limit_reached'),
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(AppTranslations.t(context, 'plan_limit_reached')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTranslations.t(context, 'later')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, AppRoutes.proPlanFlow);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B2B5F),
              foregroundColor: Colors.white,
            ),
            child: Text(AppTranslations.t(context, 'upgrade_to_pro')),
          ),
        ],
      ),
    );
  }

  Uint8List _getImageBytes() {
    try {
      if (_wine!.image.startsWith('data:image')) {
        final base64String = _wine!.image.split(',').last;
        return base64Decode(base64String);
      }
      return base64Decode(_wine!.image);
    } catch (e) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
            onPressed: () => widget.setView('cellar-preview'),
          ),
          title: Text(
            AppTranslations.t(context, 'confirm_wine'),
            style: const TextStyle(
              color: Color(0xFF4B2B5F),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
              ),
              SizedBox(height: 16),
              Text('Loading wine details...'),
            ],
          ),
        ),
      );
    }
    
    if (_wine == null && !_isDuplicate) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF7FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
            onPressed: () => widget.setView('cellar-preview'),
          ),
          title: Text(
            AppTranslations.t(context, 'confirm_wine'),
            style: const TextStyle(
              color: Color(0xFF4B2B5F),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Failed to load wine data',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWineData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2B5F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => widget.setView('cellar-preview'),
        ),
        title: Text(
          AppTranslations.t(context, 'confirm_wine'),
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Indicator
                    LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
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
                      const SizedBox(height: 16),
                    ],
                    
                    if (_isDuplicate)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isPT
                                    ? 'Este vinho já existe na sua adega'
                                    : 'This wine already exists in your cellar',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (!_isDuplicate && _wine != null) ...[
                      // Main Content Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Wine Image
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: _wine!.image.isNotEmpty
                                        ? Image.memory(
                                            _getImageBytes(),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.wine_bar, size: 60, color: Color(0xFF4B2B5F));
                                            },
                                          )
                                        : const Icon(Icons.wine_bar, size: 60, color: Color(0xFF4B2B5F)),
                                  ),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isManualMode)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.blue.shade700),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              isPT
                                                  ? 'Por favor, insira os detalhes do vinho manualmente abaixo.'
                                                  : 'Please enter the wine details manually below.',
                                              style: TextStyle(color: Colors.blue.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  // Basic Info Section
                                  _buildSectionTitle(AppTranslations.t(context, 'basic_info')),
                                  const SizedBox(height: 12),
                                  _buildEditableField(
                                    label: AppTranslations.t(context, 'wine_name'),
                                    value: _wine!.name,
                                    onChanged: (value) => setState(() => _wine = _wine!.copyWith(name: value)),
                                    isRequired: true,
                                    hint: isPT ? 'Ex: Château Margaux' : 'E.g., Château Margaux',
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Origin Section
                                  _buildSectionTitle(AppTranslations.t(context, 'origin')),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildEditableField(
                                          label: AppTranslations.t(context, 'country'),
                                          value: _wine!.country,
                                          onChanged: (value) => setState(() => _wine = _wine!.copyWith(country: value)),
                                          hint: isPT ? 'País de origem' : 'Country of origin',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildEditableField(
                                          label: AppTranslations.t(context, 'region'),
                                          value: _wine!.region,
                                          onChanged: (value) => setState(() => _wine = _wine!.copyWith(region: value)),
                                          hint: isPT ? 'Região vinícola' : 'Wine region',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Wine Details Section
                                  _buildSectionTitle(AppTranslations.t(context, 'wine_details')),
                                  const SizedBox(height: 12),
                                  _buildWineTypeDropdown(),
                                  const SizedBox(height: 12),
                                  _buildEditableField(
                                    label: AppTranslations.t(context, 'grape_variety'),
                                    value: _wine!.grape,
                                    onChanged: (value) => setState(() => _wine = _wine!.copyWith(grape: value)),
                                    hint: isPT ? 'Ex: Cabernet Sauvignon' : 'E.g., Cabernet Sauvignon',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildEditableField(
                                    label: AppTranslations.t(context, 'year'),
                                    value: _wine!.year,
                                    onChanged: (value) => setState(() => _wine = _wine!.copyWith(year: value)),
                                    hint: isPT ? 'Ano da safra' : 'Vintage year',
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Inventory Section
                                  _buildSectionTitle(AppTranslations.t(context, 'inventory')),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5EEF8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppTranslations.t(context, 'number_of_bottles'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline),
                                              onPressed: () {
                                                if (_wine!.bottles > 1) {
                                                  setState(() {
                                                    _wine = _wine!.copyWith(bottles: _wine!.bottles - 1);
                                                  });
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Container(
                                              width: 50,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${_wine!.bottles}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline),
                                              onPressed: () {
                                                setState(() {
                                                  _wine = _wine!.copyWith(bottles: _wine!.bottles + 1);
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Notes
                                  Text(
                                    '${AppTranslations.t(context, 'notes')} (${AppTranslations.t(context, 'optional')})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    maxLines: 3,
                                    initialValue: _wine!.notes,
                                    decoration: InputDecoration(
                                      hintText: isPT 
                                          ? 'Adicione observações sobre este vinho...'
                                          : 'Add any notes about this wine...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF5EEF8),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _wine = _wine!.copyWith(notes: value);
                                      });
                                    },
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // ✅ Save Button - Directly saves to your backend
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
                                        elevation: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_to_photos,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            isPT ? 'Adicionar à Adega' : 'Add to Cellar',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Cancel button
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () => widget.setView('cellar-preview'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF4B2B5F),
                                        side: const BorderSide(color: Color(0xFF4B2B5F)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        isPT ? 'Voltar' : 'Back',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    if (_isDuplicate)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => widget.setView('cellar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B2B5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(AppTranslations.t(context, 'back')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4B2B5F),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onChanged,
    bool isRequired = false,
    String? hint,
  }) {
    final isPT = Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'pt';
    final isEmpty = value.isEmpty && isRequired;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isEmpty ? Colors.orange : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isEmpty 
                ? Colors.orange.shade50 
                : (value.isNotEmpty ? const Color(0xFFE8F5E9) : const Color(0xFFF5EEF8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
          validator: isRequired ? (val) {
            if (val == null || val.isEmpty) {
              return isPT ? 'Campo obrigatório' : 'Required field';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildWineTypeDropdown() {
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.t(context, 'wine_type'),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EEF8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _wine!.wineType.isNotEmpty ? _wine!.wineType : null,
              hint: Text(isPT ? 'Selecione o tipo...' : 'Select type...'),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              items: _wineTypeOptions.map((type) {
                return DropdownMenuItem(
                  value: type['value'],
                  child: Text(
                    isPT ? type['label_pt']! : type['label_en']!,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _wine = _wine!.copyWith(wineType: value ?? '');
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
