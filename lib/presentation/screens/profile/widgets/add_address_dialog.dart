import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/address.dart';
import '../../../../providers/address_provider.dart';
import '../../../../core/services/location_service.dart';

class AddAddressDialog extends StatefulWidget {
  final Address? addressToEdit;

  const AddAddressDialog({
    super.key,
    this.addressToEdit,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _houseNumberController;
  late TextEditingController _apartmentController;
  late TextEditingController _pincodeController;
  late TextEditingController _contactNumberController;

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  List<String> _countries = [];
  List<String> _states = [];
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _countries = LocationService.getCountries();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.addressToEdit != null) {
      _firstNameController = TextEditingController(text: widget.addressToEdit!.firstName);
      _lastNameController = TextEditingController(text: widget.addressToEdit!.lastName);
      _houseNumberController = TextEditingController(text: widget.addressToEdit!.houseNumber);
      _apartmentController = TextEditingController(text: widget.addressToEdit!.apartment);
      _pincodeController = TextEditingController(text: widget.addressToEdit!.pincode);
      _contactNumberController = TextEditingController(text: widget.addressToEdit!.contactNumber);
      
      _selectedCountry = widget.addressToEdit!.country;
      _states = LocationService.getStates(_selectedCountry!);
      
      _selectedState = widget.addressToEdit!.state;
      _cities = LocationService.getCities(_selectedCountry!, _selectedState!);
      
      _selectedCity = widget.addressToEdit!.city;
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _houseNumberController = TextEditingController();
      _apartmentController = TextEditingController();
      _pincodeController = TextEditingController();
      _contactNumberController = TextEditingController();
    }

    _pincodeController.addListener(_onPincodeChanged);
  }

  void _onPincodeChanged() {
    final pincode = _pincodeController.text;
    if (pincode.length >= 5) {
      final data = LocationService.lookupPincode(pincode);
      if (data != null) {
        setState(() {
          _selectedCountry = data.country;
          _states = LocationService.getStates(_selectedCountry!);
          _selectedState = data.state;
          _cities = LocationService.getCities(_selectedCountry!, _selectedState!);
          _selectedCity = data.city;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _houseNumberController.dispose();
    _apartmentController.dispose();
    _pincodeController.removeListener(_onPincodeChanged);
    _pincodeController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null || _selectedState == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Country, State and City')),
      );
      return;
    }

    final addressProvider = context.read<AddressProvider>();
    final address = Address(
      id: widget.addressToEdit?.id ?? const Uuid().v4(),
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      country: _selectedCountry!,
      state: _selectedState!,
      city: _selectedCity!,
      houseNumber: _houseNumberController.text,
      apartment: _apartmentController.text,
      pincode: _pincodeController.text,
      contactNumber: _contactNumberController.text,
    );

    if (widget.addressToEdit != null) {
      addressProvider.updateAddress(widget.addressToEdit!.id, address);
    } else {
      addressProvider.addAddress(address);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.addressToEdit != null ? 'Edit Address' : 'Add New Address',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'First Name',
                        _firstNameController,
                        Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Last Name',
                        _lastNameController,
                        Icons.person_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Contact Number',
                  _contactNumberController,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Pincode (Auto-fills Location)',
                  _pincodeController,
                  Icons.mail_outline,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  'Country',
                  _selectedCountry,
                  _countries,
                  (val) {
                    setState(() {
                      _selectedCountry = val;
                      _states = LocationService.getStates(val!);
                      _selectedState = null;
                      _cities = [];
                      _selectedCity = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'State',
                        _selectedState,
                        _states,
                        (val) {
                          setState(() {
                            _selectedState = val;
                            _cities = LocationService.getCities(_selectedCountry!, val!);
                            _selectedCity = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        'City',
                        _selectedCity,
                        _cities,
                        (val) => setState(() => _selectedCity = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'House/Flat Number',
                  _houseNumberController,
                  Icons.home_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Apartment, Suite, etc.',
                  _apartmentController,
                  Icons.apartment_outlined,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.addressToEdit != null ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, color: AppColors.grey400, size: 20),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: (value) => value == null ? 'Required' : null,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
