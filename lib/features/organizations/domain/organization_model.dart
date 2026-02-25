import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? websiteUrl;
  final String? contactEmail;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.websiteUrl,
    this.contactEmail,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrganizationModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      description: data['description'] as String?,
      logoUrl: data['logoUrl'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      websiteUrl: data['websiteUrl'] as String?,
      contactEmail: data['contactEmail'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'websiteUrl': websiteUrl,
      'contactEmail': contactEmail,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    String? websiteUrl,
    String? contactEmail,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
