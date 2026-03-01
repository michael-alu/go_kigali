class AppConstants {
  // ── Kigali Default Coordinates ──
  static const double kigaliLat = -1.9403;
  static const double kigaliLng = 29.8739;

  // ── Listing Categories ──
  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Utility Office',
  ];

  // ── Firestore Collection Names ──
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';
}
