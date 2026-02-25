import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme.dart';
import '../../auth/presentation/auth_provider.dart';

import '../../tickets/presentation/tickets_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  final String eventId;
  const QrScannerScreen({super.key, required this.eventId});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  late MobileScannerController _controller;
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  int _scannedCount = 0;

  // Overlay state
  _ScanResult? _currentResult;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final qrCode = barcode.rawValue!;

    // Debounce: skip if same code scanned within 3 seconds
    if (_lastScannedCode == qrCode &&
        _lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) <
            const Duration(seconds: 3)) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastScannedCode = qrCode;
      _lastScanTime = DateTime.now();
    });

    try {
      final ticketRepo = ref.read(ticketRepositoryProvider);
      final user = ref.read(currentUserProvider);
      final userId = user?.uid ?? 'unknown';

      // Look up ticket by QR code
      final ticket = await ticketRepo.getTicketByQrCode(qrCode);

      if (ticket == null) {
        // Invalid ticket
        HapticFeedback.heavyImpact();
        await ticketRepo.createScanRecord(
          ticketId: 'unknown',
          scannedBy: userId,
          result: 'rejected_invalid',
        );
        _showResult(
          _ScanResult(
            isSuccess: false,
            title: 'Invalid Ticket',
            subtitle: 'QR code not recognized',
          ),
        );
        return;
      }

      // Check event match
      if (ticket.eventId != widget.eventId) {
        HapticFeedback.heavyImpact();
        await ticketRepo.createScanRecord(
          ticketId: ticket.id,
          scannedBy: userId,
          result: 'rejected_wrong_event',
        );
        _showResult(
          _ScanResult(
            isSuccess: false,
            title: 'Wrong Event',
            subtitle: 'This ticket is for a different event',
          ),
        );
        return;
      }

      // Check status
      if (ticket.isUsed) {
        HapticFeedback.heavyImpact();
        await ticketRepo.createScanRecord(
          ticketId: ticket.id,
          scannedBy: userId,
          result: 'rejected_already_used',
        );
        _showResult(
          _ScanResult(
            isSuccess: false,
            title: 'Already Used',
            subtitle:
                'Scanned at ${ticket.usedAt?.toLocal().toString().substring(0, 16) ?? "earlier"}',
          ),
        );
        return;
      }

      if (ticket.isCancelled) {
        HapticFeedback.heavyImpact();
        await ticketRepo.createScanRecord(
          ticketId: ticket.id,
          scannedBy: userId,
          result: 'rejected_cancelled',
        );
        _showResult(
          _ScanResult(
            isSuccess: false,
            title: 'Cancelled',
            subtitle: 'This ticket has been cancelled',
          ),
        );
        return;
      }

      // All good — mark as used (this also creates the scan record)
      HapticFeedback.mediumImpact();
      await ticketRepo.markTicketAsUsed(ticket.id, userId);
      setState(() => _scannedCount++);
      _showResult(
        _ScanResult(
          isSuccess: true,
          title: 'Admitted ✓',
          subtitle: '${ticket.attendeeName}\n${ticket.ticketNumber}',
        ),
      );
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showResult(
        _ScanResult(isSuccess: false, title: 'Error', subtitle: e.toString()),
      );
    }
  }

  void _showResult(_ScanResult result) {
    setState(() => _currentResult = result);

    // Auto-dismiss
    final duration = result.isSuccess
        ? const Duration(seconds: 2)
        : const Duration(seconds: 3);
    Future.delayed(duration, () {
      if (mounted) {
        setState(() {
          _currentResult = null;
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(controller: _controller, onDetect: _handleBarcode),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                8,
                MediaQuery.of(context).padding.top + 8,
                8,
                12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Scan Tickets',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Event: ${widget.eventId.substring(0, 8)}...',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _controller.toggleTorch(),
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Scanning frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner brackets
                  ..._buildCornerBrackets(),
                ],
              ),
            ),
          ),
          // Dark overlay outside scanning area
          // Instruction text
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35 + 20,
            left: 0,
            right: 0,
            child: Text(
              'Point camera at QR code',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
          ),
          // Bottom panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scanned: $_scannedCount',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manual lookup coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Manual Lookup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Result overlay
          if (_currentResult != null) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    final result = _currentResult!;
    final color = result.isSuccess ? AppColors.secondary : AppColors.error;

    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: color.withValues(alpha: 0.9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (_, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Icon(
                    result.isSuccess ? Icons.check_rounded : Icons.close,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  result.title,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 32.0;
    const thickness = 3.0;
    const color = Colors.white;
    const radius = Radius.circular(4);

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: size,
          height: thickness,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(topLeft: radius),
          ),
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: thickness,
          height: size,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(topLeft: radius),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: size,
          height: thickness,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(topRight: radius),
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: thickness,
          height: size,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(topRight: radius),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: thickness,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(bottomLeft: radius),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: thickness,
          height: size,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(bottomLeft: radius),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: thickness,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(bottomRight: radius),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: thickness,
          height: size,
          decoration: const BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(bottomRight: radius),
          ),
        ),
      ),
    ];
  }
}

class _ScanResult {
  final bool isSuccess;
  final String title;
  final String subtitle;

  const _ScanResult({
    required this.isSuccess,
    required this.title,
    required this.subtitle,
  });
}
