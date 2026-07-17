// Detail Screen
// Shows full information about a single product.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large product image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    height: 220,
                    child: Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(Icons.category, 'Category', product.category),
            if (product.brand.isNotEmpty)
              _buildInfoRow(Icons.branding_watermark, 'Brand', product.brand),
            _buildInfoRow(Icons.attach_money, 'Price', '\$${product.price.toStringAsFixed(2)}'),
            _buildInfoRow(Icons.star, 'Rating', product.rating.toStringAsFixed(2)),
            _buildInfoRow(Icons.inventory, 'Stock', '${product.stock} units'),

            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // Small helper to keep each info line consistent.
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
