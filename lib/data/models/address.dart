class Address {
  final String id;
  final String firstName;
  final String lastName;
  final String country;
  final String state;
  final String city;
  final String houseNumber;
  final String apartment;
  final String pincode;
  final String contactNumber;
  final bool isDefault;

  Address({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.state,
    required this.city,
    required this.houseNumber,
    required this.apartment,
    required this.pincode,
    required this.contactNumber,
    this.isDefault = false,
  });

  // Copy with method for updating
  Address copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? country,
    String? state,
    String? city,
    String? houseNumber,
    String? apartment,
    String? pincode,
    String? contactNumber,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      houseNumber: houseNumber ?? this.houseNumber,
      apartment: apartment ?? this.apartment,
      pincode: pincode ?? this.pincode,
      contactNumber: contactNumber ?? this.contactNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'state': state,
      'city': city,
      'houseNumber': houseNumber,
      'apartment': apartment,
      'pincode': pincode,
      'contactNumber': contactNumber,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      country: map['country'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      houseNumber: map['houseNumber'] ?? '',
      apartment: map['apartment'] ?? '',
      pincode: map['pincode'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  // Get full address as string
  String get fullAddress {
    return '$houseNumber, $apartment, $city, $state $pincode, $country';
  }

  // Get full name
  String get fullName {
    return '$firstName $lastName';
  }
}
