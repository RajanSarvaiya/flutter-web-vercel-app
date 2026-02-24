import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../providers/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final isMobile = Responsive.isMobile(context);
    final columns = Responsive.gridColumns(context);

    if (wishlist.isEmpty) {
      return _EmptyWishlist();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16.0 : 32.0,
            24,
            isMobile ? 16.0 : 32.0,
            16,
          ),
          sliver: SliverToBoxAdapter(
            child: FadeSlideAnimation(
              child: Text(
                'My Wishlist',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 22.0 : 28.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns > 1 ? columns : 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return FadeSlideAnimation(
                  delay: index * 80,
                  child: ProductCard(product: wishlist.items[index]),
                );
              },
              childCount: wishlist.itemCount,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
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
                Icons.favorite_outline_rounded,
                size: 36,
                color: AppColors.grey400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your wishlist is empty',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Save items you love for later',
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
                'EXPLORE COLLECTION',
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
