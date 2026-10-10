import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_drawer.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/error_view.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _categoryChip(
      BuildContext context,
      String label,
      bool selected,
      VoidCallback onTap,
      ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: scheme.primary,
        showCheckmark: false,
        labelStyle: TextStyle(color: selected ? scheme.onPrimary : null),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _emptyState(BuildContext context, ProductProvider products) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 56, color: Theme.of(context).hintColor),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search or category.',
            textAlign: TextAlign.center,
          ),
          if (products.hasActiveFilters) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  products.clearFilters();
                },
                child: const Text('Clear filters'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, ProductProvider products) {
    final scheme = Theme.of(context).colorScheme;
    final hint = Theme.of(context).hintColor;
    final items = products.filtered;

    return Column(
      children: [
        // A refresh failed but older products are still on screen.
        if (products.status == LoadStatus.error)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: scheme.errorContainer,
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 18, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Couldn't refresh. Showing the last update.",
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: products.setQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  products.setQuery('');
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _categoryChip(
                context,
                'All',
                products.category == null,
                    () => products.setCategory(null),
              ),
              for (final c in products.categories)
                _categoryChip(
                  context,
                  prettyCategory(c),
                  products.category == c,
                      () => products.setCategory(c),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${items.length} ${items.length == 1 ? 'product' : 'products'}',
                  style: TextStyle(fontSize: 12, color: hint),
                ),
              ),
              PopupMenuButton<SortOption>(
                tooltip: 'Sort',
                initialValue: products.sort,
                onSelected: products.setSort,
                itemBuilder: (_) => [
                  for (final s in SortOption.values)
                    PopupMenuItem(value: s, child: Text(s.label)),
                ],
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        products.sort.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: products.load,
            child: items.isEmpty
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 60),
                _emptyState(context, products),
              ],
            )
                : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: items[index]),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body;
    if (!products.hasData) {
      // Nothing to show yet: either still loading, or the first load failed.
      body = products.status == LoadStatus.error
          ? ErrorView(message: products.error, onRetry: products.load)
          : const Center(child: CircularProgressIndicator());
    } else {
      body = _buildCatalog(context, products);
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context
                .read<SettingsProvider>()
                .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
          const CartIconButton(),
        ],
      ),
      body: body,
    );
  }
}