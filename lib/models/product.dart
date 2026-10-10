/// A product from the catalog.
class Product {
  final int id;
  final String title;
  final String description;
  final String category; // slug like "mens-shirts"
  final String brand; // may be empty
  final double price; // USD
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final images =
        (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final thumbnail = (json['thumbnail'] as String?) ??
        (images.isNotEmpty ? images.first : '');

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      brand: json['brand'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      thumbnail: thumbnail,
      images: images.isEmpty && thumbnail.isNotEmpty ? [thumbnail] : images,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'brand': brand,
    'price': price,
    'rating': rating,
    'stock': stock,
    'thumbnail': thumbnail,
    'images': images,
  };
}