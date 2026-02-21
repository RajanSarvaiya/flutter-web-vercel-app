import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/auth_gate_dialog.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Responsive size helper
// ─────────────────────────────────────────────────────────────────────────────
class _RS {
  static double fs(BuildContext ctx, double m, double t, double d) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 768) return m;
    if (w < 1200) return t;
    return d;
  }

  static double sz(BuildContext ctx, double m, double t, double d) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 768) return m;
    if (w < 1200) return t;
    return d;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Root screen
// ─────────────────────────────────────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  final _pincodeCtrl = TextEditingController();
  String? _deliveryInfo;

  Product? get _product =>
      context.read<ProductProvider>().getProductById(widget.productId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = _product;
      if (p != null) {
        context.read<ProductProvider>().addToRecentlyViewed(p);
        setState(() {
          _selectedSize = p.sizes.isNotEmpty ? p.sizes.first : null;
          _selectedColor = p.colors.isNotEmpty ? p.colors.first : null;
        });
      }
    });
  }

  @override
  void dispose() {
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _addToCart() {
    final p = _product;
    if (p == null) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      auth.setPendingAction(() {
        context.read<CartProvider>().addItem(
            p, _selectedSize ?? p.sizes.first, _selectedColor ?? p.colors.first);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${p.name} added to cart')));
        }
      });
      AuthGateDialog.show(context, actionLabel: 'add to cart');
      return;
    }
    for (var i = 0; i < _quantity; i++) {
      context.read<CartProvider>().addItem(
          p, _selectedSize ?? p.sizes.first, _selectedColor ?? p.colors.first);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${p.name} added to cart'),
      action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white70,
          onPressed: () => context.go('/cart')),
    ));
  }

  void _buyNow() {
    _addToCart();
    context.go('/cart');
  }

  void _toggleWishlist() {
    final p = _product;
    if (p == null) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      auth.setPendingAction(
          () => context.read<WishlistProvider>().toggleWishlist(p));
      AuthGateDialog.show(context, actionLabel: 'save to wishlist');
      return;
    }
    context.read<WishlistProvider>().toggleWishlist(p);
  }

  void _checkDelivery() {
    if (_pincodeCtrl.text.length == 6) {
      setState(() => _deliveryInfo = 'Delivery by Tomorrow · Free');
    }
  }

  // Shared info-panel widgets list (used by both mobile & desktop)
  List<Widget> _infoWidgets(
      BuildContext context, Product p, bool isInWishlist) {
    return [
      _ProductHeader(product: p, isInWishlist: isInWishlist,
          onToggleWishlist: _toggleWishlist),
      const SizedBox(height: 6),
      _PriceRow(product: p),
      const SizedBox(height: 4),
      Text('(Incl. of all taxes)',
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.grey500,
              fontStyle: FontStyle.italic)),
      if (p.hasDiscount) ...[
        const SizedBox(height: 10),
        _GSTBadge(product: p),
      ],
      const SizedBox(height: 14),
      _SizeRow(
          sizes: p.sizes,
          selected: _selectedSize,
          onSelected: (s) => setState(() => _selectedSize = s)),
      const SizedBox(height: 14),
      _QuantityRow(
          quantity: _quantity,
          onChanged: (q) => setState(() => _quantity = q)),
      const SizedBox(height: 14),
      _ColorRow(
          colors: p.colors,
          selected: _selectedColor,
          onSelected: (c) => setState(() => _selectedColor = c)),
      const SizedBox(height: 16),
      _BNPLStrip(price: p.price),
      const SizedBox(height: 16),
      _DeliveryRow(
          ctrl: _pincodeCtrl,
          deliveryInfo: _deliveryInfo,
          onCheck: _checkDelivery),
      const SizedBox(height: 16),
      _CTAButtons(onAddToCart: _addToCart, onBuyNow: _buyNow),
      const SizedBox(height: 20),
      _Accordions(product: p),
      const SizedBox(height: 12),
      _FeatureStrip(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.getProductById(widget.productId);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isSmallScreen = isMobile || isTablet;

    if (product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text('Product not found',
                style: GoogleFonts.poppins(fontSize: 18)),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () => context.go('/'),
                child: const Text('GO HOME')),
          ],
        ),
      );
    }

    final related = provider.getRelatedProducts(product);
    final isInWishlist = context
        .select<WishlistProvider, bool>((wl) => wl.isInWishlist(product.id));
    final infoWidgets = _infoWidgets(context, product, isInWishlist);

    if (isSmallScreen) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile / Tablet: image slider
                  _MobileImageStack(
                      images: product.images,
                      isInWishlist: isInWishlist,
                      onToggleWishlist: _toggleWishlist),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: _RS.sz(context, 12, 16, 32),
                        vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...infoWidgets,
                        const SizedBox(height: 20),
                        if (related.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 16),
                          _RelatedSection(related: related, isMobile: true),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mobile sticky bottom bar
          _MobileBottomBar(
              product: product,
              quantity: _quantity,
              onAddToCart: _addToCart,
              onBuyNow: _buyNow),
        ],
      );
    }

    // Desktop
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: _RS.sz(context, 12, 16, 24), vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Breadcrumb(product: product),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Left: image grid ──
                Expanded(
                  flex: 11,
                  child: _DesktopImageGrid(
                    images: product.images,
                    isInWishlist: isInWishlist,
                    onToggleWishlist: _toggleWishlist,
                  ),
                ),
                SizedBox(width: _RS.sz(context, 12, 24, 40)),
                // ── Right: info panel ──
                Expanded(
                  flex: 8,
                  child: FadeSlideAnimation(
                    delay: 150,
                    beginOffset: const Offset(0.15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: infoWidgets,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),
            if (related.isNotEmpty) _RelatedSection(related: related, isMobile: false),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Mobile: single-column full-width stacked images
class _MobileImageStack extends StatefulWidget {
  final List<String> images;
  final bool isInWishlist;
  final VoidCallback onToggleWishlist;

  const _MobileImageStack(
      {required this.images,
      required this.isInWishlist,
      required this.onToggleWishlist});

  @override
  State<_MobileImageStack> createState() => _MobileImageStackState();
}

class _MobileImageStackState extends State<_MobileImageStack> {
  late final PageController _pc;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.9,
          child: PageView.builder(
            controller: _pc,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (ctx, i) => Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.grey200,
                    highlightColor: AppColors.grey100,
                    child: Container(color: AppColors.grey200),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey100,
                    child: const Icon(Icons.image_outlined, size: 48),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _WishlistCircle(
                      isInWishlist: widget.isInWishlist,
                      onTap: widget.onToggleWishlist),
                ),
              ],
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.black : AppColors.grey300,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Desktop: 2-column grid of stacked portrait images (Myntra style)
class _DesktopImageGrid extends StatelessWidget {
  final List<String> images;
  final bool isInWishlist;
  final VoidCallback onToggleWishlist;

  const _DesktopImageGrid(
      {required this.images,
      required this.isInWishlist,
      required this.onToggleWishlist});

  @override
  Widget build(BuildContext context) {
    // Pair images into 2-column rows
    final List<Widget> rows = [];
    for (var i = 0; i < images.length; i += 2) {
      final a = images[i];
      final b = i + 1 < images.length ? images[i + 1] : null;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _GridImage(url: a)),
          const SizedBox(width: 4),
          Expanded(child: b != null ? _GridImage(url: b) : const SizedBox()),
        ],
      ));
      rows.add(const SizedBox(height: 4));
    }

    return Stack(
      children: [
        Column(children: rows),
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              _WishlistCircle(
                  isInWishlist: isInWishlist, onTap: onToggleWishlist),
              const SizedBox(height: 8),
              _IconCircle(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridImage extends StatelessWidget {
  final String url;
  const _GridImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.95,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.grey200,
          highlightColor: AppColors.grey100,
          child: Container(color: AppColors.grey200),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.grey100,
          child: const Icon(Icons.image_outlined, size: 40),
        ),
      ),
    );
  }
}

