import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_shimmer.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        actions: [
          // Show listing count badge
          if (listingProvider.filteredListings.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${listingProvider.filteredListings.length}',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
      return const LoadingShimmer();
    }

    if (provider.error != null) {
      return const ErrorStateWidget(
        icon: Icons.error_outline,
        message: 'Something went wrong',
        subtitle: 'Could not load the directory. Please try again.',
      );
    }

    final listings = provider.filteredListings;

    if (listings.isEmpty) {
      return ErrorStateWidget(
        icon: Icons.search_off,
        message: 'No listings found',
        subtitle:
            provider.searchQuery.isNotEmpty || provider.selectedCategory != null
            ? 'Try adjusting your filters'
            : 'Be the first to add a listing!',
        onRetry:
            provider.searchQuery.isNotEmpty || provider.selectedCategory != null
            ? () => provider.clearFilters()
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ListingCard(
            key: ValueKey(listing.id),
            listing: listing,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListingDetailScreen(listing: listing),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
