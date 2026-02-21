import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../providers/product_provider.dart';
import '../../../data/dummy/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollCtrl;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 300;
      if (show != _showFab) {
        setState(() => _showFab = show);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollCtrl,
          child: Column(
            children: [
              const _HeroCarousel(),
              SizedBox(height: 48),
              const _CategoryShowcase(),
              SizedBox(height: 48),
              const _FeaturedProducts(),
              SizedBox(height: 48),
              const _PromoSection(),
            ],
          ),
        ),
        // Scroll-to-top FAB
        Positioned(
          right: 24,
          bottom: 32,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _showFab
                ? FloatingActionButton(
                    key: const ValueKey('fab_up'),
                    onPressed: _scrollToTop,
                    backgroundColor: Colors.black,
                    elevation: 4,
                    mini: false,
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('fab_hidden')),
          ),
        ),
      ],
    );
  }
}

// ── Hero Carousel (Full Screen + Crossfade) ──
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  Timer? _autoTimer;
  late AnimationController _bounceController;

  final _slides = const [
    _SlideData(
      title: 'NEW SEASON',
      subtitle: 'Formal Shirts',
      description: 'Crafted with precision. Designed for distinction.',
      ctaText: 'SHOP SHIRTS',
      route: '/category/Formal%20Shirts',
      imageUrl:
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=1200&h=800&fit=crop',
    ),
    _SlideData(
      title: 'TAILORED FIT',
      subtitle: 'Formal Pants',
      description: 'Impeccable tailoring meets modern style.',
      ctaText: 'SHOP PANTS',
      route: '/category/Formal%20Pants',
      imageUrl:
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=1200&h=800&fit=crop',
    ),
    _SlideData(
      title: 'BEST SELLERS',
      subtitle: 'Curated Collection',
      description: 'Our most loved styles, handpicked for you.',
      ctaText: 'EXPLORE NOW',
      route: '/',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200&h=800&fit=crop',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() => _currentPage = (_currentPage + 1) % _slides.length);
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isMobile = Responsive.isMobile(context);

    return Container(
      height: screenHeight,
      color: Colors.black, // Base background to prevent white flashes
      child: Stack(
        children: [
          // 3D Cube transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1200),
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey(_currentPage);
              
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: isIncoming ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOutCubic)),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: _HeroSlide(
              key: ValueKey(_currentPage),
              data: _slides[_currentPage],
              isMobile: isMobile,
            ),
          ),

          // Dot indicator
          Positioned(
            bottom: 72,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = _currentPage == i;
                return GestureDetector(
                  onTap: () => setState(() => _currentPage = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8.0,
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Scroll-down hint
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceController.value * 8),
                  child: child,
                );
              },
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  final String description;
  final String ctaText;
  final String route;
  final String imageUrl;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.ctaText,
    required this.route,
    required this.imageUrl,
  });
}

class _HeroSlide extends StatelessWidget {

  final _SlideData data;
  final bool isMobile;