class _WishlistCircle extends StatelessWidget {
  final bool isInWishlist;
  final VoidCallback onTap;
  const _WishlistCircle({required this.isInWishlist, required this.onTap});

  @override
  Widget build(BuildContext context) =>
      _IconCircle(
        icon: isInWishlist
            ? Icons.bookmark_rounded
            : Icons.bookmark_border_rounded,
        iconColor: isInWishlist ? AppColors.black : AppColors.grey600,
        onTap: onTap,
      );
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _IconCircle(
      {required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon,
            size: 18, color: iconColor ?? AppColors.grey700),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info-panel sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ProductHeader extends StatelessWidget {
  final Product product;
  final bool isInWishlist;
  final VoidCallback onToggleWishlist;

  const _ProductHeader(
      {required this.product,
      required this.isInWishlist,
      required this.onToggleWishlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: _RS.fs(context, 15, 17, 18),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          product.category.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: _RS.fs(context, 11, 12, 12),
            color: AppColors.grey500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.star_rounded,
                      size: 11, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${product.reviewCount} Reviews)',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.grey500),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final Product product;
  const _PriceRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 8,
      children: [
        if (product.hasDiscount)
          Text(
            'MRP ₹${product.originalPrice.toInt()}',
            style: GoogleFonts.poppins(
              fontSize: _RS.fs(context, 13, 14, 15),
              color: AppColors.grey400,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          '₹${product.price.toInt()}',
          style: GoogleFonts.poppins(
            fontSize: _RS.fs(context, 22, 26, 28),
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        if (product.hasDiscount)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              '${product.discountPercent}%',
              style: GoogleFonts.poppins(
                fontSize: _RS.fs(context, 13, 14, 15),
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ),
      ],
    );
  }
}

class _GSTBadge extends StatelessWidget {
  final Product product;
  const _GSTBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    final saving =
        ((product.originalPrice - product.price) * 0.18).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.savings_outlined,
              size: 14, color: Color(0xFF2E7D32)),
          const SizedBox(width: 5),
          Text(
            '( INCL. GST SAVINGS OF ₹$saving )',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeRow extends StatelessWidget {
  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelected;
  const _SizeRow(
      {required this.sizes,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SIZE GUIDE',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  decoration: TextDecoration.underline,
                )),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((s) {
            final sel = selected == s;
            return GestureDetector(
              onTap: () => onSelected(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _RS.sz(context, 48, 54, 56),
                height: _RS.sz(context, 40, 44, 46),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? AppColors.black : AppColors.white,
                  border: Border.all(
                      color: sel ? AppColors.black : AppColors.grey300,
                      width: sel ? 1.5 : 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  s,
                  style: GoogleFonts.poppins(
                    fontSize: _RS.fs(context, 12, 13, 13),
                    fontWeight:
                        sel ? FontWeight.w700 : FontWeight.w500,
                    color:
                        sel ? AppColors.white : AppColors.grey700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  const _QuantityRow(
      {required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('QUANTITY',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
              letterSpacing: 2,
            )),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QBtn(
                  icon: Icons.remove,
                  onTap: quantity > 1
                      ? () => onChanged(quantity - 1)
                      : null),
              Container(width: 1, height: 32, color: AppColors.grey200),
              SizedBox(
                width: 40,
                child: Text('$quantity',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
              Container(width: 1, height: 32, color: AppColors.grey200),
              _QBtn(icon: Icons.add, onTap: () => onChanged(quantity + 1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon,
              size: 16,
              color:
                  onTap == null ? AppColors.grey300 : AppColors.black),
        ),
      );
}

/// Color selector — small solid-color squares with name below
class _ColorRow extends StatelessWidget {
  final List<String> colors;
  final String? selected;
  final ValueChanged<String> onSelected;
  const _ColorRow(
      {required this.colors,
      required this.selected,
      required this.onSelected});

  // Map color names to rough Color values
  Color _colorFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('white')) return const Color(0xFFF5F5F5);
    if (n.contains('black')) return const Color(0xFF212121);
    if (n.contains('navy') || n.contains('blue')) {
      return const Color(0xFF1A2E5A);
    }
    if (n.contains('red')) return const Color(0xFFC62828);
    if (n.contains('green')) return const Color(0xFF2E7D32);
    if (n.contains('grey') || n.contains('gray')) {
      return const Color(0xFF9E9E9E);
    }
    if (n.contains('brown') || n.contains('khaki')) {
      return const Color(0xFF795548);
    }
    if (n.contains('beige') || n.contains('cream')) {
      return const Color(0xFFF5F0E8);
    }
    if (n.contains('pink')) return const Color(0xFFE91E63);
    if (n.contains('yellow')) return const Color(0xFFFFC107);
    if (n.contains('orange')) return const Color(0xFFFF5722);
    if (n.contains('purple')) return const Color(0xFF7B1FA2);
    if (n.contains('olive')) return const Color(0xFF558B2F);
    return const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('COLOR',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                  letterSpacing: 2,
                )),
            if (selected != null) ...[
              const SizedBox(width: 6),
              Text('— ${selected!.toUpperCase()}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  )),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((c) {
            final sel = selected == c;
            final clr = _colorFor(c);
            return GestureDetector(
              onTap: () => onSelected(c),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _RS.sz(context, 32, 36, 38),
                    height: _RS.sz(context, 32, 36, 38),
                    decoration: BoxDecoration(
                      color: clr,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                          color:
                              sel ? AppColors.black : AppColors.grey300,
                          width: sel ? 2 : 1),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: sel
                          ? AppColors.black
                          : AppColors.grey500,
                      fontWeight: sel
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BNPLStrip extends StatelessWidget {
  final double price;
  const _BNPLStrip({required this.price});

  @override
  Widget build(BuildContext context) {
    final inst = (price / 3).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF388E3C),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text('NEW',
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                        fontSize: _RS.fs(context, 11, 12, 12),
                        color: AppColors.grey700),
                    children: [
                      const TextSpan(text: 'PAY NOW '),
                      TextSpan(
                        text: '₹$inst',
                        style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' REST PAY LATER'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'AT 0% EMI ON CARDS | CHECK EMI NOW',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  final TextEditingController ctrl;
  final String? deliveryInfo;
  final VoidCallback onCheck;
  const _DeliveryRow(
      {required this.ctrl,
      required this.deliveryInfo,
      required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CHECK ESTIMATED DELIVERY',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
              letterSpacing: 1.5,
            )),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: ctrl,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Pincode',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.grey400),
                    counterText: '',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: AppColors.black),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: onCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text('CHECK',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
        if (deliveryInfo != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 14, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Text(deliveryInfo!,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ],
    );
  }
}

/// Dual CTA — width-equal ADD TO CART (outlined) + BUY IT NOW (filled)
class _CTAButtons extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  const _CTAButtons(
      {required this.onAddToCart, required this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    final h = _RS.sz(context, 48.0, 50.0, 52.0);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: h,
            child: OutlinedButton(
              onPressed: onAddToCart,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
              ),
              child: Text('ADD TO CART',
                  style: GoogleFonts.poppins(
                      fontSize: _RS.fs(context, 12, 13, 13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      letterSpacing: 0.8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: h,
            child: ElevatedButton(
              onPressed: onBuyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
              ),
              child: Text('BUY IT NOW',
                  style: GoogleFonts.poppins(
                      fontSize: _RS.fs(context, 12, 13, 13),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Collapsible accordion sections
class _Accordions extends StatelessWidget {
  final Product product;
  const _Accordions({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccordionTile(title: 'DESCRIPTION', content: product.description,
            initialExpanded: true),
        _AccordionTile(
            title: 'MANUFACTURER DETAILS',
            content:
                'Manufactured in India. Marketed by ${product.category} Brand Pvt. Ltd. Country of Origin: India.'),
        _AccordionTile(
            title: 'SHIPPING, RETURN AND EXCHANGE',
            content:
                'Free shipping on orders above ₹499. Easy 30-day returns. Exchange within 15 days. Items must be unworn and with original tags.'),
      ],
    );
  }
}

class _AccordionTile extends StatefulWidget {
  final String title;
  final String content;
  final bool initialExpanded;
  const _AccordionTile(
      {required this.title,
      required this.content,
      this.initialExpanded = false});

  @override
  State<_AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<_AccordionTile>
    with SingleTickerProviderStateMixin {
  late bool _open;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _open = widget.initialExpanded;
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
        value: widget.initialExpanded ? 1.0 : 0.0);
    _anim = _ctrl.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      _open ? _ctrl.forward() : _ctrl.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.grey800,
                    )),
                AnimatedRotation(
                  turns: _open ? 0.125 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.add,
                      size: 16, color: AppColors.grey600),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) =>
                Align(heightFactor: _anim.value, child: child),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(widget.content,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey600,
                      height: 1.7)),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.local_shipping_outlined, 'Free shipping over ₹2,000'),
      (Icons.replay_rounded, '30-day easy returns'),
      (Icons.verified_outlined, 'Premium quality guarantee'),
    ];
    return Column(
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(e.$1, size: 16, color: AppColors.grey500),
                  const SizedBox(width: 8),
                  Text(e.$2,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.grey600)),
                ]),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile sticky bottom bar
// ─────────────────────────────────────────────────────────────────────────────
class _MobileBottomBar extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  const _MobileBottomBar(
      {required this.product,
      required this.quantity,
      required this.onAddToCart,
      required this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, -3))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onAddToCart,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.black, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    child: Text('ADD TO CART',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            letterSpacing: 0.8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    child: Text('BUY IT NOW',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Related products — 4-col grid on desktop, list on mobile
// ─────────────────────────────────────────────────────────────────────────────
class _RelatedSection extends StatelessWidget {
  final List<Product> related;
  final bool isMobile;
  const _RelatedSection(
      {required this.related, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final cols = isTablet ? 3 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MORE FROM THIS CATEGORY',
          style: GoogleFonts.poppins(
            fontSize: _RS.fs(context, 14, 16, 18),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 160,
                  child: FadeSlideAnimation(
                    delay: i * 70,
                    beginOffset: const Offset(0.3, 0),
                    child: ProductCard(
                        product: related[i],
                        showQuickAdd: false,
                        heroPrefix: 'rel-m'),
                  ),
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: related.length.clamp(0, cols * 2),
            itemBuilder: (ctx, i) => FadeSlideAnimation(
              delay: i * 70,
              beginOffset: const Offset(0, 0.15),
              child: ProductCard(
                  product: related[i], heroPrefix: 'rel-d'),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Breadcrumb
// ─────────────────────────────────────────────────────────────────────────────
class _Breadcrumb extends StatelessWidget {
  final Product product;
  const _Breadcrumb({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BLink('Home', () => context.go('/')),
        _Sep(),
        _BLink(product.category,
            () => context.go('/category/${Uri.encodeComponent(product.category)}')),
        _Sep(),
        Flexible(
          child: Text(product.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.black,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _BLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _BLink(this.text, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.grey500)),
      );
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('/',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.grey400,
              fontWeight: FontWeight.w600,
            )),
      );
}
