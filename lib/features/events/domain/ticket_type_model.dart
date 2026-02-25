import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TicketTypeModel {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final int priceAmount; // in cents
  final String priceCurrency;
  final int quantityTotal;
  final int quantitySold;
  final int maxPerOrder;
  final DateTime? saleStart;
  final DateTime? saleEnd;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const TicketTypeModel({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    this.priceAmount = 0,
    this.priceCurrency = 'EUR',
    required this.quantityTotal,
    this.quantitySold = 0,
    this.maxPerOrder = 5,
    this.saleStart,
    this.saleEnd,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory TicketTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TicketTypeModel(
      id: doc.id,
      eventId: data['eventId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      priceAmount: data['priceAmount'] as int? ?? 0,
      priceCurrency: data['priceCurrency'] as String? ?? 'EUR',
      quantityTotal: data['quantityTotal'] as int? ?? 0,
      quantitySold: data['quantitySold'] as int? ?? 0,
      maxPerOrder: data['maxPerOrder'] as int? ?? 5,
      saleStart: (data['saleStart'] as Timestamp?)?.toDate(),
      saleEnd: (data['saleEnd'] as Timestamp?)?.toDate(),
      sortOrder: data['sortOrder'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'name': name,
      'description': description,
      'priceAmount': priceAmount,
      'priceCurrency': priceCurrency,
      'quantityTotal': quantityTotal,
      'quantitySold': quantitySold,
      'maxPerOrder': maxPerOrder,
      'saleStart': saleStart != null ? Timestamp.fromDate(saleStart!) : null,
      'saleEnd': saleEnd != null ? Timestamp.fromDate(saleEnd!) : null,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TicketTypeModel copyWith({
    String? id,
    String? eventId,
    String? name,
    String? description,
    int? priceAmount,
    String? priceCurrency,
    int? quantityTotal,
    int? quantitySold,
    int? maxPerOrder,
    DateTime? saleStart,
    DateTime? saleEnd,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TicketTypeModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceAmount: priceAmount ?? this.priceAmount,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      quantityTotal: quantityTotal ?? this.quantityTotal,
      quantitySold: quantitySold ?? this.quantitySold,
      maxPerOrder: maxPerOrder ?? this.maxPerOrder,
      saleStart: saleStart ?? this.saleStart,
      saleEnd: saleEnd ?? this.saleEnd,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // --- Helper getters ---

  bool get isSoldOut => quantitySold >= quantityTotal;
  int get remaining => (quantityTotal - quantitySold).clamp(0, quantityTotal);
  bool get isFree => priceAmount == 0;

  bool get isOnSale {
    final now = DateTime.now();
    if (!isActive) return false;
    if (isSoldOut) return false;
    if (saleStart != null && now.isBefore(saleStart!)) return false;
    if (saleEnd != null && now.isAfter(saleEnd!)) return false;
    return true;
  }

  String get formattedPrice {
    if (priceAmount == 0) return 'Besplatno';
    final euros = priceAmount / 100;
    final formatter = NumberFormat('#,##0.00', 'hr');
    return '${formatter.format(euros)} $priceCurrency';
  }
}
