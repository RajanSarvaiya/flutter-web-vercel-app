import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/kite_loader.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../providers/product_provider.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadInitial(category: widget.category);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      context.read<ProductProvider>().loadInitial(category: widget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final columns = Responsive.gridColumns(context);

    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isInitialLoading) {
          return const KiteLoader.fullScreen();
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _CategoryHeader(
                category: widget.category,
                productCount: provider.filteredProducts.length,
                isMobile: isMobile,
              ),
            ),
            // Toolbar
            SliverToBoxAdapter(
              child: _Toolbar(
                isGridView: _isGridView,
                onViewToggle: () => setState(() => _isGridView = !_isGridView),
                sortOption: provider.sortOption,
                onSortChanged: provider.setSortOption,
                isMobile: isMobile,
                onFilterTap: isMobile
                    ? () => _showFilterSheet(context, provider)
                    : null,
              ),
            ),
            // Content
            if (isDesktop)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Side filter
                      SizedBox(
                        width: 250,
                        child: _FilterPanel(provider: provider),
                      ),
                      SizedBox(width: 32),
                      // Products
                      Expanded(
                        child: _buildProductGrid(
                            provider, columns - 1, _isGridView),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildProductSliver(
                    provider, columns > 1 ? columns : 2, _isGridView),
              ),
            // Pagination loader
            if (provider.isLoadingMore)
              const SliverToBoxAdapter(child: PaginationLoader()),
            // No more items
            if (!provider.hasMore && provider.displayedProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'You\'ve seen all items',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              ),
            // Empty state
            if (provider.displayedProducts.isEmpty && !provider.isInitialLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: FadeSlideAnimation(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.grey400),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.grey500,
                            ),
                          ),
                          SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: provider.clearFilters,
                            child: const Text('CLEAR FILTERS'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildProductGrid(
      ProductProvider provider, int columns, bool isGrid) {
    final products = provider.displayedProducts;
    if (!isGrid) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 200,
              child: FadeSlideAnimation(
                delay: index * 50,
                child: ProductCard(product: products[index]),
              ),
            ),
          );
        },
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns > 0 ? columns : 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return FadeSlideAnimation(
          delay: index * 50,
          child: ProductCard(product: products[index]),
        );
      },
    );
  }

  Widget _buildProductSliver(
      ProductProvider provider, int columns, bool isGrid) {
    final products = provider.displayedProducts;
    if (!isGrid) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 200,
                child: FadeSlideAnimation(
                  delay: index * 50,
                  child: ProductCard(product: products[index]),
                ),
              ),
            );
          },
          childCount: products.length,
        ),
      );
    }
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return FadeSlideAnimation(
            delay: index * 50,
            child: ProductCard(product: products[index]),
          );
        },
        childCount: products.length,
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: _FilterPanel(provider: provider),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;
  final int productCount;
  final bool isMobile;

  const _CategoryHeader({
    required this.category,
    required this.productCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
      decoration: const BoxDecoration(
        color: AppColors.grey50,
      ),
      child: FadeSlideAnimation(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    'Home',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.chevron_right, size: 16, color: AppColors.grey400),
                ),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              category,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 24.0 : 32.0,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '$productCount products',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onViewToggle;
  final SortOption sortOption;
  final ValueChanged<SortOption> onSortChanged;
  final bool isMobile;
  final VoidCallback? onFilterTap;

  const _Toolbar({
    required this.isGridView,
    required this.onViewToggle,
    required this.sortOption,
    required this.onSortChanged,
    required this.isMobile,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 48.0,
        vertical: 12,
      ),
      child: Row(
        children: [
          if (isMobile && onFilterTap != null)
            TextButton.icon(
              onPressed: onFilterTap,
              icon: Icon(Icons.tune_rounded, size: 18),
              label: const Text('Filter'),
              style: TextButton.styleFrom(foregroundColor: AppColors.black),
            ),
          const Spacer(),
          // Sort
          PopupMenuButton<SortOption>(
            initialValue: sortOption,
            onSelected: onSortChanged,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_rounded, size: 18, color: AppColors.grey600),
                const SizedBox(width: 6),
                Text(
                  'Sort',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            itemBuilder: (_) => [
              _sortItem(SortOption.popular, 'Most Popular'),
              _sortItem(SortOption.priceLowHigh, 'Price: Low to High'),
              _sortItem(SortOption.priceHighLow, 'Price: High to Low'),
              _sortItem(SortOption.newest, 'Newest First'),
            ],
          ),
          const SizedBox(width: 12),
          // View toggle
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              size: 20,
              color: AppColors.grey600,
            ),
            onPressed: onViewToggle,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<SortOption> _sortItem(SortOption option, String label) {
    return PopupMenuItem(
      value: option,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: sortOption == option ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final ProductProvider provider;

  const _FilterPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: provider.clearFilters,
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Sizes
        Text(
          'SIZES',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.grey500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.availableSizes.map((size) {
            final selected = provider.selectedSizes.contains(size);
            return GestureDetector(
              onTap: () => provider.toggleSize(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.black : AppColors.white,
                  border: Border.all(
                    color: selected ? AppColors.black : AppColors.grey300,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  size,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.white : AppColors.grey700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Colors
        Text(
          'COLORS',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.grey500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.availableColors.map((color) {
            final selected = provider.selectedColors.contains(color);
            return GestureDetector(
              onTap: () => provider.toggleColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.black : AppColors.white,
                  border: Border.all(
                    color: selected ? AppColors.black : AppColors.grey300,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  color,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.white : AppColors.grey700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Price range
        Text(
          'PRICE RANGE',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.grey500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: provider.priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          activeColor: AppColors.black,
          inactiveColor: AppColors.grey200,
          labels: RangeLabels(
            '\u20B9${provider.priceRange.start.toInt()}',
            '\u20B9${provider.priceRange.end.toInt()}',
          ),
          onChanged: provider.setPriceRange,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\u20B9${provider.priceRange.start.toInt()}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey600),
            ),
            Text(
              '\u20B9${provider.priceRange.end.toInt()}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
