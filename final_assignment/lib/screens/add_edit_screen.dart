// Add / Edit Screen
// Same screen is used for both adding a new product and editing an
// existing one. If an existing product is passed in, its values are
// used to pre-fill the form.

import 'package:flutter/material.dart';
import '../models/product.dart';

class AddEditScreen extends StatefulWidget {
  final Product? existingProduct; // null when adding a new product

  const AddEditScreen({super.key, this.existingProduct});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _ratingController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;
  late TextEditingController _brandController;

  bool get isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;

    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toString() : '');
    _ratingController = TextEditingController(text: p != null ? p.rating.toString() : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '');
    _imageController = TextEditingController(text: p?.image ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // If editing, keep the same id. If adding, generate a new local id
    // using the current time so it doesn't clash with API ids.
    final id = isEditing ? widget.existingProduct!.id : DateTime.now().millisecondsSinceEpoch;

    final product = Product(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      rating: double.tryParse(_ratingController.text.trim()) ?? 0,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      image: _imageController.text.trim(),
      brand: _brandController.text.trim(),
    );

    Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, 'Title', requiredField: true),
              _buildTextField(_descriptionController, 'Description', maxLines: 3),
              _buildTextField(_categoryController, 'Category'),
              _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
              _buildTextField(_ratingController, 'Rating (0-5)', keyboardType: TextInputType.number),
              _buildTextField(_stockController, 'Stock', keyboardType: TextInputType.number),
              _buildTextField(_imageController, 'Image URL'),
              _buildTextField(_brandController, 'Brand'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
