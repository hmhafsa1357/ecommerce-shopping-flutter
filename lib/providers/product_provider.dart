import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

enum LoadStatus { loading, success, error }

enum SortOption { featured, priceLow, priceHigh, rating }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.featured:
        return 'Featured';
      case SortOption.priceLow:
        return 'Price: low to high';
      case SortOption.priceHigh:
        return 'Price: high to low';
      case SortOption.rating:
        return 'Top rated';
    }
  }
}

/// Holds the catalog plus the current search text, category and sort order.
/// Search and filtering happen on the device, so they feel instant.
class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  List<Product> _all = [];
  LoadStatus _status = LoadStatus.loading;
  String _error = '';
  String _query = '';
  String? _category; // null means "All"
  SortOption _sort = SortOption.featured;

  ProductProvider({ProductService? service})
      : _service = service ?? ProductService();

  LoadStatus get status => _status;
  String get error => _error;
  String get query => _query;
  String? get category => _category;
  SortOption get sort => _sort;
  bool get hasData => _all.isNotEmpty;
  bool get hasActiveFilters => _query.isNotEmpty || _category != null;

  /// Every category found in the catalog, alphabetically.
  List<String> get categories {
    final set = _all.map((p) => p.category).toSet().toList();
    set.sort();
    return set;
  }

  /// Products after applying search, category and sort.
  List<Product> get filtered {
    final q = _query.trim().toLowerCase();

    final list = _all.where((p) {
      if (_category != null && p.category != _category) return false;
      if (q.isEmpty) return true;
      return p.title.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.featured:
        break; // keep the API's order
    }
    return list;
  }

  /// Loads (or reloads) the catalog. Old data stays visible if a reload fails.
  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = '';
    notifyListeners();

    try {
      _all = await _service.fetchProducts();
      _status = LoadStatus.success;
    } on ProductException catch (e) {
      _error = e.message;
      _status = LoadStatus.error;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  void setSort(SortOption value) {
    _sort = value;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _category = null;
    notifyListeners();
  }
}