// Product model
// Represents a single product, whether it comes from the DummyJSON API
// or from the local SQLite database.

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String image;
  final String brand;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.image,
    required this.brand,
  });

  // Create a Product from the JSON returned by the DummyJSON API.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      // API sometimes returns price as int, sometimes double, so we parse safely.
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      // Prefer the first image from the "images" list, fallback to "thumbnail".
      image: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? json['images'][0]
          : (json['thumbnail'] ?? ''),
      brand: json['brand'] ?? '',
    );
  }

  // Create a Product from a row stored in SQLite.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      rating: map['rating'] is int ? (map['rating'] as int).toDouble() : map['rating'],
      stock: map['stock'],
      image: map['image'],
      brand: map['brand'],
    );
  }

  // Convert a Product into a Map so it can be saved into SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'stock': stock,
      'image': image,
      'brand': brand,
    };
  }

  // Helper to create a copy of a product with some fields changed.
  // Useful when editing a product.
  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? rating,
    int? stock,
    String? image,
    String? brand,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      brand: brand ?? this.brand,
    );
  }
}
