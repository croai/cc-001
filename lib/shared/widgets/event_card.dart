import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../features/events/domain/event_model.dart';
import '../../shared/utils/date_formatter.dart';
import '../../shared/utils/currency_formatter.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final int? lowestPriceCents;
  final String? priceCurrency;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.lowestPriceCents,
    this.priceCurrency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image (16:9)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.coverImageUrl != null &&
                      event.coverImageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: event.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildImagePlaceholder(),
                      errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  else
                    _buildImagePlaceholder(),
                  // Category badge
                  if (event.categoryId != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.categoryId!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    formatEventDateTime(event.dateStart),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location
                  if (event.locationName != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.locationName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  // Bottom row: price + capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        lowestPriceCents != null
                            ? formatPrice(
                                lowestPriceCents!,
                                priceCurrency ?? 'EUR',
                              )
                            : '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: (lowestPriceCents ?? 0) == 0
                              ? AppColors.secondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      // Capacity
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: event.capacityPercentage,
                              strokeWidth: 3,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                event.isSoldOut
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${event.ticketsSold}/${event.maxCapacity}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: const Center(
        child: Icon(Icons.event, size: 48, color: Colors.white54),
      ),
    );
  }
}
