import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String organizationId;
  final String? categoryId;
  final String title;
  final String slug;
  final String? description;
  final String? coverImageUrl;
  final DateTime dateStart;
  final DateTime? dateEnd;
  final String timezone;
  final String? locationName;
  final String? locationAddress;
  final double? locationLat;
  final double? locationLng;
  final bool isOnline;
  final String? onlineUrl;
  final String status; // draft, published, cancelled, completed
  final String visibility; // public, private
  final int maxCapacity;
  final int ticketsSold;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const EventModel({
    required this.id,
    required this.organizationId,
    this.categoryId,
    required this.title,
    required this.slug,
    this.description,
    this.coverImageUrl,
    required this.dateStart,
    this.dateEnd,
    this.timezone = 'Europe/Zagreb',
    this.locationName,
    this.locationAddress,
    this.locationLat,
    this.locationLng,
    this.isOnline = false,
    this.onlineUrl,
    this.status = 'draft',
    this.visibility = 'public',
    this.maxCapacity = 100,
    this.ticketsSold = 0,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EventModel(
      id: doc.id,
      organizationId: data['organizationId'] as String? ?? '',
      categoryId: data['categoryId'] as String?,
      title: data['title'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      description: data['description'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      dateStart: (data['dateStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateEnd: (data['dateEnd'] as Timestamp?)?.toDate(),
      timezone: data['timezone'] as String? ?? 'Europe/Zagreb',
      locationName: data['locationName'] as String?,
      locationAddress: data['locationAddress'] as String?,
      locationLat: (data['locationLat'] as num?)?.toDouble(),
      locationLng: (data['locationLng'] as num?)?.toDouble(),
      isOnline: data['isOnline'] as bool? ?? false,
      onlineUrl: data['onlineUrl'] as String?,
      status: data['status'] as String? ?? 'draft',
      visibility: data['visibility'] as String? ?? 'public',
      maxCapacity: data['maxCapacity'] as int? ?? 100,
      ticketsSold: data['ticketsSold'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizationId': organizationId,
      'categoryId': categoryId,
      'title': title,
      'slug': slug,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'dateStart': Timestamp.fromDate(dateStart),
      'dateEnd': dateEnd != null ? Timestamp.fromDate(dateEnd!) : null,
      'timezone': timezone,
      'locationName': locationName,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'isOnline': isOnline,
      'onlineUrl': onlineUrl,
      'status': status,
      'visibility': visibility,
      'maxCapacity': maxCapacity,
      'ticketsSold': ticketsSold,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt': publishedAt != null
          ? Timestamp.fromDate(publishedAt!)
          : null,
    };
  }

  EventModel copyWith({
    String? id,
    String? organizationId,
    String? categoryId,
    String? title,
    String? slug,
    String? description,
    String? coverImageUrl,
    DateTime? dateStart,
    DateTime? dateEnd,
    String? timezone,
    String? locationName,
    String? locationAddress,
    double? locationLat,
    double? locationLng,
    bool? isOnline,
    String? onlineUrl,
    String? status,
    String? visibility,
    int? maxCapacity,
    int? ticketsSold,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      timezone: timezone ?? this.timezone,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      isOnline: isOnline ?? this.isOnline,
      onlineUrl: onlineUrl ?? this.onlineUrl,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      ticketsSold: ticketsSold ?? this.ticketsSold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  // --- Helper getters ---

  double get capacityPercentage {
    if (maxCapacity <= 0) return 0.0;
    return (ticketsSold / maxCapacity).clamp(0.0, 1.0);
  }

  bool get isPublished => status == 'published';
  bool get isDraft => status == 'draft';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isSoldOut => ticketsSold >= maxCapacity;
  bool get isFree => false; // determined by ticket types, not event

  String get formattedDate {
    return DateFormat('EEE, d. MMM yyyy.', 'hr').format(dateStart);
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(dateStart);
  }

  String get formattedDateTime {
    return '${formattedDate} • ${formattedTime}';
  }

  int get remainingCapacity =>
      (maxCapacity - ticketsSold).clamp(0, maxCapacity);
}