  const _HeroSlide({super.key, required this.data, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: data.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.black),
          errorWidget: (context, url, error) => Container(color: Colors.black),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.black.withValues(alpha: 0.75),
                AppColors.black.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        Positioned(
          left: isMobile ? 24.0 : 64.0,
          bottom: isMobile ? 60.0 : 80.0,
          right: isMobile ? 24.0 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white.withValues(alpha: 0.7),
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                data.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 32.0 : 48.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 12),
              Text(
                data.description,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14.0 : 16.0,
                  color: AppColors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(data.route),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24.0 : 36.0,
                    vertical: isMobile ? 14.0 : 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  data.ctaText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Category Showcase ──
class _CategoryShowcase extends StatelessWidget {
  const _CategoryShowcase();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = isMobile ? 16.0 : 22.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final isTablet = !isMobile && maxWidth < 1200;
              final isDesktop = maxWidth >= 1200;

              // Grid columns based on width
              final crossAxisCount = isMobile
                  ? 1
                  : (maxWidth >= 1400 ? 4 : (maxWidth >= 1000 ? 3 : 2));

              // Card aspect ratio and large variant for wide layouts
              final childAspectRatio =
                  isMobile ? 2.2 : (crossAxisCount >= 4 ? 0.72 : 0.65);
              final cardIsLarge = crossAxisCount >= 4;

              Widget grid = GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: isMobile ? 12 : 20,
                mainAxisSpacing: isMobile ? 12 : 20,
                children: [
                  _CategoryCard(
                    title: 'Formal Shirts',
                    image:
                        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&h=1200&fit=crop',
                    route: '/category/Formal%20Shirts',
                    delay: 200,
                    isLarge: cardIsLarge,
                  ),
                  _CategoryCard(
                    title: 'Formal Pants',
                    image:
                        'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800&h=1200&fit=crop',
                    route: '/category/Formal%20Pants',
                    delay: 300,
                    isLarge: cardIsLarge,
                  ),
                  _CategoryCard(
                    title: 'Formal Pair',
                    image:
                        'https://images.unsplash.com/photo-1521223890158-f9f7c3d5bab3?w=800&h=1200&fit=crop',
                    route: '/category/Suits',
                    delay: 400,
                    isLarge: cardIsLarge,
                  ),
                  _CategoryCard(
                    title: 'Premium Fabrics',
                    image:
                        'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=800&h=1200&fit=crop',
                    route: '/category/Fabrics',
                    delay: 500,
                    isLarge: cardIsLarge,
                  ),
                ],
              );

              // ── Desktop: top heading hidden; side panel on right ──
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: grid),
                    const SizedBox(width: 50),
                    const SizedBox(width: 360, child: _CategorySidePanel()),
                  ],
                );
              }

              // ── Mobile / Tablet: heading at top, grid below, no side panel ──
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top heading (replaces side panel on small screens)
                  FadeSlideAnimation(
                    child: Text(
                      'SHOP BY CATEGORY',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey500,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FadeSlideAnimation(
                    delay: 80,
                    child: Text(
                      'Our Collections',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 28.0 : 24.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  grid,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCardExpanded extends StatelessWidget {
  final String title;
  final String image;
  final String route;
  final int delay;

  const _CategoryCardExpanded({
    required this.title,
    required this.image,
    required this.route,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _CategoryCard(
        title: title,
        image: image,
        route: route,
        delay: delay,
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String title;
  final String image;
  final String route;
  final int delay;
  final bool isLarge;

  const _CategoryCard({
    required this.title,
    required this.image,
    required this.route,
    this.delay = 0,
    this.isLarge = false,
  });


  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final height = widget.isLarge ? (isMobile ? 360.0 : 520.0) : (isMobile ? 160.0 : 220.0);
    final padding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 16.0;
    final titleSize = widget.isLarge ? (isMobile ? 18.0 : 22.0) : (isMobile ? 14.0 : 18.0);
    final exploreSize = isMobile ? 10.0 : 12.0;
    final iconSize = isMobile ? 12.0 : 14.0;
    final underlineWidthDefault = isMobile ? 24.0 : 24.0;
    final underlineWidthHover = widget.isLarge ? (isMobile ? 64.0 : 80.0) : (isMobile ? 48.0 : 48.0);

    return FadeSlideAnimation(
      delay: widget.delay,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: () => context.go(widget.route),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12.0,
                  offset: const Offset(0, 6.0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Static image (no hover zoom)
                  CachedNetworkImage(
                    imageUrl: widget.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.grey800),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.grey800,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.grey400, size: 40),
                    ),
                  ),

                  // Static gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),

                  // Content (responsive)
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          width: _hovering ? underlineWidthHover : underlineWidthDefault,
                          color: AppColors.white,
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'EXPLORE COLLECTION',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: exploreSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  letterSpacing: isMobile ? 1.5 : 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.white,
                              size: iconSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // // Large badge for the big cards (static opacity)
                  // if (widget.isLarge)
                  //   Positioned(
                  //     top: 16,
                  //     left: 16,
                  //     child: Opacity(
                  //       opacity: 0.85,
                  //       child: Container(
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 12, vertical: 8),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.white.withValues(alpha: 0.08),
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //         child: Text(
                  //           widget.title.toUpperCase(),
                  //           style: GoogleFonts.poppins(
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w600,
                  //             color: AppColors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Right-hand information panel used in the new showcase layout
class _CategorySidePanel extends StatelessWidget {
  const _CategorySidePanel();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final headingSize = isMobile ? 28.0 : 40.0;
    final subtitleSize = isMobile ? 14.0 : 16.0;
    final buttonFontSize = isMobile ? 12.0 : 14.0; // ignore: unused_local_variable
    final verticalSpacingSmall = isMobile ? 10.0 : 12.0;
    final verticalSpacingLarge = isMobile ? 18.0 : 24.0;

    return FadeSlideAnimation(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 12.0 : 40.0),
        child: Center(
          child: 
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
            '// Our Collections',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 24.0 : 32.0,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
            SizedBox(height: verticalSpacingSmall),
            Text(
            'SHOP BY CATEGORY',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
              letterSpacing: 4,
            ),
          ),
            SizedBox(height: verticalSpacingLarge),
          ],
        ),
        ),
      ),
    );
  }
}


// ── Featured Products ──
class _FeaturedProducts extends StatefulWidget {
  const _FeaturedProducts();

