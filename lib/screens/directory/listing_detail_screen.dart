import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../listings/edit_listing_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  Future<void> _launchNavigation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = LatLng(listing.latitude, listing.longitude);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.currentUser?.uid == listing.createdBy;

    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              backgroundColor: AppTheme.accentGold,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditListingScreen(listing: listing),
                  ),
                );
              },
              child: const Icon(Icons.edit, color: AppTheme.primaryDark),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(initialCenter: location, initialZoom: 15.0),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.go_kigali',
                    maxZoom: 20,
                    retinaMode: true,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 44,
                        height: 50,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.place,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.accentGold,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      listing.category,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    listing.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    listing.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Divider(),
                  const SizedBox(height: 16),

                  _buildInfoRow(Icons.location_on, 'Address', listing.address),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.phone, 'Contact', listing.contactNumber),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    Icons.my_location,
                    'Coordinates',
                    '${listing.latitude.toStringAsFixed(4)}, ${listing.longitude.toStringAsFixed(4)}',
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _launchNavigation,
                      icon: const Icon(Icons.directions),
                      label: const Text('GET DIRECTIONS'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
