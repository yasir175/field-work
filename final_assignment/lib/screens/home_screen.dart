// Home Screen
// The main screen of the app. Shows the product list, search bar,
// Load More pagination button, pull-to-refresh, and add/edit/delete actions.

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = []; // full list currently loaded (from API or DB)
  List<Product> _displayedProducts = []; // list shown after search filter

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  String? _errorMessage;
  int _dataVersion = 0;

  int _skip = 0;
  final int _pageSize = 10;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load the first page of products: try the API first, fall back to SQLite.
  Future<void> _loadInitialProducts() async {
    final loadVersion = _dataVersion;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _skip = 0;
      _hasMoreData = true;
    });

    try {
      final products = await _apiService.fetchProducts(limit: _pageSize, skip: 0);
      final cachedProducts = await _dbHelper.getAllProducts();

      final cachedById = {for (final product in cachedProducts) product.id: product};
      final mergedProducts = <Product>[
        for (final product in products) cachedById[product.id] ?? product,
        ...cachedProducts.where((product) => !products.any((remote) => remote.id == product.id)),
      ];

      if (!mounted || loadVersion != _dataVersion) return;

      // Successful fetch: save fresh data into SQLite for offline use.
      await _dbHelper.replaceProducts(mergedProducts);

      if (!mounted || loadVersion != _dataVersion) return;

      setState(() {
        _allProducts = mergedProducts;
        _displayedProducts = mergedProducts;
        _isOffline = false;
        _skip = products.length;
        _hasMoreData = products.length == _pageSize;
      });
    } catch (e) {
      if (!mounted || loadVersion != _dataVersion) return;

      // Network failed, fall back to whatever is cached locally.
      final cachedProducts = await _dbHelper.getAllProducts();

      if (!mounted || loadVersion != _dataVersion) return;

      setState(() {
        _isOffline = true;
        _allProducts = cachedProducts;
        _displayedProducts = cachedProducts;
        _hasMoreData = false; // no pagination while offline
        if (cachedProducts.isEmpty) {
          _errorMessage = 'No internet connection and no cached data available.';
        }
      });

      if (cachedProducts.isNotEmpty && mounted) {
        _showSnackBar('No internet connection. Showing cached products.');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Load the next page of products (pagination).
  Future<void> _loadMoreProducts() async {
    if (_isOffline || !_hasMoreData || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final moreProducts = await _apiService.fetchProducts(limit: _pageSize, skip: _skip);

      setState(() {
        _allProducts.addAll(moreProducts);
        _displayedProducts = List.from(_allProducts);
        _skip += moreProducts.length;
        _hasMoreData = moreProducts.length == _pageSize;
      });

      // Keep the local cache in sync with everything loaded so far.
      await _dbHelper.replaceProducts(_allProducts);
    } catch (e) {
      if (mounted) _showSnackBar('Could not load more products. Check your connection.');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  // Pull-to-refresh: reload products from the API from scratch.
  Future<void> _refreshProducts() async {
    await _loadInitialProducts();
  }

  // Simple local search/filter as the user types.
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _displayedProducts = List.from(_allProducts);
      } else {
        _displayedProducts = _allProducts.where((product) {
          return product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Open Detail Screen for a product.
  void _viewProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DetailScreen(product: product)),
    );
  }

  // Open Add/Edit Screen to add a brand new product.
  Future<void> _addProduct() async {
    final newProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (context) => const AddEditScreen()),
    );

    if (newProduct != null) {
      await _dbHelper.insertProduct(newProduct);
      _dataVersion++;
      setState(() {
        _allProducts.insert(0, newProduct);
        _displayedProducts = List.from(_allProducts);
      });
      _showSnackBar('Product added.');
    }
  }

  // Open Add/Edit Screen to edit an existing product.
  Future<void> _editProduct(Product product) async {
    final updatedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (context) => AddEditScreen(existingProduct: product)),
    );

    if (updatedProduct != null) {
      await _dbHelper.updateProduct(updatedProduct);
      _dataVersion++;
      setState(() {
        final index = _allProducts.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) _allProducts[index] = updatedProduct;
        _displayedProducts = List.from(_allProducts);
      });
      _showSnackBar('Product updated.');
    }
  }

  // Show confirmation dialog, then delete the product locally.
  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteProduct(product.id);
        _dataVersion++;
        setState(() {
          _allProducts.removeWhere((p) => p.id == product.id);
          _displayedProducts.removeWhere((p) => p.id == product.id);
        });
        _showSnackBar('Product deleted.');
      } catch (e) {
        _showSnackBar('Failed to delete product.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.cloud_off),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or category...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_displayedProducts.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Simple responsive layout: use a grid on wide screens (tablets),
          // and a plain list on narrow screens (phones).
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.6,
              ),
              itemCount: _displayedProducts.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) => _buildListItem(index),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _displayedProducts.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) => _buildListItem(index),
          );
        },
      ),
    );
  }

  Widget _buildListItem(int index) {
    // Last item reserved for the "Load More" button when more data exists.
    if (index == _displayedProducts.length) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _isLoadingMore
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _loadMoreProducts,
                  child: const Text('Load More'),
                ),
        ),
      );
    }

    final product = _displayedProducts[index];
    return ProductCard(
      product: product,
      onView: () => _viewProduct(product),
      onEdit: () => _editProduct(product),
      onDelete: () => _deleteProduct(product),
    );
  }
}