  @override
  State<_FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<_FeaturedProducts>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['All', 'Best Sellers', 'New Arrivals'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _getProducts(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return MockData.bestSellers;
      case 2:
        return MockData.newArrivals;
      default:
        return MockData.featured;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final columns = Responsive.gridColumns(context);
    final padding = isMobile ? 16.0 : 22.0;

    return Column(
      children: [
        FadeSlideAnimation(
          child: Text(
            'CURATED FOR YOU',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.grey500,
              letterSpacing: 4,
            ),
          ),
        ),
        SizedBox(height: 8),
        FadeSlideAnimation(
          delay: 100,
          child: Text(
            'Featured Collection',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 24.0 : 32.0,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(height: 24),
        // Tabs
        FadeSlideAnimation(
          delay: 200,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.black,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerHeight: 0,
            tabAlignment: TabAlignment.center,
            tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
            onTap: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 24),
        // Products grid
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final products = _getProducts(_tabController.index);
            final displayCount =
                products.length > 8 ? 8 : products.length;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                key: ValueKey(_tabController.index),
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns > 1 ? columns : 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    return FadeSlideAnimation(
                      delay: index * 80,
                      child: ProductCard(product: products[index], heroPrefix: 'featured'),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Promo Section with Video-Like Background Animation ──
class _PromoSection extends StatefulWidget {
  const _PromoSection();

  @override
  State<_PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<_PromoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = Responsive.isMobile(context);

    return FadeSlideAnimation(
      child: Container(
        width: double.infinity,
        height: isMobile ? 500 : 550,
        color: AppColors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated video-like background
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _VideoBackgroundPainter(
                    progress: _bgController.value,
                    screenWidth: screenWidth,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Dark overlay
            Container(
              color: AppColors.black.withValues(alpha: 0.4),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 48.0,
                vertical: isMobile ? 40.0 : 60.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeSlideAnimation(
                    child: Text(
                      'THE KITE & CO. PROMISE',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white.withValues(alpha: 0.7),
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeSlideAnimation(
                    delay: 100,
                    child: Text(
                      'Premium Quality.\nTimeless Style.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 28.0 : 44.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeSlideAnimation(
                    delay: 200,
                    child: Text(
                      'Free shipping on orders over \u20B92,000 • Easy returns • Premium packaging',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 13.0 : 15.0,
                        color: AppColors.white.withValues(alpha: 0.7),
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 40),
                  Wrap(
                    spacing: isMobile ? 20 : 40,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _PromoFeature(
                        Icons.local_shipping_outlined,
                        'Free Shipping',
                        delay: 300,
                      ),
                      _PromoFeature(
                        Icons.replay_rounded,
                        '30-Day Returns',
                        delay: 350,
                      ),
                      _PromoFeature(
                        Icons.verified_outlined,
                        'Premium Quality',
                        delay: 400,
                      ),
                      _PromoFeature(
                        Icons.support_agent_outlined,
                        '24/7 Support',
                        delay: 450,
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

// Custom painter for video-like background animation
class _VideoBackgroundPainter extends CustomPainter {
  final double progress;
  final double screenWidth;

  _VideoBackgroundPainter({
    required this.progress,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create flowing gradient with wave effect
    final colors = [
      Color.fromARGB(60, 255, 255, 255),
      Color.fromARGB(30, 255, 255, 255),
      Color.fromARGB(10, 255, 255, 255),
    ];

    // Horizontal flowing gradient (video-like)
    final gradient = LinearGradient(
      begin: Alignment(-1.0 + (progress * 2.0), -0.5),
      end: Alignment(1.0 + (progress * 2.0), 0.5),
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw flowing waves
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Add subtle moving wave patterns
    _drawWaves(canvas, size);
  }

  void _drawWaves(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final offset = progress * size.width;
      final waveX = (offset - size.width) + (i * size.width / 2);

      final path = Path();
      for (double x = waveX; x < waveX + size.width; x += 10) {
        final y = size.height / 2 +
            30 * sin((x / size.width + progress) * 2 * 3.14159);
        if (x == waveX) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(_VideoBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Simple promo feature widget
class _PromoFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  final int delay;

  const _PromoFeature(
    this.icon,
    this.label, {
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: delay,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.white.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recently Viewed ──
class _RecentlyViewed extends StatelessWidget {
  const _RecentlyViewed();

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final recentlyViewed = products.recentlyViewed;
    final isMobile = Responsive.isMobile(context);

    if (recentlyViewed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 48.0),
          child: FadeSlideAnimation(
            child: Text(
              'Recently Viewed',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 20.0 : 24.0,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 48.0),
            itemCount: recentlyViewed.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 170,
                  child: FadeSlideAnimation(
                    delay: index * 60,
                    beginOffset: const Offset(0.3, 0),
                    child: ProductCard(
                      product: recentlyViewed[index],
                      showQuickAdd: false,
                      heroPrefix: 'recent',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
