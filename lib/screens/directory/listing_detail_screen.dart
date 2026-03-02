import 'package:flutter/material.dart';
import '../../models/listing_model.dart';

/// Placeholder detail screen - will be fully implemented in a later commit
class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      body: const Center(
        child: Text(
          'Detail Page - Coming Soon',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
