import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/animations/fade_slide_animation.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../data/models/address.dart';
import '../../../data/models/order.dart';
import '../profile/widgets/add_address_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _selectedAddress;
  String _selectedPaymentMethod = 'UPI';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Set default address if available
    final addressProvider = context.read<AddressProvider>();
    if (addressProvider.addresses.isNotEmpty) {
      _selectedAddress = addressProvider.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addressProvider.addresses.first,
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Mock processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final items = cart.items.map((item) => OrderItem(
      productId: item.product.id,
      productName: item.product.name,
      productImage: item.product.images.first,
      quantity: item.quantity,
      price: item.product.price,
      size: item.selectedSize,
      color: item.selectedColor,
    )).toList();

    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      status: OrderStatus.pending,
      items: items,
      totalAmount: cart.total + (cart.subtotal >= 2000 ? 0 : 149),
      shippingAddressId: _selectedAddress!.id,
    );

    orderProvider.addOrder(order);
    cart.clear();

    setState(() => _isProcessing = false);

    // Navigate to orders screen or a success screen
    context.go('/profile/orders');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final shipping = cart.subtotal >= 2000 ? 0.0 : 149.0;
    final total = cart.total + shipping;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: AppColors.black))
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_paper_texture.png'),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Shipping Address'),
                    const SizedBox(height: 16),
                    _buildAddressCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 16),
                    _buildPaymentMethods(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Order Summary'),
                    const SizedBox(height: 16),
                    _buildOrderSummary(cart, shipping, total),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'PLACE ORDER',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedAddress != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedAddress!.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final result = await context.push<Address>(
                          '/select-address',
                        );
                        if (result != null) {
                          setState(() => _selectedAddress = result);
                        }
                      },
                      child: Text(
                        'Change',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<Address>(
                          context: context,
                          builder: (context) => AddAddressDialog(),
                        );
                        if (result != null) {
                          setState(() => _selectedAddress = result);
                        }
                      },
                      child: Text(
                        '+ Add New',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_selectedAddress!.houseNumber}, ${_selectedAddress!.apartment}\n${_selectedAddress!.city}, ${_selectedAddress!.state} ${_selectedAddress!.pincode}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedAddress!.contactNumber,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else
            Consumer<AddressProvider>(
              builder: (context, addressProvider, _) {
                final hasAddresses = addressProvider.addresses.isNotEmpty;
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasAddresses) ...[
                        TextButton.icon(
                          onPressed: () async {
                            final result = await context.push<Address>(
                              '/select-address',
                            );
                            if (result != null) {
                              setState(() => _selectedAddress = result);
                            }
                          },
                          icon: const Icon(Icons.location_on_outlined, color: AppColors.black),
                          label: Text(
                            'Select Address',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      TextButton.icon(
                        onPressed: () async {
                          final result = await showDialog<Address>(
                            context: context,
                            builder: (context) => AddAddressDialog(),
                          );
                          if (result != null) {
                            setState(() => _selectedAddress = result);
                          }
                        },
                        icon: const Icon(Icons.add_rounded, color: AppColors.black),
                        label: Text(
                          'Add New',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 'UPI', 'name': 'UPI (PhonePe, GPay)', 'icon': Icons.account_balance_wallet_outlined},
      {'id': 'CARD', 'name': 'Credit / Debit Card', 'icon': Icons.credit_card_outlined},
      {'id': 'COD', 'name': 'Cash on Delivery', 'icon': Icons.payments_outlined},
    ];

    return Column(
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = method['id'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.black : AppColors.grey200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  method['icon'] as IconData,
                  color: isSelected ? AppColors.white : AppColors.grey600,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  method['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.white, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '\u20B9${cart.subtotal.toInt()}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Shipping', shipping == 0 ? 'FREE' : '\u20B9${shipping.toInt()}',
              isGreen: shipping == 0),
          if (cart.totalSavings > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('Discount', '-\u20B9${cart.totalSavings.toInt()}', isGreen: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.grey200),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isGreen ? AppColors.success : AppColors.black,
          ),
        ),
      ],
    );
  }
}
