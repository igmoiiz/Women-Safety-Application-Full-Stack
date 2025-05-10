class PublicWashroom {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final bool isVerified;
  final String type;
  final double rating;
  final String? description; // Added description field

  PublicWashroom({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    this.isVerified = false,
    this.type = 'public',
    this.rating = 3.5,
    this.description, // Added to constructor
  });
}
