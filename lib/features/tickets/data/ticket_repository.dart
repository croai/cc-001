import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../domain/ticket_model.dart';
import '../domain/order_model.dart';
import '../../scanner/domain/ticket_scan_model.dart';
import '../../../shared/utils/exceptions.dart';

class TicketRepository {
  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  TicketRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Atomically purchase tickets using a Firestore Transaction.
  /// Prevents overselling by verifying capacity inside the transaction.
  Future<OrderModel> purchaseTickets({
    required String userId,
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required String attendeeName,
    required String attendeeEmail,
  }) async {
    return _firestore.runTransaction<OrderModel>((transaction) async {
      // a) Read ticket type inside transaction
      final ttDoc = await transaction.get(
        _firestore.collection('ticket_types').doc(ticketTypeId),
      );
      if (!ttDoc.exists) throw Exception('Ticket type not found');

      final ttData = ttDoc.data()!;
      final quantitySold = ttData['quantitySold'] as int? ?? 0;
      final quantityTotal = ttData['quantityTotal'] as int? ?? 0;

      // b) Verify ticket type capacity
      if (quantitySold + quantity > quantityTotal) {
        throw const CapacityExceededException('This ticket type is sold out.');
      }

      // c) Read event and verify event capacity
      final eventDoc = await transaction.get(
        _firestore.collection('events').doc(eventId),
      );
      if (!eventDoc.exists) throw Exception('Event not found');

      final eventData = eventDoc.data()!;
      final ticketsSold = eventData['ticketsSold'] as int? ?? 0;
      final maxCapacity = eventData['maxCapacity'] as int? ?? 0;

      if (ticketsSold + quantity > maxCapacity) {
        throw const CapacityExceededException('Event capacity exceeded.');
      }

      final priceAmount = ttData['priceAmount'] as int? ?? 0;
      final currency = ttData['priceCurrency'] as String? ?? 'EUR';
      final now = DateTime.now();

      // d) Create order
      final orderId = _uuid.v4();
      final orderNumber =
          'ORD-${DateFormat('yyyyMMdd').format(now)}-${(ticketsSold + 1).toString().padLeft(4, '0')}';

      final order = OrderModel(
        id: orderId,
        userId: userId,
        eventId: eventId,
        orderNumber: orderNumber,
        status: 'completed',
        totalAmount: priceAmount * quantity,
        currency: currency,
        createdAt: now,
        completedAt: now,
      );

      transaction.set(
        _firestore.collection('orders').doc(orderId),
        order.toFirestore(),
      );

      // e) Create individual tickets
      for (int i = 0; i < quantity; i++) {
        final ticketId = _uuid.v4();
        final ticketNumber =
            'TKT-${(ticketsSold + i + 1).toString().padLeft(4, '0')}';
        final qrCode = _uuid.v4();

        final ticket = TicketModel(
          id: ticketId,
          orderId: orderId,
          eventId: eventId,
          ticketTypeId: ticketTypeId,
          userId: userId,
          qrCode: qrCode,
          ticketNumber: ticketNumber,
          attendeeName: attendeeName,
          attendeeEmail: attendeeEmail,
          status: 'valid',
          purchasedAt: now,
        );

        transaction.set(
          _firestore.collection('tickets').doc(ticketId),
          ticket.toFirestore(),
        );
      }

      // f) Increment ticketType.quantitySold
      transaction.update(
        _firestore.collection('ticket_types').doc(ticketTypeId),
        {'quantitySold': FieldValue.increment(quantity)},
      );

      // g) Increment event.ticketsSold
      transaction.update(_firestore.collection('events').doc(eventId), {
        'ticketsSold': FieldValue.increment(quantity),
      });

      return order;
    });
  }

  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<TicketModel> getTicket(String ticketId) {
    return _firestore
        .collection('tickets')
        .doc(ticketId)
        .snapshots()
        .map((doc) => TicketModel.fromFirestore(doc));
  }

  Future<TicketModel?> getTicketByQrCode(String qrCode) async {
    final snapshot = await _firestore
        .collection('tickets')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return TicketModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> markTicketAsUsed(String ticketId, String scannedBy) async {
    final now = DateTime.now();

    // Update ticket status
    await _firestore.collection('tickets').doc(ticketId).update({
      'status': 'used',
      'usedAt': Timestamp.fromDate(now),
    });

    // Create scan record
    final scanId = _uuid.v4();
    final scan = TicketScanModel(
      id: scanId,
      ticketId: ticketId,
      scannedBy: scannedBy,
      result: 'admitted',
      scannedAt: now,
    );
    await _firestore
        .collection('ticket_scans')
        .doc(scanId)
        .set(scan.toFirestore());
  }

  Future<void> createScanRecord({
    required String ticketId,
    required String scannedBy,
    required String result,
  }) async {
    final scanId = _uuid.v4();
    final scan = TicketScanModel(
      id: scanId,
      ticketId: ticketId,
      scannedBy: scannedBy,
      result: result,
      scannedAt: DateTime.now(),
    );
    await _firestore
        .collection('ticket_scans')
        .doc(scanId)
        .set(scan.toFirestore());
  }
}
