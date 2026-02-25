import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cellar_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/wine_card.dart';
import 'free_add_wine_screen.dart';
import 'free_preview_wine_screen.dart';
import 'free_confirm_wine_screen.dart';
import '../../translations/translations_extension.dart';

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
  String _searchQuery = '';
  String _sortBy = 'name-az';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load wines when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CellarProvider>(context, listen: false).loadWines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cellarProvider = Provider.of<CellarProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isPro = user?.plan == 'PRO';
    
    // Filter wines based on selected filters
    final filteredWines = cellarProvider.filterWines(
      country: _selectedCountry,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      appBar: CustomAppBar(
        title: 'My Wine Cellar',
        showBackButton: true,
        onBackPressed: () => widget.setView('chat'),
        showLanguageToggle: true,
      ),
      body: Column(
        children: [
          // Usage info for free plan
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
                    'Free Plan: ${cellarProvider.wineCount}/${CellarProvider.maxFreeBottles} bottles used',
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
                      child: const Text(
                        'Limit Reached',
                        style: TextStyle(
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
                    hintText: 'Search wine...',
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
                        itemLabels: (item) => item == 'all' ? 'All countries' : item,
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
                          if (item == 'name-az') return 'Name (A–Z)';
                          if (item == 'year-desc') return 'Year (Newest)';
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
                ? _buildEmptyState(context, cellarProvider.canAddMore)
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
                          // Navigate to wine details/edit
                          _showWineDetails(context, wine);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isPro && !cellarProvider.canAddMore) {
            _showLimitDialog(context);
            return;
          }
          
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
        backgroundColor: (!isPro && !cellarProvider.canAddMore)
            ? Colors.grey
            : const Color(0xFF4B2B5F),
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildEmptyState(BuildContext context, bool canAddMore) {
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
          const Text(
            'Your cellar is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canAddMore
                ? 'Start by adding your first wine bottle'
                : 'Free plan limit reached. Upgrade to Pro to add more.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (canAddMore)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreeAddWineScreen(
                      setView: widget.setView,
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
              child: const Text('Add First Wine'),
            ),
        ],
      ),
    );
  }

  void _showWineDetails(BuildContext context, wine) {
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
              _buildDetailRow('Grape', wine.grape),
              _buildDetailRow('Region', wine.region),
              _buildDetailRow('Bottles', wine.bottles.toString()),
              if (wine.notes.isNotEmpty) _buildDetailRow('Notes', wine.notes),
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
                      child: const Text('Close'),
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

  void _showLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit Reached'),
        content: const Text(
          'Free plan allows up to 6 bottles. Upgrade to Pro to add more wines to your cellar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to pro plan selection
              Navigator.pushNamed(context, '/pro-plan-flow');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B2B5F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade to Pro'),
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
