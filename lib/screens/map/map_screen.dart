import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../directory/listing_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  /// Launch navigation to a specific listing
  Future<void> _launchNavigation(ListingModel listing) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Get category-based marker color
  Color _getMarkerColor(String category) {
    switch (category) {
      case 'Hospital':
        return Colors.redAccent;
      case 'Police Station':
        return Colors.blueAccent;
      case 'Library':
        return Colors.teal;
      case 'Restaurant':
        return Colors.orange;
      case 'Café':
        return Colors.brown;
      case 'Park':
        return Colors.green;
      case 'Tourist Attraction':
        return Colors.purple;
      case 'Utility Office':
        return Colors.grey;
      default:
        return AppTheme.accentGold;
    }
  }

  /// Get category icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Police Station':
        return Icons.local_police;
      case 'Library':
        return Icons.menu_book;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.coffee;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.camera_alt;
      case 'Utility Office':
        return Icons.business;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final listings = listingProvider.filteredListings;
    final kigaliCenter = LatLng(AppConstants.kigaliLat, AppConstants.kigaliLng);

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: listings.isEmpty
          ? const Center(
              child: Text(
                'No listings to display on map',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: kigaliCenter,
                initialZoom: 13.0,
              ),
              children: [
                // Dark-themed CartoDB tile layer
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.go_kigali',
                  maxZoom: 20,
                  retinaMode: true,
                ),
                // Custom styled markers
                MarkerLayer(
                  markers: listings.map((listing) {
                    final color = _getMarkerColor(listing.category);
                    final icon = _getCategoryIcon(listing.category);
                    return Marker(
                      point: LatLng(listing.latitude, listing.longitude),
                      width: 44,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          _showListingBottomSheet(context, listing);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: Colors.white, size: 18),
                            ),
                            // Drop arrow pointer
                            Icon(Icons.arrow_drop_down, color: color, size: 14),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  /// Show a bottom sheet with listing info when a marker is tapped
  void _showListingBottomSheet(BuildContext context, ListingModel listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.primaryMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  listing.category,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Name
              Text(
                listing.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Address
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppTheme.textHint,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      listing.address,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListingDetailScreen(listing: listing),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchNavigation(listing),
                      icon: const Icon(Icons.directions),
                      label: const Text('Navigate'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
