import '../../data/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? category,
    int page,
    int perPage,
  });

  Future<Product?> getProductById(String id);
  Future<List<Product>> getFeaturedProducts();
  Future<List<Product>> getRelatedProducts(Product product, {int limit});
  Future<List<Product>> searchProducts(String query);
}
