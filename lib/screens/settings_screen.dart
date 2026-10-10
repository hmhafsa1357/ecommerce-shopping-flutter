import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty your cart?'),
        content: const Text('All items in your cart will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Empty cart'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CartProvider>().clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart emptied')),
        );
      }
    }
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionLabel(context, 'Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            value: isDark,
            onChanged: (value) => settings
                .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
          _sectionLabel(context, 'Data'),
          ListTile(
            leading: Icon(Icons.remove_shopping_cart_outlined,
                color: scheme.error),
            title: Text('Empty cart', style: TextStyle(color: scheme.error)),
            onTap: () => _confirmClearCart(context),
          ),
          _sectionLabel(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Product data'),
            subtitle: Text('Provided by DummyJSON (dummyjson.com)'),
          ),
        ],
      ),
    );
  }
}