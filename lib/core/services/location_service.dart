class LocationData {
  final String city;
  final String state;
  final String country;

  LocationData({
    required this.city,
    required this.state,
    required this.country,
  });
}

class LocationService {
  // Mock data for dependent dropdowns
  static const Map<String, Map<String, List<String>>> locationHierarchy = {
    'India': {
      'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
      'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane'],
      'Delhi': ['New Delhi', 'North Delhi', 'South Delhi'],
    },
    'USA': {
      'California': ['Los Angeles', 'San Francisco', 'San Diego'],
      'New York': ['New York City', 'Buffalo', 'Rochester'],
      'Texas': ['Houston', 'Austin', 'Dallas'],
    },
    'UK': {
      'England': ['London', 'Manchester', 'Birmingham'],
      'Scotland': ['Glasgow', 'Edinburgh', 'Aberdeen'],
    },
  };

  // Mock data for pincode lookup
  static final Map<String, LocationData> _pincodeMap = {
    '380001': LocationData(city: 'Ahmedabad', state: 'Gujarat', country: 'India'),
    '400001': LocationData(city: 'Mumbai', state: 'Maharashtra', country: 'India'),
    '110001': LocationData(city: 'New Delhi', state: 'Delhi', country: 'India'),
    '90001': LocationData(city: 'Los Angeles', state: 'California', country: 'USA'),
    '10001': LocationData(city: 'New York City', state: 'New York', country: 'USA'),
    'SW1A': LocationData(city: 'London', state: 'England', country: 'UK'),
  };

  static List<String> getCountries() {
    return locationHierarchy.keys.toList();
  }

  static List<String> getStates(String country) {
    if (locationHierarchy.containsKey(country)) {
      return locationHierarchy[country]!.keys.toList();
    }
    return [];
  }

  static List<String> getCities(String country, String state) {
    if (locationHierarchy.containsKey(country) &&
        locationHierarchy[country]!.containsKey(state)) {
      return locationHierarchy[country]![state]!;
    }
    return [];
  }

  static LocationData? lookupPincode(String pincode) {
    // In a real app, this would be an API call
    return _pincodeMap[pincode];
  }
}
