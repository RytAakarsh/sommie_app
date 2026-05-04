import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/models/wine_model.dart';
import '../../../core/utils/translations.dart';
import '../../../routes/app_routes.dart';
import 'free_add_wine_screen.dart';
import 'free_preview_wine_screen.dart';
import 'free_confirm_wine_screen.dart';

class FreeCellarScreen extends StatefulWidget {
  final Function(String) setView;

  const FreeCellarScreen({
    super.key,
    required this.setView,
  });

  @override
  State<FreeCellarScreen> createState() => _FreeCellarScreenState();
}

class _FreeCellarScreenState extends State<FreeCellarScreen> {
  String _selectedCountry = 'all';
  String _selectedWineType = 'all';
  String _searchQuery = '';
  String _sortBy = 'name-az';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _deletingWineId;
  WineModel? _editingWine;
  final _editFormKey = GlobalKey<FormState>();
  
  // Edit form controllers
  late TextEditingController _editNameController;
  late TextEditingController _editGrapeController;
  late TextEditingController _editYearController;
  late TextEditingController _editCountryController;
  late TextEditingController _editRegionController;
  late TextEditingController _editWineTypeController;
  late TextEditingController _editBottlesController;
  late TextEditingController _editNotesController;
  
  final List<Map<String, String>> _wineTypeOptions = [
    {'value': 'red', 'label_en': 'Red', 'label_pt': 'Tinto'},
    {'value': 'white', 'label_en': 'White', 'label_pt': 'Branco'},
    {'value': 'rose', 'label_en': 'Rosé', 'label_pt': 'Rosé'},
    {'value': 'sparkling', 'label_en': 'Sparkling', 'label_pt': 'Espumante'},
  ];

  @override
  void initState() {
    super.initState();
    _loadWines();
    _initializeEditControllers();
  }
  
  void _initializeEditControllers() {
    _editNameController = TextEditingController();
    _editGrapeController = TextEditingController();
    _editYearController = TextEditingController();
    _editCountryController = TextEditingController();
    _editRegionController = TextEditingController();
    _editWineTypeController = TextEditingController();
    _editBottlesController = TextEditingController();
    _editNotesController = TextEditingController();
  }

  Future<void> _loadWines() async {
    setState(() => _isLoading = true);
    await Provider.of<CellarProvider>(context, listen: false).loadWines();
    setState(() => _isLoading = false);
  }

  String _getWineTypeLabel(String type, bool isPT) {
    final option = _wineTypeOptions.firstWhere(
      (o) => o['value'] == type,
      orElse: () => {},
    );
    return isPT ? (option['label_pt'] ?? type) : (option['label_en'] ?? type);
  }

  void _showEditDialog(WineModel wine, bool isPT) {
    _editingWine = wine;
    _editNameController.text = wine.name;
    _editGrapeController.text = wine.grape;
    _editYearController.text = wine.year;
    _editCountryController.text = wine.country;
    _editRegionController.text = wine.region;
    _editWineTypeController.text = wine.wineType;
    _editBottlesController.text = wine.bottles.toString();
    _editNotesController.text = wine.notes;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.t(context, 'edit')),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wine Name (required)
                  _buildEditField(
                    controller: _editNameController,
                    label: AppTranslations.t(context, 'wine_name'),
                    isRequired: true,
                    isPT: isPT,
                  ),
                  const SizedBox(height: 12),
                  
                  // Grape Variety
                  _buildEditField(
                    controller: _editGrapeController,
                    label: AppTranslations.t(context, 'grape_variety'),
                    isPT: isPT,
                  ),
                  const SizedBox(height: 12),
                  
                  // Year
                  _buildEditField(
                    controller: _editYearController,
                    label: AppTranslations.t(context, 'year'),
                    isPT: isPT,
                  ),
                  const SizedBox(height: 12),
                  
                  // Wine Type
                  _buildEditWineTypeDropdown(isPT),
                  const SizedBox(height: 12),
                  
