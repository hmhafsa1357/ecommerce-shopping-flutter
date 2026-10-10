import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _pageController = PageController();
  int _page = 0;
  int _quantity = 1;

  Product get product => widget.product;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addToCart() {
    context.read<CartProvider>().add(product, quantity: _quantity);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _quantity == 1 ? 'Added to cart' : 'Added $_quantity to cart',
          ),
          action: SnackBarAction(
            label: 'View cart',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ),
      );
  }

  Widget _carousel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = product.images.length;

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => ProductImage(url: product.images[i]),
          ),
          if (count > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? scheme.primary
                            : scheme.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hint = Theme.of(context).hintColor;
    final inCart = context.watch<CartProvider>().quantityOf(product.id);
    final inStock = product.stock > 0;

    final stockText = !inStock
        ? 'Out of stock'
        : (product.stock <= 5 ? 'Only ${product.stock} left' : 'In stock');
    final stockColor = !inStock || product.stock <= 5 ? scheme.error : hint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: const [CartIconButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            children: [
              _carousel(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prettyCategory(product.category),
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        if (product.brand.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              product.brand,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: hint),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFFBA7517),
                        ),
                        const SizedBox(width: 4),
                        Text(product.rating.toStringAsFixed(1)),
                        const SizedBox(width: 12),
                        Text(
                          stockText,
                          style: TextStyle(fontSize: 13, color: stockColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatPrice(product.price),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    if (inCart > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Already in your cart: $inCart',
                        style: TextStyle(fontSize: 12, color: hint),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(product.description, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              QuantityStepper(
                quantity: _quantity,
                onDecrement:
                _quantity > 1 ? () => setState(() => _quantity--) : null,
                onIncrement: _quantity < CartProvider.maxPerItem
                    ? () => setState(() => _quantity++)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: inStock ? _addToCart : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    inStock
                        ? 'Add  ·  ${formatPrice(product.price * _quantity)}'
                        : 'Out of stock',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}