import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/animations/fade_slide_animation.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/bg_paper_texture.png'),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('FAQs'),
              const SizedBox(height: 16),
              _buildFAQTile(
                'How can I track my order?',
                'You can track your order in the "My Orders" section of your profile.',
              ),
              _buildFAQTile(
                'What is your return policy?',
                'We offer a 30-day return policy for all unworn and unwashed items.',
              ),
              _buildFAQTile(
                'How do I cancel my order?',
                'You can cancel your order within 2 hours of placing it from the order details page.',
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Contact Us'),
              const SizedBox(height: 16),
              _buildContactTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@kiteandco.com',
                onTap: () {},
              ),
              _buildContactTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Phone Support',
                subtitle: '+1 (800) 123-4567',
                onTap: () {},
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Follow Us'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.camera_alt_outlined),
                  const SizedBox(width: 16),
                  _buildSocialIcon(Icons.facebook_outlined),
                  const SizedBox(width: 16),
                  _buildSocialIcon(Icons.alternate_email_rounded),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FadeSlideAnimation(
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return FadeSlideAnimation(
      delay: 100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey100),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FadeSlideAnimation(
      delay: 200,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey100),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.black),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return FadeSlideAnimation(
      delay: 300,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}
