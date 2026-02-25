import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/models/wine_model.dart';
import '../../../core/utils/storage_helper.dart';
import '../../translations/translations_extension.dart';

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

  @override
  void initState() {
    super.initState();
    _loadWineData();
  }

  Future<void> _loadWineData() async {
    final result = await StorageHelper.getWineResult();
    final upload = await StorageHelper.getWineUpload();

    if (result != null && upload != null) {
      final parsed = result['register_result']?['parsed'] ?? {};
      
      setState(() {
        _wine = WineModel(
          id: result['register_result']?['wine_id'] ?? 
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: parsed['wine_name'] ?? '',
          grape: parsed['grape'] ?? '',
          year: parsed['year'] ?? '',
          country: parsed['country'] ?? '',
          region: parsed['region'] ?? '',
          bottles: 1,
          notes: '',
          image: upload['preview'] ?? '',
        );
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
      await cellarProvider.addWine(_wine!);
      
      if (mounted) {
        widget.setView('cellar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving wine: $e'),
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
    if (_wine == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: CustomAppBar(
        title: 'Confirm Wine Details',
        showBackButton: true,
        onBackPressed: () => widget.setView('cellar-preview'),
        showLanguageToggle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Wine Image
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
                      child: _wine!.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                base64Decode(
                                  _wine!.image.split(',').last,
                                ),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.wine_bar,
                              size: 80,
                              color: Color(0xFF4B2B5F),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Review and edit the scanned information',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Editable fields
                  _buildEditableField(
                    label: 'Wine Name',
                    value: _wine!.name,
                    onChanged: (value) {
                      setState(() {
                        _wine = _wine!.copyWith(name: value);
                      });
                    },
                  ),
                  
                  _buildEditableField(
                    label: 'Grape Variety',
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
                          label: 'Year',
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
                          label: 'Country',
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
                    label: 'Region',
                    value: _wine!.region,
                    onChanged: (value) {
                      setState(() {
                        _wine = _wine!.copyWith(region: value);
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bottles counter
                  const Text(
                    'Number of Bottles',
                    style: TextStyle(
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
                        _wine!.bottles == 1 ? 'bottle' : 'bottles',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  const Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any notes about this wine...',
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
                  
                  const SizedBox(height: 32),
                  
                  // Add to Cellar button
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
                      child: const Text(
                        'Add to Cellar',
                        style: TextStyle(
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
