import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/auth_gate_dialog.dart';
import '../../core/utils/responsive.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool showQuickAdd;
  final String heroPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.showQuickAdd = true,
    this.heroPrefix = 'card',
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleQuickAdd() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      auth.setPendingAction(() {
        final product = widget.product;
        context.read<CartProvider>().addItem(
              product,
              product.sizes.first,
              product.colors.first,
            );
      });
      AuthGateDialog.show(context, actionLabel: 'add to cart');
      return;
    }
    context.read<CartProvider>().addItem(
          widget.product,
          widget.product.sizes.first,
          widget.product.colors.first,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleWishlist() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      auth.setPendingAction(() {
        context.read<WishlistProvider>().toggleWishlist(widget.product);
      });
      AuthGateDialog.show(context, actionLabel: 'save to wishlist');
      return;
    }
    context.read<WishlistProvider>().toggleWishlist(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isInWishlist = context.select<WishlistProvider, bool>(
        (wl) => wl.isInWishlist(widget.product.id));

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/product/${widget.product.id}'),
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.04 + _elevationAnimation.value * 0.01),
                    blurRadius: 4 + _elevationAnimation.value,
                    offset: Offset(0, 2 + _elevationAnimation.value * 0.3),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Hero(
                        tag: 'product-${widget.heroPrefix}-${widget.product.id}',
                        child: CachedNetworkImage(
                          imageUrl: widget.product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(

                            baseColor: AppColors.grey200,
                            highlightColor: AppColors.grey100,
                            child: Container(color: AppColors.grey200),
                          ),
                          errorWidget: (context, url, error) => Container(

                            color: AppColors.grey100,
                            child: const Icon(Icons.image_outlined,
                                color: AppColors.grey400, size: 40),
                          ),
                        ),
                      ),
                    ),
                    // Badges
                    if (widget.product.hasDiscount || widget.product.isNew)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.product.hasDiscount)
                              _Badge(
                                  '${widget.product.discountPercent}% OFF',
                                  AppColors.danger),
                            if (widget.product.isNew)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: _Badge('NEW', AppColors.black),
                              ),
                          ],
                        ),
                      ),
                    // Wishlist button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _toggleWishlist,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isInWishlist
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 18,
                            color: isInWishlist
                                ? AppColors.danger
                                : AppColors.grey600,
                          ),
                        ),
                      ),
                    ),
                    // Quick add button on hover (desktop)
                    if (isDesktop && widget.showQuickAdd)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedSlide(
                          offset: _isHovering
                              ? Offset.zero
                              : const Offset(0, 1),
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedOpacity(
                            opacity: _isHovering ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: _handleQuickAdd,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                color: AppColors.black.withValues(alpha: 0.9),
                                child: Text(
                                  'QUICK ADD',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Row(
                      children: [
                        Text(
                          '\u20B9${widget.product.price.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        if (widget.product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '\u20B9${widget.product.originalPrice.toInt()}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.grey500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
