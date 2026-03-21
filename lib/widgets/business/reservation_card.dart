import 'package:flutter/material.dart';
import '../../models/business/reservation_model.dart';
import 'food_image.dart';
import 'info_banner.dart';
import 'customer_row.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final bool isApproved;
  final bool isRejected;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.isApproved,
    required this.isRejected,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Yemek Fotoğrafı ─────────────────────────────
          FoodImage(imageUrl: reservation.foodImageUrl),

          // ── Tarih / Saat bandı ───────────────────────────
          InfoBanner(reservation: reservation),

          // ── Müşteri + Butonlar ───────────────────────────
          CustomerRow(
            reservation: reservation,
            isApproved: isApproved,
            isRejected: isRejected,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ],
      ),
    );
  }
}
