import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// The shopping cart. Saved on the device so it survives app restarts.
class CartProvider extends ChangeNotifier {
  static const _key = 'cart';

  /// Most of one product a customer can add.
  static const maxPerItem = 10;

  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total => _items.fold(0.0, (sum, i) => sum + i.lineTotal);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _items = [];
    for (final entry in raw) {
      try {
        _items.add(CartItem.fromJson(jsonDecode(entry) as Map<String, dynamic>));
      } catch (_) {
        // Skip any corrupt entry instead of crashing.
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _items.map((i) => jsonEncode(i.toJson())).toList(),
    );
  }

  int _cap(int value) {
    if (value < 1) return 1;
    if (value > maxPerItem) return maxPerItem;
    return value;
  }

  int quantityOf(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index == -1 ? 0 : _items[index].quantity;
  }

  Future<void> add(Product product, {int quantity = 1}) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index == -1) {
      _items.add(CartItem(product: product, quantity: _cap(quantity)));
    } else {
      _items[index] = _items[index]
          .copyWith(quantity: _cap(_items[index].quantity + quantity));
    }
    await _persist();
  }

  Future<void> increment(int productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    _items[index] =
        _items[index].copyWith(quantity: _cap(_items[index].quantity + 1));
    await _persist();
  }

  /// Lowering the quantity below 1 removes the item.
  Future<void> decrement(int productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    if (_items[index].quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] =
          _items[index].copyWith(quantity: _items[index].quantity - 1);
    }
    await _persist();
  }

  Future<void> remove(int productId) async {
    _items.removeWhere((i) => i.product.id == productId);
    await _persist();
  }

  Future<void> clear() async {
    _items = [];
    await _persist();
  }
}