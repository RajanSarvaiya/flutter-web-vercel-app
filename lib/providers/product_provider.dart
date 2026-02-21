import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/dummy/mock_data.dart';

enum SortOption { popular, priceLowHigh, priceHighLow, newest }

class ProductProvider extends ChangeNotifier {
  final List<Product> _allProducts = MockData.allProducts;
  List<Product> _displayedProducts = [];
  String? _selectedCategory;
  Set<String> _selectedSizes = {};
  Set<String> _selectedColors = {};
  RangeValues _priceRange = const RangeValues(0, 5000);
  SortOption _sortOption = SortOption.popular;
  String _searchQuery = '';
  final List<Product> _recentlyViewed = [];

  // Pagination
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;

  List<Product> get allProducts => _allProducts;
  List<Product> get displayedProducts => _displayedProducts;
  String? get selectedCategory => _selectedCategory;
  Set<String> get selectedSizes => _selectedSizes;
  Set<String> get selectedColors => _selectedColors;
  RangeValues get priceRange => _priceRange;
  SortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isInitialLoading => _isInitialLoading;
  List<Product> get recentlyViewed => List.unmodifiable(_recentlyViewed);

  List<Product> get filteredProducts {
    var products = _allProducts.toList();

    if (_selectedCategory != null) {
      products =
          products.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }

    if (_selectedSizes.isNotEmpty) {
      products = products
          .where(
              (p) => p.sizes.any((s) => _selectedSizes.contains(s)))
          .toList();
    }

    if (_selectedColors.isNotEmpty) {
      products = products
          .where(
              (p) => p.colors.any((c) => _selectedColors.contains(c)))
          .toList();
    }

    products = products
        .where(
            (p) => p.price >= _priceRange.start && p.price <= _priceRange.end)
        .toList();

    switch (_sortOption) {
      case SortOption.popular:
        products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case SortOption.priceLowHigh:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.newest:
        products.sort((a, b) {
          if (a.isNew && !b.isNew) return -1;
          if (!a.isNew && b.isNew) return 1;
          return 0;
        });
        break;
    }

    return products;
  }

  // Pagination methods
  Future<void> loadInitial({String? category}) async {
    _isInitialLoading = true;
    _currentPage = 1;
    _selectedCategory = category;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final filtered = filteredProducts;
    final end = _itemsPerPage > filtered.length ? filtered.length : _itemsPerPage;
    _displayedProducts = filtered.sublist(0, end);
    _hasMore = end < filtered.length;
    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentPage++;
    final filtered = filteredProducts;
    final start = (_currentPage - 1) * _itemsPerPage;

    if (start >= filtered.length) {
      _hasMore = false;
      _isLoadingMore = false;
      notifyListeners();
      return;
    }

    final end = start + _itemsPerPage > filtered.length
        ? filtered.length
        : start + _itemsPerPage;
    _displayedProducts.addAll(filtered.sublist(start, end));
    _hasMore = end < filtered.length;
    _isLoadingMore = false;
    notifyListeners();
  }

  void addToRecentlyViewed(Product product) {
    _recentlyViewed.removeWhere((p) => p.id == product.id);
    _recentlyViewed.insert(0, product);
    if (_recentlyViewed.length > 10) {
      _recentlyViewed.removeLast();
    }
    notifyListeners();
  }

  List<String> get availableSizes {
    final products = _selectedCategory != null
        ? _allProducts.where((p) => p.category == _selectedCategory)
        : _allProducts;
    return products.expand((p) => p.sizes).toSet().toList()..sort();
  }

  List<String> get availableColors {
    final products = _selectedCategory != null
        ? _allProducts.where((p) => p.category == _selectedCategory)
        : _allProducts;
    return products.expand((p) => p.colors).toSet().toList()..sort();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _currentPage = 1;
    _displayedProducts = [];
    _hasMore = true;
    loadInitial(category: category);
  }

  void toggleSize(String size) {
    if (_selectedSizes.contains(size)) {
      _selectedSizes.remove(size);
    } else {
      _selectedSizes.add(size);
    }
    _refreshPagination();
    notifyListeners();
  }

  void toggleColor(String color) {
    if (_selectedColors.contains(color)) {
      _selectedColors.remove(color);
    } else {
      _selectedColors.add(color);
    }
    _refreshPagination();
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    _refreshPagination();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _refreshPagination();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _refreshPagination();
    notifyListeners();
  }

  void clearFilters() {
    _selectedSizes = {};
    _selectedColors = {};
    _priceRange = const RangeValues(0, 5000);
    _sortOption = SortOption.popular;
    _searchQuery = '';
    _refreshPagination();
    notifyListeners();
  }

  void _refreshPagination() {
    _currentPage = 1;
    final filtered = filteredProducts;
    final end = _itemsPerPage > filtered.length ? filtered.length : _itemsPerPage;
    _displayedProducts = filtered.sublist(0, end);
    _hasMore = end < filtered.length;
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> getRelatedProducts(Product product) {
    return _allProducts
        .where((p) => p.category == product.category && p.id != product.id)
        .take(4)
        .toList();
  }
}
