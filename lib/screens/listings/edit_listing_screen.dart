import 'package:flutter/material.dart';
import '../../models/listing_model.dart';

/// Placeholder edit screen - will be fully implemented in the next commit
class EditListingScreen extends StatelessWidget {
  final ListingModel listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: const Center(
        child: Text(
          'Edit Listing - Coming Soon',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
