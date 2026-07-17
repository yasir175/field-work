// Database Helper
// One simple class that manages the local SQLite database.
// Used both as an offline cache of API data and as local storage
// for CRUD operations (since DummyJSON's write endpoints don't
// really persist data on their server).

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

class DatabaseHelper {
  // Singleton pattern so the whole app shares one database instance.
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  // Get the database, opening/creating it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            category TEXT,
            price REAL,
            rating REAL,
            stock INTEGER,
            image TEXT,
            brand TEXT
          )
        ''');
      },
    );
  }

  // Insert a single product. Used for adding new local products.
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing product by id.
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete a product by id.
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get every product currently stored locally.
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id ASC');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // Replace all locally cached products with a fresh list from the API.
  // Used right after a successful network fetch, so offline mode
  // always has the latest downloaded data.
  Future<void> replaceProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('products');
    for (final product in products) {
      batch.insert('products', product.toMap());
    }

    await batch.commit(noResult: true);
  }

  // Wipe the whole products table.
  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }
}
