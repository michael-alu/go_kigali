import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';
import 'add_listing_screen.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userListings = listingProvider.userListings;

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: userListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_business, size: 64, color: AppTheme.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'You have no listings yet',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add a new place or service',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: userListings.length,
              itemBuilder: (context, index) {
                final listing = userListings[index];
                return Dismissible(
                  key: Key(listing.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.primaryMedium,
                        title: const Text('Delete Listing'),
                        content: Text(
                          'Are you sure you want to delete "${listing.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: AppTheme.errorRed),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    final success = await listingProvider.deleteListing(
                      listing.id,
                    );
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete listing'),
                        ),
                      );
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: AppTheme.errorRed),
                  ),
                  child: ListingCard(
                    listing: listing,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ListingDetailScreen(listing: listing),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit button for first listing (quick access)
          if (userListings.isNotEmpty)
            FloatingActionButton.small(
              heroTag: 'edit',
              backgroundColor: AppTheme.primaryLight,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditListingScreen(listing: userListings.first),
                  ),
                );
              },
              child: const Icon(Icons.edit, color: AppTheme.accentGold),
            ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddListingScreen(userId: authProvider.currentUser!.uid),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
