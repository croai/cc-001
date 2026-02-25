import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/exceptions.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../events/presentation/events_provider.dart';
import '../../events/domain/ticket_type_model.dart';
import 'tickets_provider.dart';

class PurchaseFlowScreen extends ConsumerStatefulWidget {
  final String eventId;
  const PurchaseFlowScreen({super.key, required this.eventId});

  @override
  ConsumerState<PurchaseFlowScreen> createState() => _PurchaseFlowScreenState();
}

class _PurchaseFlowScreenState extends ConsumerState<PurchaseFlowScreen> {
  final Map<String, int> _quantities = {};
  bool _isConfirmPhase = false;
  bool _isPurchasing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  int _totalQuantity() => _quantities.values.fold(0, (sum, q) => sum + q);

  int _totalPrice(List<TicketTypeModel> types) {
    int total = 0;
    for (final tt in types) {
      total += (_quantities[tt.id] ?? 0) * tt.priceAmount;
    }
    return total;
  }

  Future<void> _confirmPurchase(List<TicketTypeModel> types) async {
    setState(() => _isPurchasing = true);
    try {
      final ticketRepo = ref.read(ticketRepositoryProvider);
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Not authenticated');

      // Purchase for each ticket type with quantity > 0
      for (final tt in types) {
        final qty = _quantities[tt.id] ?? 0;
        if (qty <= 0) continue;

        await ticketRepo.purchaseTickets(
          userId: user.uid,
          eventId: widget.eventId,
          ticketTypeId: tt.id,
          quantity: qty,
          attendeeName: _nameController.text,
          attendeeEmail: _emailController.text,
        );
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } on CapacityExceededException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
        // Refresh ticket types
        ref.invalidate(ticketTypesProvider(widget.eventId));
        setState(() => _isConfirmPhase = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Purchase Complete! 🎉',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your tickets are ready.\nCheck "My Tickets" to view them.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.context.go('/my-tickets');
                  },
                  child: const Text('View My Tickets'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final ticketTypesAsync = ref.watch(ticketTypesProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isConfirmPhase ? 'Confirm Order' : 'Select Tickets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isConfirmPhase) {
              setState(() => _isConfirmPhase = false);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: eventAsync.when(
        data: (event) {
          return ticketTypesAsync.when(
            data: (ticketTypes) {
              if (_isConfirmPhase) {
                return _buildConfirmPhase(ticketTypes);
              }
              return _buildSelectionPhase(ticketTypes);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSelectionPhase(List<TicketTypeModel> ticketTypes) {
    final total = _totalPrice(ticketTypes);
    final qty = _totalQuantity();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Choose your tickets',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...ticketTypes.map(
                (tt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TicketTypeSelector(
                    ticketType: tt,
                    quantity: _quantities[tt.id] ?? 0,
                    onChanged: (q) => setState(() => _quantities[tt.id] = q),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom bar
        Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatPrice(total, 'EUR'),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$qty ticket${qty != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 160,
                height: 50,
                child: ElevatedButton(
                  onPressed: qty > 0
                      ? () => setState(() => _isConfirmPhase = true)
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPhase(List<TicketTypeModel> ticketTypes) {
    final selectedTypes = ticketTypes
        .where((tt) => (_quantities[tt.id] ?? 0) > 0)
        .toList();
    final total = _totalPrice(ticketTypes);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Order Summary',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Line items
              ...selectedTypes.map((tt) {
                final qty = _quantities[tt.id] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$qty× ${tt.name}',
                        style: GoogleFonts.inter(fontSize: 15),
                      ),
                      Text(
                        formatPrice(tt.priceAmount * qty, 'EUR'),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatPrice(total, 'EUR'),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Attendee info
              Text(
                'Attendee Information',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        // Confirm button
        Container(
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
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPurchasing
                  ? null
                  : () => _confirmPurchase(selectedTypes),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      total == 0 ? 'Confirm Registration' : 'Confirm Purchase',
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketTypeSelector extends StatelessWidget {
  final TicketTypeModel ticketType;
  final int quantity;
  final ValueChanged<int> onChanged;

  const _TicketTypeSelector({
    required this.ticketType,
    required this.quantity,
    required this.onChanged,
  });

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
          border: Border.all(
            color: quantity > 0 ? AppColors.primary : AppColors.border,
            width: quantity > 0 ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticketType.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSoldOut ? 'Rasprodano' : ticketType.formattedPrice,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSoldOut
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSoldOut)
                  Row(
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap: quantity > 0
                            ? () => onChanged(quantity - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: quantity < ticketType.maxPerOrder
                            ? () => onChanged(quantity + 1)
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
            if (ticketType.description != null) ...[
              const SizedBox(height: 6),
              Text(
                ticketType.description!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (!isSoldOut) ...[
              const SizedBox(height: 4),
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

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.textPrimary : AppColors.inputBorder,
        ),
      ),
    );
  }
}
