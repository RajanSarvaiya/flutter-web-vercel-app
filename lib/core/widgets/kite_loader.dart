import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_colors.dart';

class KiteLoader extends StatefulWidget {
  final bool fullScreen;
  final double size;

  const KiteLoader({super.key, this.fullScreen = false, this.size = 40});

  const KiteLoader.fullScreen({super.key})
      : fullScreen = true,
        size = 40;

  const KiteLoader.inline({super.key})
      : fullScreen = false,
        size = 28;

  @override
  State<KiteLoader> createState() => _KiteLoaderState();
}

class _KiteLoaderState extends State<KiteLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loader = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  'KITE & CO.',
                  style: GoogleFonts.poppins(
                    fontSize: widget.fullScreen ? 28 : 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                    letterSpacing: widget.fullScreen ? 6 : 3,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.fullScreen ? 24 : 12),
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.black.withValues(alpha: _fadeAnimation.value),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (widget.fullScreen) {
      return Container(
        color: AppColors.white,
        child: Center(child: loader),
      );
    }
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: loader,
    ));
  }
}

class PaginationLoader extends StatelessWidget {
  const PaginationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
          ),
        ),
      ),
    );
  }
}
