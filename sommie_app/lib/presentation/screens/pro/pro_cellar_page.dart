import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/pro_view_provider.dart';
import '../../../data/providers/language_provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/models/wine_model.dart';
import '../../widgets/wine_card.dart';

class ProCellarPage extends StatefulWidget {
  const ProCellarPage({super.key});

  @override
  State<ProCellarPage> createState() => _ProCellarPageState();
}

class _ProCellarPageState extends State<ProCellarPage> {
  String _selectedCountry = 'all';
  String _searchQuery = '';
  String _sortBy = 'name-az';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWines();
  }

  Future<void> _loadWines() async {
    await Provider.of<CellarProvider>(context, listen: false).loadWines();
  }

  @override
  Widget build(BuildContext context) {
    final cellarProvider = Provider.of<CellarProvider>(context);
    final viewProvider = Provider.of<ProViewProvider>(context, listen: false);
    final isPT = Provider.of<LanguageProvider>(context).currentLanguage == 'pt';

    final filteredWines = cellarProvider.filterWines(
      country: _selectedCountry,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF4B2B5F)),
                  onPressed: () => viewProvider.setView(ProView.dashboard),
                ),
                title: Text(
                  isPT ? 'Minha Adega' : 'My Cellar',
                  style: const TextStyle(
                    color: Color(0xFF4B2B5F),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(90),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Wine count
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isPT
                                ? '${filteredWines.length} vinhos no total'
                                : '${filteredWines.length} total wines',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Filter bar
                        Row(
                          children: [
                            Expanded(
                              child: _buildSearchField(isPT),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterDropdown(
                                value: _selectedCountry,
                                items: ['all', ...cellarProvider.getUniqueCountries()],
                                itemLabels: (item) {
                                  if (item == 'all') return isPT ? 'Todos os países' : 'All countries';
                                  return item;
                                },
                                onChanged: (value) => setState(() => _selectedCountry = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Sort dropdown
                        _buildSortDropdown(isPT),
                      ],
                    ),
                  ),
                ),
              ),

              // Wine grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final wine = filteredWines[index];
                      return WineCard(
                        wine: wine,
                        onTap: () => _showWineDetails(context, wine, isPT),
                      );
                    },
                    childCount: filteredWines.length,
                  ),
                ),
              ),

              // Empty state
              if (filteredWines.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wine_bar,
                            size: 50,
                            color: Color(0xFF4B2B5F),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isPT ? 'Sua adega está vazia' : 'Your cellar is empty',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPT
                              ? 'Comece adicionando seu primeiro vinho'
                              : 'Start by adding your first wine',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => viewProvider.setView(ProView.cellarAdd),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B2B5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(isPT ? 'Adicionar Primeiro Vinho' : 'Add First Wine'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Add button positioned above bottom nav
          Positioned(
            bottom: 70,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => viewProvider.setView(ProView.cellarAdd),
              backgroundColor: const Color(0xFF4B2B5F),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isPT) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: isPT ? 'Buscar vinho...' : 'Search wine...',
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
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

  Widget _buildSortDropdown(bool isPT) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        items: [
          DropdownMenuItem(
            value: 'name-az',
            child: Text(isPT ? 'Nome (A–Z)' : 'Name (A–Z)'),
          ),
          DropdownMenuItem(
            value: 'year-desc',
            child: Text(isPT ? 'Ano (Mais novo)' : 'Year (Newest)'),
          ),
        ],
        onChanged: (value) => setState(() => _sortBy = value!),
      ),
    );
  }

  void _showWineDetails(BuildContext context, WineModel wine, bool isPT) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: wine.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            wine.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.wine_bar, size: 35);
                            },
                          ),
                        )
                      : const Icon(Icons.wine_bar, size: 35),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wine.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${wine.year} • ${wine.country}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(isPT ? 'Uva' : 'Grape', wine.grape),
            _buildDetailRow(isPT ? 'Região' : 'Region', wine.region),
            _buildDetailRow(isPT ? 'Garrafas' : 'Bottles', wine.bottles.toString()),
            if (wine.notes.isNotEmpty)
              _buildDetailRow(isPT ? 'Observações' : 'Notes', wine.notes),
            const SizedBox(height: 16),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(isPT ? 'Fechar' : 'Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
