import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../app/theme.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../domain/ticket_type_model.dart';
import 'events_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final ticketTypesAsync = ref.watch(ticketTypesProvider(eventId));

    return eventAsync.when(
      data: (event) {
        final ticketTypes = ticketTypesAsync.valueOrNull ?? [];
        final lowestPrice = ticketTypes.isEmpty
            ? null
            : ticketTypes
                  .where((t) => t.isOnSale)
                  .fold<int?>(
                    null,
                    (min, t) => min == null || t.priceAmount < min
                        ? t.priceAmount
                        : min,
                  );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Hero image
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: event.coverImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: event.coverImageUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      _buildImagePlaceholder(),
                                )
                              : _buildImagePlaceholder(),
                        ),
                        // Gradient overlays
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Back & share buttons
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          child: _CircleButton(
                            icon: Icons.arrow_back,
                            onTap: () => context.pop(),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 16,
                          child: _CircleButton(icon: Icons.share, onTap: () {}),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Status badge
                        if (!event.isPublished)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: event.isCancelled
                                      ? AppColors.error.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event.status.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: event.isCancelled
                                        ? AppColors.error
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Title
                        Text(
                          event.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Organizer (placeholder)
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'by ${event.organizationId}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Details section
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          title: formatEventDate(event.dateStart),
                          subtitle: formatDateRange(
                            event.dateStart,
                            event.dateEnd,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (event.isOnline)
                          _DetailRow(
                            icon: Icons.link,
                            title: 'Online event',
                            subtitle: event.onlineUrl ?? '',
                          )
                        else if (event.locationName != null)
                          _DetailRow(
                            icon: Icons.place_outlined,
                            title: event.locationName!,
                            subtitle: event.locationAddress ?? '',
                          ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.people_outline,
                          title:
                              '${event.ticketsSold} / ${event.maxCapacity} attending',
                          customWidget: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: event.capacityPercentage,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ),
                        if (lowestPrice != null) ...[
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.confirmation_number_outlined,
                            title:
                                'Starting from ${formatPrice(lowestPrice, 'EUR')}',
                          ),
                        ],
                        const SizedBox(height: 28),
                        // About section
                        if (event.description != null &&
                            event.description!.isNotEmpty) ...[
                          Text(
                            'About',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                        // Ticket types section
                        Text(
                          'Tickets',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...ticketTypes.map(
                          (tt) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TicketTypeCard(ticketType: tt),
                          ),
                        ),
                        if (ticketTypes.isEmpty)
                          ticketTypesAsync.when(
                            data: (_) => Text(
                              'No ticket types available',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            loading: () => const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, _) => Text('Error: $e'),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
              // Sticky bottom bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lowestPrice != null
                                ? formatPrice(lowestPrice, 'EUR')
                                : '—',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'per ticket',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 180,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: event.isSoldOut
                              ? null
                              : () => context.push('/event/$eventId/purchase'),
                          child: Text(
                            event.isSoldOut ? 'Sold Out' : 'Get Tickets',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
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
        child: Icon(Icons.event, size: 64, color: Colors.white54),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? customWidget;

  const _DetailRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              if (customWidget != null) customWidget!,
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketTypeCard extends StatelessWidget {
  final TicketTypeModel ticketType;

  const _TicketTypeCard({required this.ticketType});

  @override
  Widget build(BuildContext context) {
    final isSoldOut = ticketType.isSoldOut;

    return Opacity(
      opacity: isSoldOut ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticketType.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  isSoldOut ? 'Rasprodano' : ticketType.formattedPrice,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSoldOut ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
            if (ticketType.description != null) ...[
              const SizedBox(height: 4),
              Text(
                ticketType.description!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (!isSoldOut) ...[
              const SizedBox(height: 6),
              Text(
                '${ticketType.remaining} remaining',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
