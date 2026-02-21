import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: isMobile ? _buildDrawer(context) : null,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_paper_texture.png'),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: navigationShell,
      ),
      bottomNavigationBar: isMobile
          ? AppBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final cartCount =
        context.select<CartProvider, int>((cart) => cart.itemCount);

    return AppBar(
      leading: isMobile
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            'KITE & CO.',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 18.0 : 22.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: AppColors.black,
            ),
          ),
        ),
      ),
      centerTitle: isMobile,
      actions: [
        if (!isMobile) ...[
          _NavLink('Home', () => context.go('/')),
          _NavLink('Shirts', () => context.go('/category/Formal%20Shirts')),
          _NavLink('Pants', () => context.go('/category/Formal%20Pants')),
          SizedBox(width: 16),
        ],
        // Wishlist
        IconButton(
          icon: const Icon(Icons.favorite_outline_rounded, size: 22),
          onPressed: () {
            if (isMobile) {
              navigationShell.goBranch(1);
            } else {
              context.go('/wishlist');
            }
          },
        ),
        // Cart
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 22),
              onPressed: () {
                if (isMobile) {
                  navigationShell.goBranch(2);
                } else {
                  context.go('/cart');
                }
              },
            ),
            if (cartCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    cartCount > 9 ? '9+' : '$cartCount',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Profile
        if (!isMobile)
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, size: 22),
            onPressed: () => context.go('/profile'),
          ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'KITE & CO.',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Premium Formal Wear',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                    letterSpacing: 1,
                  ),
                ),
                if (auth.isLoggedIn) ...[
                  SizedBox(height: 8),
                  Text(
                    'Hello, ${auth.userName}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          _DrawerItem(
            icon: Icons.checkroom_outlined,
            label: 'Formal Shirts',
            onTap: () {
              Navigator.pop(context);
              context.go('/category/Formal%20Shirts');
            },
          ),
          _DrawerItem(
            icon: Icons.straighten_outlined,
            label: 'Formal Pants',
            onTap: () {
              Navigator.pop(context);
              context.go('/category/Formal%20Pants');
            },
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.favorite_outline,
            label: 'Wishlist',
            onTap: () {
              Navigator.pop(context);
              context.go('/wishlist');
            },
          ),
          _DrawerItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Cart',
            onTap: () {
              Navigator.pop(context);
              context.go('/cart');
            },
          ),
          _DrawerItem(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          if (auth.isLoggedIn) ...[
            const Divider(),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              onTap: () {
                auth.logout();
                Navigator.pop(context);
                context.go('/');
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink(this.label, this.onTap);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovering ? AppColors.black : AppColors.grey700,
                  letterSpacing: 1.5,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: _hovering ? 24 : 0.0,
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey800,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
