import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme.dart';
import '../../../shared/utils/date_formatter.dart';
import 'tickets_provider.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));

    return ticketAsync.when(
      data: (ticket) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Your Ticket'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            ticket.attendeeName.isNotEmpty
                                ? ticket.attendeeName
                                : 'Attendee',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatEventDate(ticket.purchasedAt),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Perforation with semicircle cutouts
                    SizedBox(
                      height: 24,
                      child: Stack(
                        children: [
                          // Dashed line
                          Center(
                            child: Row(
                              children: List.generate(
                                40,
                                (_) => Expanded(
                                  child: Container(
                                    height: 1.5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Left cutout
                          Positioned(
                            left: -12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Right cutout
                          Positioned(
                            right: -12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // QR Code section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        children: [
                          // QR Code
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: ticket.qrCode,
                              version: QrVersions.auto,
                              size: 200,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.primary,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.primary,
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Ticket number
                          Text(
                            ticket.ticketNumber,
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Info rows
                          _InfoRow(
                            label: 'Attendee',
                            value: ticket.attendeeName,
                          ),
                          _InfoRow(
                            label: 'Ticket Type',
                            value: ticket.ticketTypeId,
                          ),
                          _InfoRow(
                            label: 'Status',
                            value: ticket.status.toUpperCase(),
                            valueColor: ticket.isValid
                                ? AppColors.secondary
                                : ticket.isUsed
                                ? AppColors.textSecondary
                                : AppColors.error,
                          ),
                          _InfoRow(
                            label: 'Order',
                            value: ticket.orderId.substring(0, 8),
                          ),
                          if (ticket.isUsed && ticket.usedAt != null)
                            _InfoRow(
                              label: 'Used at',
                              value: formatEventDateTime(ticket.usedAt!),
                            ),
                          const SizedBox(height: 20),
                          // Share button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share coming soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Share Ticket'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Show this QR code at the entrance',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
