import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../providers/cart_provider.dart';
import '../../../data/models/product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isMobile = Responsive.isMobile(context);

    if (cart.isEmpty) {
      return _EmptyCart();
    }

    if (isMobile) {
      return _MobileCart(cart: cart);
    }
    return _DesktopCart(cart: cart);
  }
}

// ── Empty Cart ──
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeSlideAnimation(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: AppColors.grey400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add something premium to your bag',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.grey500,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'START SHOPPING',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile Cart ──
class _MobileCart extends StatelessWidget {
  final CartProvider cart;

  const _MobileCart({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: cart.items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return FadeSlideAnimation(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'My Cart (${cart.itemCount})',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }
              final itemIndex = index - 1;
              return FadeSlideAnimation(
                delay: index * 60,
                child: _CartItemTile(
                  item: cart.items[itemIndex],
                  index: itemIndex,
                  isMobile: true,
                ),
              );
            },
          ),
        ),
        _OrderSummaryBar(cart: cart),
      ],
    );
  }
}

// ── Desktop Cart ──
class _DesktopCart extends StatelessWidget {
  final CartProvider cart;

  const _DesktopCart({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(48),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          child: FadeSlideAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping Cart',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart items
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          return FadeSlideAnimation(
                            delay: index * 60,
                            child: _CartItemTile(
                              item: cart.items[index],
                              index: index,
                              isMobile: false,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 48),
                    // Order summary
                    SizedBox(
                      width: 360,
                      child: _OrderSummaryPanel(cart: cart),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Cart Item Tile ──
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final int index;
  final bool isMobile;

  const _CartItemTile({
    required this.item,
    required this.index,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Dismissible(
      key: ValueKey('${item.product.id}-${item.selectedSize}-${item.selectedColor}'),
      direction: isMobile
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      onDismissed: (_) => cart.removeItem(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.product.images.first,
                width: isMobile ? 80.0 : 100.0,
                height: isMobile ? 100.0 : 120.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 13.0 : 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!isMobile)
                        IconButton(
                          icon: Icon(Icons.close, size: 18),
                          onPressed: () => cart.removeItem(index),
                          color: AppColors.grey400,
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item.selectedSize} • ${item.selectedColor}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: item.quantity > 1
                                  ? () => cart.updateQuantity(
                                      index, item.quantity - 1)
                                  : null,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: 28,
                                child: Text(
                                  '${item.quantity}',
                                  key: ValueKey(item.quantity),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () => cart.updateQuantity(
                                  index, item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        '\u20B9${item.total.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppColors.black : AppColors.grey300,
        ),
      ),
    );
  }
}

// ── Order Summary (Mobile Bar) ──
class _OrderSummaryBar extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummaryBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final shipping = cart.subtotal >= 2000 ? 0.0 : 149.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                    Text(
                      '\u20B9${(cart.total + shipping).toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: Text(
                      'CHECKOUT',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (shipping == 0)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Free shipping applied!',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Order Summary (Desktop Panel) ──
class _OrderSummaryPanel extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummaryPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    final shipping = cart.subtotal >= 2000 ? 0.0 : 149.0;
    final total = cart.total + shipping;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20),
          _SummaryRow('Subtotal', '\u20B9${cart.subtotal.toInt()}'),
          if (cart.totalSavings > 0)
            _SummaryRow(
              'Savings',
              '-\u20B9${cart.totalSavings.toInt()}',
              valueColor: AppColors.success,
            ),
          _SummaryRow(
            'Shipping',
            shipping == 0 ? 'FREE' : '\u20B9${shipping.toInt()}',
            valueColor: shipping == 0 ? AppColors.success : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: const Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\u20B9${total.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // Coupon
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 18, color: AppColors.grey500),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Apply coupon code',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
                Text(
                  'Apply',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'PROCEED TO CHECKOUT',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Trust badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 14, color: AppColors.grey500),
              SizedBox(width: 4),
              Text(
                'Secure checkout',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
