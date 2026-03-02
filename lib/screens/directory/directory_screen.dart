import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/category_chip.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kigali City')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: listingProvider.setSearchQuery,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a service...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
                suffixIcon: listingProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textHint),
                        onPressed: () => listingProvider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AppConstants.categories.map((category) {
                return CategoryChip(
                  label: category,
                  isSelected: listingProvider.selectedCategory == category,
                  onTap: () => listingProvider.setCategoryFilter(category),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Listings
          Expanded(child: _buildListingsList(context, listingProvider)),
        ],
      ),
    );
  }

  Widget _buildListingsList(BuildContext context, ListingProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final listings = provider.filteredListings;

    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            const Text(
              'No listings found',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
            if (provider.searchQuery.isNotEmpty ||
                provider.selectedCategory != null)
              TextButton(
                onPressed: () => provider.clearFilters(),
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return ListingCard(
          listing: listing,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        );
      },
    );
  }
}
