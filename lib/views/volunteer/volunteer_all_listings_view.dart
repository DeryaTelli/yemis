import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../widgets/volunteer/volunteer_listing_card.dart';
import 'volunteer_detail_view.dart';

class VolunteerAllListingsView extends StatelessWidget {
  final String title;
  final List<VolunteerListing> listings;

  const VolunteerAllListingsView({
    super.key,
    required this.title,
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(title)),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: listings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = listings[index];
            return VolunteerListingCard(
              listing: item,
              width: double.infinity,
              imageHeight: 160,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VolunteerDetailView(listing: item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
