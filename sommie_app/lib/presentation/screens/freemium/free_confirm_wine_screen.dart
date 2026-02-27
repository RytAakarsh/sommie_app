import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/models/wine_model.dart';
import '../../../core/utils/storage_helper.dart';
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
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _loadWineData();
  }

  // Helper method to get language without causing rebuilds
  bool _isPortuguese(BuildContext context) {
    return Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'pt';
  }

  Future<void> _loadWineData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isDuplicate = false;
    });

    try {
      final result = await StorageHelper.getWineResult();
      final upload = await StorageHelper.getWineUpload();

      if (result == null) {
        throw Exception(_isPortuguese(context) 
            ? 'Nenhum resultado encontrado. Tente novamente.'
            : 'No scan result found. Please try again.');
      }

      if (upload == null) {
        throw Exception(_isPortuguese(context) 
            ? 'Nenhuma imagem encontrada. Tente novamente.'
            : 'No image found. Please try again.');
      }

      // Check if it's a duplicate
      if (result.containsKey('duplicate') && result['duplicate'] == true) {
        setState(() {
          _isDuplicate = true;
          _wine = WineModel(
            id: result['wine_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: _isPortuguese(context) ? 'Vinho já existe' : 'Wine already exists',
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

      // Safely extract data from result
      final registerResult = result['register_result'] as Map<String, dynamic>? ?? {};
      final parsed = registerResult['parsed'] as Map<String, dynamic>? ?? {};
      
      // Get wine_id safely
      String wineId = '';
      if (registerResult.containsKey('wine_id')) {
        wineId = registerResult['wine_id'].toString();
      } else {
        wineId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      setState(() {
        _wine = WineModel(
          id: wineId,
          name: _safeString(parsed['wine_name']),
          grape: _safeString(parsed['grape']),
          year: _safeString(parsed['year']),
          country: _safeString(parsed['country']),
          region: _safeString(parsed['region']),
          bottles: _safeInt(parsed['bottles'], 1),
          notes: '',
          image: upload['preview'] ?? '',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading wine data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int _safeInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  Future<void> _saveToCellar() async {
    if (_wine == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use listen: false to avoid the Provider error
      final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
      
      // If it's a duplicate, just show a message and go back
      if (_isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isPortuguese(context) 
                  ? 'Este vinho já está na sua adega'
                  : 'This wine is already in your cellar'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        widget.setView('cellar');
        return;
      }
      
      await cellarProvider.addWine(_wine!);
      
      if (mounted) {
        // Clear temporary storage
        await StorageHelper.saveWineResult({});
        await StorageHelper.saveWineUpload({});
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isPortuguese(context) 
                ? 'Vinho adicionado à adega!'
                : 'Wine added to cellar!'),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.setView('cellar');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      
      // Check for plan limit exceeded
      if (errorMsg.contains('PLAN_LIMIT_EXCEEDED')) {
        errorMsg = _isPortuguese(context)
            ? 'Limite do plano gratuito atingido (6 garrafas). Faça upgrade para o PRO!'
            : 'Free plan limit reached (6 bottles). Upgrade to PRO!';
        
        // Show upgrade dialog
        _showUpgradeDialog();
      }
      
      if (mounted) {
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUpgradeDialog() {
    final isPT = _isPortuguese(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isPT ? 'Limite Atingido' : 'Limit Reached',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isPT
              ? 'Você atingiu o máximo de 6 garrafas no plano gratuito. Faça upgrade para o PRO para adicionar mais vinhos!'
              : 'You have reached the maximum of 6 bottles in the free plan. Upgrade to PRO to add more wines!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isPT ? 'Depois' : 'Later'),
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
            child: Text(isPT ? 'Upgrade para PRO' : 'Upgrade to PRO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPT = _isPortuguese(context);
    
    if (_isLoading && _wine == null) {
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
            isPT ? 'Confirmar Detalhes do Vinho' : 'Confirm Wine Details',
            style: const TextStyle(
              color: Color(0xFF4B2B5F),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B5F)),
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
          isPT ? 'Confirmar Detalhes do Vinho' : 'Confirm Wine Details',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Error message
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
                  
                  // Duplicate warning
                  if (_isDuplicate) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700),
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
                    const SizedBox(height: 16),
                  ],
                  
                  // Wine Image
                  if (_wine != null && _wine!.image.isNotEmpty && !_isDuplicate)
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
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
                          child: _buildWineImage(),
                        ),
                      ),
                    ),
                  
                  if (!_isDuplicate) ...[
                    const SizedBox(height: 24),
                    
                    Text(
                      isPT 
                          ? 'Revise e edite as informações escaneadas'
                          : 'Review and edit the scanned information',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Editable fields
                    if (_wine != null) ...[
                      _buildEditableField(
                        label: isPT ? 'Nome do Vinho' : 'Wine Name',
                        value: _wine!.name,
                        onChanged: (value) {
                          setState(() {
                            _wine = _wine!.copyWith(name: value);
                          });
                        },
                      ),
                      
                      _buildEditableField(
                        label: isPT ? 'Variedade da Uva' : 'Grape Variety',
                        value: _wine!.grape,
                        onChanged: (value) {
                          setState(() {
                            _wine = _wine!.copyWith(grape: value);
                          });
                        },
                      ),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableField(
                              label: isPT ? 'Ano' : 'Year',
                              value: _wine!.year,
                              onChanged: (value) {
                                setState(() {
                                  _wine = _wine!.copyWith(year: value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEditableField(
                              label: isPT ? 'País' : 'Country',
                              value: _wine!.country,
                              onChanged: (value) {
                                setState(() {
                                  _wine = _wine!.copyWith(country: value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      _buildEditableField(
                        label: isPT ? 'Região' : 'Region',
                        value: _wine!.region,
                        onChanged: (value) {
                          setState(() {
                            _wine = _wine!.copyWith(region: value);
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bottles counter
                      Text(
                        isPT ? 'Número de Garrafas' : 'Number of Bottles',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (_wine!.bottles > 1) {
                                setState(() {
                                  _wine = _wine!.copyWith(
                                    bottles: _wine!.bottles - 1,
                                  );
                                });
                              }
                            },
                          ),
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
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
                                _wine = _wine!.copyWith(
                                  bottles: _wine!.bottles + 1,
                                );
                              });
                            },
                          ),
                          const Spacer(),
                          Text(
                            _wine!.bottles == 1 
                                ? (isPT ? 'garrafa' : 'bottle') 
                                : (isPT ? 'garrafas' : 'bottles'),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notes
                      Text(
                        isPT ? 'Observações (Opcional)' : 'Notes (Optional)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: isPT 
                              ? 'Adicione observações sobre este vinho...'
                              : 'Add any notes about this wine...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _wine = _wine!.copyWith(notes: value);
                          });
                        },
                      ),
                    ],
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Add to Cellar button
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
                        child: Text(
                          isPT ? 'Adicionar à Adega' : 'Add to Cellar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
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
                        child: Text(
                          isPT ? 'Voltar para Adega' : 'Back to Cellar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF3E8FF),
              child: const Icon(
                Icons.wine_bar,
                size: 80,
                color: Color(0xFF4B2B5F),
              ),
            );
          },
        );
      } else {
        return Image.network(
          _wine!.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF3E8FF),
              child: const Icon(
                Icons.wine_bar,
                size: 80,
                color: Color(0xFF4B2B5F),
              ),
            );
          },
        );
      }
    } catch (e) {
      return Container(
        color: const Color(0xFFF3E8FF),
        child: const Icon(
          Icons.wine_bar,
          size: 80,
          color: Color(0xFF4B2B5F),
        ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}