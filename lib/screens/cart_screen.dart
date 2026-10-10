import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  /// Simulated checkout: no payment, just a confirmation and an empty cart.
  Future<void> _checkout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final count = cart.totalItems;
    final total = cart.total;
    await cart.clear();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          size: 48,
          color: Theme.of(ctx).colorScheme.primary,
        ),
        title: const Text('Order placed'),
        content: Text(
          'Thank you! Your order of $count ${count == 1 ? 'item' : 'items'} '
              '(${formatPrice(total)}) has been placed.\n\n'
              'This is a demo app, so no payment was taken.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue shopping'),
          ),
        ],
      ),
    );

    if (context.mounted) Navigator.of(context).pop();
  }

  Widget _itemRow(BuildContext context, CartProvider cart, CartItem item) {
    final scheme = Theme.of(context).colorScheme;
    final hint = Theme.of(context).hintColor;
    final product = item.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: scheme.onError),
      ),
      onDismissed: (_) {
        cart.remove(product.id);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: const Text('Removed from cart'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => cart.add(product, quantity: item.quantity),
              ),
            ),
          );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: ProductImage(url: product.thumbnail),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatPrice(product.price)} each',
                      style: TextStyle(fontSize: 12, color: hint),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        QuantityStepper(
                          quantity: item.quantity,
                          decrementIcon: item.quantity == 1
                              ? Icons.delete_outline
                              : Icons.remove,
                          onDecrement: () => cart.decrement(product.id),
                          onIncrement: item.quantity < CartProvider.maxPerItem
                              ? () => cart.increment(product.id)
                              : null,
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(item.lineTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final hint = Theme.of(context).hintColor;
    final count = cart.totalItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(cart.isEmpty ? 'Your cart' : 'Your cart ($count)'),
      ),
      body: cart.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 56, color: hint),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add something from the shop and it will show up here.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continue shopping'),
                ),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _itemRow(context, cart, cart.items[index]),
          ),
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Total ($count ${count == 1 ? 'item' : 'items'})',
                    style: TextStyle(color: hint),
                  ),
                  const Spacer(),
                  Text(
                    formatPrice(cart.total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _checkout(context),
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}