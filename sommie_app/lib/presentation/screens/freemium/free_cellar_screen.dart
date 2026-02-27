import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../widgets/wine_card.dart';
import '../../../routes/app_routes.dart';
import 'free_add_wine_screen.dart';
import 'free_preview_wine_screen.dart';
import 'free_confirm_wine_screen.dart';
import '../../widgets/language_mixin.dart';

class FreeCellarScreen extends StatefulWidget {
  final Function(String) setView;

  const FreeCellarScreen({
    super.key,
    required this.setView,
  });

  @override
  State<FreeCellarScreen> createState() => _FreeCellarScreenState();
}

class _FreeCellarScreenState extends State<FreeCellarScreen> with LanguageMixin {
  String _selectedCountry = 'all';
  String _searchQuery = '';
  String _sortBy = 'name-az';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWines();
  }

  Future<void> _loadWines() async {
    setState(() => _isLoading = true);
    await Provider.of<CellarProvider>(context, listen: false).loadWines();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cellarProvider = Provider.of<CellarProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.currentUser;
    final isPro = user?.plan == 'PRO';
    final isPT = languageProvider.currentLanguage == 'pt';
    
    final filteredWines = cellarProvider.filterWines(
      country: _selectedCountry,
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
        title: Text(
          isPT ? 'Minha Adega' : 'My Wine Cellar',
          style: const TextStyle(
            color: Color(0xFF4B2B5F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Language is handled by global provider
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isPro) ...[
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPT
                              ? 'Plano Gratuito: ${cellarProvider.wineCount}/${CellarProvider.maxFreeBottles} garrafas usadas'
                              : 'Free Plan: ${cellarProvider.wineCount}/${CellarProvider.maxFreeBottles} bottles used',
                          style: const TextStyle(
                            color: Color(0xFF4B2B5F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!cellarProvider.canAddMore)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPT ? 'Limite Atingido' : 'Limit Reached',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

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
                          hintText: isPT ? 'Buscar vinho...' : 'Search wine...',
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
                      
                      // Country and Sort filters
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _selectedCountry,
                              items: [
                                'all',
                                ...cellarProvider.getUniqueCountries(),
                              ],
                              itemLabels: (item) => item == 'all' 
                                  ? (isPT ? 'Todos os países' : 'All countries')
                                  : item,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCountry = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _sortBy,
                              items: const ['name-az', 'year-desc'],
                              itemLabels: (item) {
                                if (item == 'name-az') {
                                  return isPT ? 'Nome (A–Z)' : 'Name (A–Z)';
                                }
                                if (item == 'year-desc') {
                                  return isPT ? 'Ano (Mais novo)' : 'Year (Newest)';
                                }
                                return item;
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
                    ],
                  ),
                ),

                // Wine Grid
                Expanded(
                  child: filteredWines.isEmpty
                      ? _buildEmptyState(context, cellarProvider.canAddMore, isPT)
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
                            return WineCard(
                              wine: wine,
                              onTap: () {
                                _showWineDetails(context, wine, isPT);
                              },
                            );
                          },
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemLabels(item)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool canAddMore, bool isPT) {
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
            isPT ? 'Sua adega está vazia' : 'Your cellar is empty',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canAddMore
                ? (isPT 
                    ? 'Comece adicionando sua primeira garrafa de vinho'
                    : 'Start by adding your first wine bottle')
                : (isPT
                    ? 'Limite do plano gratuito atingido. Faça upgrade para o PRO para adicionar mais.'
                    : 'Free plan limit reached. Upgrade to PRO to add more.'),
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
              child: Text(isPT ? 'Adicionar Primeiro Vinho' : 'Add First Wine'),
            ),
        ],
      ),
    );
  }

  void _showWineDetails(BuildContext context, wine, bool isPT) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: wine.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              wine.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.wine_bar, size: 40);
                              },
                            ),
                          )
                        : const Icon(Icons.wine_bar, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wine.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wine.year} • ${wine.country}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(isPT ? 'Uva' : 'Grape', wine.grape),
              _buildDetailRow(isPT ? 'Região' : 'Region', wine.region),
              _buildDetailRow(isPT ? 'Garrafas' : 'Bottles', wine.bottles.toString()),
              if (wine.notes.isNotEmpty) 
                _buildDetailRow(isPT ? 'Observações' : 'Notes', wine.notes),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B2B5F),
                        side: const BorderSide(color: Color(0xFF4B2B5F)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(isPT ? 'Fechar' : 'Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog(BuildContext context, bool isPT) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPT ? 'Limite Atingido' : 'Limit Reached'),
        content: Text(isPT
            ? 'O plano gratuito permite até 6 garrafas. Faça upgrade para o PRO para adicionar mais vinhos à sua adega.'
            : 'Free plan allows up to 6 bottles. Upgrade to PRO to add more wines to your cellar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isPT ? 'Cancelar' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
