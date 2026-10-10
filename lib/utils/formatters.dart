/// 29.99 -> "$29.99"
String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';

/// "mens-shirts" -> "Mens Shirts"
String prettyCategory(String slug) {
  return slug
      .split(RegExp(r'[-_ ]'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}