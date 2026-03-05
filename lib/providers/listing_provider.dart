import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();

  // ── State Variables ──
  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];

  bool _isLoading = false;
  String? _error;

  // Search & Filter State
  String _searchQuery = '';
  String? _selectedCategory;

  StreamSubscription? _allListingsSub;
  StreamSubscription? _userListingsSub;

  // ── Getters ──
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  /// Returns all listings filtered by search query and selected category
  List<ListingModel> get filteredListings {
    return _allListings.where((listing) {
      final matchesSearch = listing.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Returns the authenticated user's listings
  List<ListingModel> get userListings => _userListings;

  // ── Initialization ──

  /// Start listening to all listings from Firestore
  void initDirectory() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _allListingsSub?.cancel();
    _allListingsSub = _listingService.getAllListings().listen(
      (listings) {
        _allListings = listings;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load directory. Please try again.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Start listening to user-specific listings from Firestore
  void initUserListings(String userId) {
    _error = null;
    _userListingsSub?.cancel();
    _userListingsSub = _listingService
        .getUserListings(userId)
        .listen(
          (listings) {
            _userListings = listings;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Failed to load your listings.';
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _allListingsSub?.cancel();
    _userListingsSub?.cancel();
    super.dispose();
  }

  // ── Filters ──

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // Toggle off if tapped again
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // ── CRUD Operations ──

  Future<bool> createListing(ListingModel listing) async {
    _setLoading(true);
    _clearError();
    try {
      await _listingService.createListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create listing. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    _clearError();
    try {
      await _listingService.updateListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update listing. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    _setLoading(true);
    _clearError();
    try {
      await _listingService.deleteListing(listingId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete listing. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ── Helpers ──

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
