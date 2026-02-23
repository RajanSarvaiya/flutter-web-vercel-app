import 'package:flutter/material.dart';
import '../data/models/address.dart';

class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [];
  static const int maxAddresses = 10;

  List<Address> get addresses => List.unmodifiable(_addresses);
  int get addressCount => _addresses.length;

  Address? getDefaultAddress() {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return null;
    }
  }

  void addAddress(Address address) {
    if (_addresses.length >= maxAddresses) {
      throw Exception('Maximum $maxAddresses addresses allowed');
    }
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(String addressId, Address updatedAddress) {
    final index = _addresses.indexWhere((addr) => addr.id == addressId);
    if (index != -1) {
      _addresses[index] = updatedAddress;
      notifyListeners();
    }
  }

  void deleteAddress(String addressId) {
    _addresses.removeWhere((addr) => addr.id == addressId);
    notifyListeners();
  }

  void setDefaultAddress(String addressId) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == addressId,
      );
    }
    notifyListeners();
  }

  Address? getAddressById(String addressId) {
    try {
      return _addresses.firstWhere((addr) => addr.id == addressId);
    } catch (e) {
      return null;
    }
  }
}
