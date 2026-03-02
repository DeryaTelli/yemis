import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/home/volunteer_home_viewmodel.dart';
import '../../views/volunteer/volunteer_detail_view.dart';
import 'volunteer_listing_card.dart';

/// Yatay kaydırılabilir gönüllü ilanları bölümü.
class VolunteerListingSection extends StatelessWidget {
  const VolunteerListingSection({
    super.key,
    required this.title,
    required this.section,
  });

  final String title;
  final VolunteerSection section;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerHomeViewModel>();
    final sectionListings = vm.listings.where((l) => l.section == section).toList();

    if (sectionListings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Başlık ve "Tümü" Butonu ──────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Tümü',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.volunteerColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Yatay Liste ──────────────────────────────────
        SizedBox(
          height: 240, // İlan kartı yüksekliği
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sectionListings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final listing = sectionListings[index];
              return VolunteerListingCard(
                listing: listing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VolunteerDetailView(listing: listing),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
