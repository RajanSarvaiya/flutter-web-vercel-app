import '../../data/models/product.dart';
import '../../data/dummy/mock_data.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final List<Product> _allProducts = MockData.allProducts;

  @override
  Future<List<Product>> getProducts({
    String? category,
    int page = 1,
    int perPage = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var products = _allProducts.toList();

    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }

    final start = (page - 1) * perPage;
    if (start >= products.length) return [];

    final end = start + perPage;
    return products.sublist(
      start,
      end > products.length ? products.length : end,
    );
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<Product>> getRelatedProducts(Product product,
      {int limit = 4}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allProducts
        .where((p) => p.category == product.category && p.id != product.id)
        .take(limit)
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _allProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }
}
