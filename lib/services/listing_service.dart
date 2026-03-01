import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../utils/constants.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a real-time stream of all listings ordered by timestamp descending
  Stream<List<ListingModel>> getAllListings() {
    return _firestore
        .collection(AppConstants.listingsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get a real-time stream of listings created by a specific user (My Listings)
  Stream<List<ListingModel>> getUserListings(String userId) {
    return _firestore
        .collection(AppConstants.listingsCollection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Create a new listing
  Future<void> createListing(ListingModel listing) async {
    await _firestore
        .collection(AppConstants.listingsCollection)
        .add(listing.toMap());
  }

  /// Update an existing listing
  Future<void> updateListing(ListingModel listing) async {
    await _firestore
        .collection(AppConstants.listingsCollection)
        .doc(listing.id)
        .update(listing.toMap());
  }

  /// Delete a listing by ID
  Future<void> deleteListing(String listingId) async {
    await _firestore
        .collection(AppConstants.listingsCollection)
        .doc(listingId)
        .delete();
  }
}