                  // Country
                  _buildEditField(
                    controller: _editCountryController,
                    label: AppTranslations.t(context, 'country'),
                    isPT: isPT,
                  ),
                  const SizedBox(height: 12),
                  
                  // Region
                  _buildEditField(
                    controller: _editRegionController,
                    label: AppTranslations.t(context, 'region'),
                    isPT: isPT,
                  ),
                  const SizedBox(height: 12),
                  
                  // Bottles
                  _buildEditField(
                    controller: _editBottlesController,
                    label: AppTranslations.t(context, 'bottles'),
                    isPT: isPT,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  
                  // Notes (optional)
                  _buildEditField(
                    controller: _editNotesController,
                    label: AppTranslations.t(context, 'notes'),
                    isPT: isPT,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => _saveEditedWine(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B2B5F),
              foregroundColor: Colors.white,
            ),
            child: Text(AppTranslations.t(context, 'save')),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required bool isPT,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFFF5EEF8),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return '$label ${isPT ? 'é obrigatório' : 'is required'}';
        }
        return null;
      } : null,
    );
  }

  Widget _buildEditWineTypeDropdown(bool isPT) {
    return DropdownButtonFormField<String>(
      value: _editWineTypeController.text.isNotEmpty ? _editWineTypeController.text : null,
      decoration: InputDecoration(
        labelText: AppTranslations.t(context, 'wine_type'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFFF5EEF8),
      ),
      items: _wineTypeOptions.map((type) {
        return DropdownMenuItem(
          value: type['value'],
          child: Text(isPT ? type['label_pt']! : type['label_en']!),
        );
      }).toList(),
      onChanged: (value) {
        _editWineTypeController.text = value ?? '';
      },
    );
  }

  Future<void> _saveEditedWine(BuildContext context) async {
    if (_editFormKey.currentState?.validate() ?? false) {
      final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
      
      final updatedWine = WineModel(
        id: _editingWine!.id,
        name: _editNameController.text,
        grape: _editGrapeController.text,
        year: _editYearController.text,
        country: _editCountryController.text,
        region: _editRegionController.text,
        wineType: _editWineTypeController.text,
        bottles: int.tryParse(_editBottlesController.text) ?? 1,
        notes: _editNotesController.text,
        image: _editingWine!.image,
        alcohol: null,
        volume: _editingWine!.volume,
      );
      
      final success = await cellarProvider.updateWine(updatedWine);
      
      if (mounted && success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.t(context, 'wine_updated')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(String wineId, String wineName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.t(context, 'delete')),
        content: Text(
          '${AppTranslations.t(context, 'delete')} "$wineName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _deletingWineId = wineId);
              Navigator.pop(context);
              
              final cellarProvider = Provider.of<CellarProvider>(context, listen: false);
              final success = await cellarProvider.deleteWine(wineId);
              
              setState(() => _deletingWineId = null);
              
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppTranslations.t(context, 'wine_deleted')),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppTranslations.t(context, 'delete')),
          ),
        ],
      ),
    );
  }

  Uint8List _getImageBytes(String imageData) {
    try {
      if (imageData.startsWith('data:image')) {
        final base64String = imageData.split(',').last;
        return base64Decode(base64String);
      }
      return base64Decode(imageData);
    } catch (e) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellarProvider = Provider.of<CellarProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';
    final user = authProvider.currentUser;
    final isPro = user?.plan == 'PRO';
    
    final filteredWines = cellarProvider.filterWines(
      country: _selectedCountry,
      wineType: _selectedWineType,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
          onPressed: () => widget.setView('chat'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.t(context, 'my_cellar'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              '${filteredWines.length} ${AppTranslations.t(context, 'wines_count')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (!isPro)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cellarProvider.wineCount}/${CellarProvider.maxFreeBottles}',
                  style: const TextStyle(
                    color: Color(0xFF4B2B5F),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Plan limit banner for free users
                if (!isPro && cellarProvider.wineCount >= CellarProvider.maxFreeBottles)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
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
                            AppTranslations.t(context, 'plan_limit_reached'),
                            style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.proPlanFlow),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF4B2B5F),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(AppTranslations.t(context, 'upgrade_to_pro')),
                        ),
                      ],
                    ),
                  ),

                // Filter Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppTranslations.t(context, 'search_wine'),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Filters row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: _buildFilterDropdown(
                                value: _selectedCountry,
                                items: ['all', ...cellarProvider.getUniqueCountries()],
                                itemLabels: (item) => item == 'all' 
                                    ? AppTranslations.t(context, 'all_countries')
                                    : item,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 140,
                              child: _buildFilterDropdown(
                                value: _selectedWineType,
                                items: ['all', ...cellarProvider.getUniqueWineTypes()],
                                itemLabels: (item) {
                                  if (item == 'all') return AppTranslations.t(context, 'all_types');
                                  return _getWineTypeLabel(item, isPT);
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWineType = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 140,
                              child: _buildFilterDropdown(
                                value: _sortBy,
                                items: const ['name-az', 'year-desc'],
                                itemLabels: (item) {
                                  if (item == 'name-az') return AppTranslations.t(context, 'name_az');
                                  return AppTranslations.t(context, 'year_newest');
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _sortBy = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Wine Grid or Empty State
                Expanded(
                  child: filteredWines.isEmpty
                      ? _buildEmptyState(context)
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredWines.length,
                          itemBuilder: (context, index) {
                            final wine = filteredWines[index];
                            return _buildWineCard(wine, isPT);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: cellarProvider.canAddMore || isPro
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreeAddWineScreen(
                      setView: (view) {
                        Navigator.pop(context);
                        if (view == 'cellar-preview') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FreePreviewWineScreen(
                                setView: (view) {
                                  Navigator.pop(context);
                                  if (view == 'cellar-confirm') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FreeConfirmWineScreen(
                                          setView: widget.setView,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF4B2B5F),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildWineCard(WineModel wine, bool isPT) {
    final hasImage = wine.image.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with 3-dot menu
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: hasImage
                      ? Image.memory(
                          _getImageBytes(wine.image),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF3E8FF),
                              child: const Icon(Icons.wine_bar, size: 40, color: Color(0xFF4B2B5F)),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFF3E8FF),
                          child: const Icon(Icons.wine_bar, size: 40, color: Color(0xFF4B2B5F)),
                        ),
                ),
                // 3-dot menu
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(wine, isPT);
                        } else if (value == 'delete') {
                          _showDeleteDialog(wine.id, wine.name);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(AppTranslations.t(context, 'edit')),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            AppTranslations.t(context, 'delete'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Delete loading overlay
                if (_deletingWineId == wine.id)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Wine Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${wine.year} • ${wine.country}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Wine type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getWineTypeLabel(wine.wineType, isPT).toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${wine.bottles} ${wine.bottles == 1 ? '🍾' : '🍾🍾'}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String Function(String) itemLabels,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              itemLabels(item),
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cellarProvider = Provider.of<CellarProvider>(context);
    final canAddMore = cellarProvider.canAddMore;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wine_bar,
              size: 60,
              color: Color(0xFF4B2B5F),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppTranslations.t(context, 'no_wines'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppTranslations.t(context, 'add_first_wine'),
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (canAddMore)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreeAddWineScreen(
                      setView: (view) {
                        Navigator.pop(context);
                        if (view == 'cellar-preview') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FreePreviewWineScreen(
                                setView: (view) {
                                  Navigator.pop(context);
                                  if (view == 'cellar-confirm') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FreeConfirmWineScreen(
                                          setView: widget.setView,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B2B5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppTranslations.t(context, 'add_wine')),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _editNameController.dispose();
    _editGrapeController.dispose();
    _editYearController.dispose();
    _editCountryController.dispose();
    _editRegionController.dispose();
    _editWineTypeController.dispose();
    _editBottlesController.dispose();
    _editNotesController.dispose();
    super.dispose();
  }
}