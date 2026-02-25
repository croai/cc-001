import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../features/events/domain/event_model.dart';
import '../../features/events/domain/ticket_type_model.dart';

Future<void> seedDemoEvents(FirebaseFirestore firestore) async {
  const uuid = Uuid();
  final batch = firestore.batch();
  final now = DateTime.now();

  // --- Event 1: Flutter Forward Zagreb ---
  final event1Id = uuid.v4();
  final event1 = EventModel(
    id: event1Id,
    organizationId: 'org-demo-1',
    categoryId: 'Conference',
    title: 'Flutter Forward Zagreb 2025',
    slug: 'flutter-forward-zagreb-2025',
    description:
        'The biggest Flutter conference in Croatia! Join us for a full day of talks, workshops, and networking with Flutter developers from around the region. Featuring speakers from Google, VGV, and more.',
    coverImageUrl: 'https://picsum.photos/seed/flutter2025/800/450',
    dateStart: now.add(const Duration(days: 30)),
    dateEnd: now.add(const Duration(days: 30, hours: 8)),
    locationName: 'HUB385',
    locationAddress: 'Ivana Lučića 2a, 10000 Zagreb',
    locationLat: 45.8008,
    locationLng: 15.9716,
    status: 'published',
    visibility: 'public',
    maxCapacity: 200,
    ticketsSold: 53,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
  batch.set(firestore.collection('events').doc(event1Id), event1.toFirestore());

  // Ticket types for Event 1
  final tt1a = TicketTypeModel(
    id: uuid.v4(),
    eventId: event1Id,
    name: 'Early Bird',
    description: 'Limited early bird tickets at a discounted price',
    priceAmount: 1000,
    quantityTotal: 50,
    quantitySold: 23,
    sortOrder: 0,
    createdAt: now,
  );
  final tt1b = TicketTypeModel(
    id: uuid.v4(),
    eventId: event1Id,
    name: 'Regular',
    description: 'Standard admission ticket',
    priceAmount: 2000,
    quantityTotal: 100,
    quantitySold: 0,
    sortOrder: 1,
    createdAt: now,
  );
  final tt1c = TicketTypeModel(
    id: uuid.v4(),
    eventId: event1Id,
    name: 'VIP',
    description: 'VIP access with exclusive networking dinner',
    priceAmount: 5000,
    quantityTotal: 30,
    quantitySold: 30,
    sortOrder: 2,
    createdAt: now,
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt1a.id),
    tt1a.toFirestore(),
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt1b.id),
    tt1b.toFirestore(),
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt1c.id),
    tt1c.toFirestore(),
  );

  // --- Event 2: AI/ML Meetup ---
  final event2Id = uuid.v4();
  final event2 = EventModel(
    id: event2Id,
    organizationId: 'org-demo-2',
    categoryId: 'Meetup',
    title: 'AI/ML Meetup #12',
    slug: 'ai-ml-meetup-12',
    description:
        'Monthly AI/ML meetup featuring talks on LLMs, computer vision, and practical ML engineering. Pizza and drinks provided!',
    coverImageUrl: 'https://picsum.photos/seed/aiml12/800/450',
    dateStart: now.add(const Duration(days: 7)),
    dateEnd: now.add(const Duration(days: 7, hours: 3)),
    locationName: 'WESPA Spaces',
    locationAddress: 'Savska cesta 28, 10000 Zagreb',
    locationLat: 45.8025,
    locationLng: 15.9701,
    status: 'published',
    visibility: 'public',
    maxCapacity: 80,
    ticketsSold: 42,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
  batch.set(firestore.collection('events').doc(event2Id), event2.toFirestore());

  final tt2 = TicketTypeModel(
    id: uuid.v4(),
    eventId: event2Id,
    name: 'Free Entry',
    priceAmount: 0,
    quantityTotal: 80,
    quantitySold: 42,
    sortOrder: 0,
    createdAt: now,
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt2.id),
    tt2.toFirestore(),
  );

  // --- Event 3: UX Workshop ---
  final event3Id = uuid.v4();
  final event3 = EventModel(
    id: event3Id,
    organizationId: 'org-demo-3',
    categoryId: 'Workshop',
    title: 'UX Workshop: Design Systems',
    slug: 'ux-workshop-design-systems',
    description:
        'Hands-on workshop where you\'ll learn to build a scalable design system from scratch. Bring your laptop!',
    coverImageUrl: 'https://picsum.photos/seed/uxworkshop/800/450',
    dateStart: now.add(const Duration(days: 14)),
    dateEnd: now.add(const Duration(days: 14, hours: 6)),
    locationName: 'Lauba',
    locationAddress: 'Baruna Filipovića 23a, 10000 Zagreb',
    locationLat: 45.7978,
    locationLng: 15.9567,
    status: 'published',
    visibility: 'public',
    maxCapacity: 30,
    ticketsSold: 18,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
  batch.set(firestore.collection('events').doc(event3Id), event3.toFirestore());

  final tt3 = TicketTypeModel(
    id: uuid.v4(),
    eventId: event3Id,
    name: 'Workshop Pass',
    priceAmount: 2500,
    quantityTotal: 30,
    quantitySold: 18,
    sortOrder: 0,
    createdAt: now,
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt3.id),
    tt3.toFirestore(),
  );

  // --- Event 4: Tech Networking Night ---
  final event4Id = uuid.v4();
  final event4 = EventModel(
    id: event4Id,
    organizationId: 'org-demo-1',
    categoryId: 'Networking',
    title: 'Tech Networking Night',
    slug: 'tech-networking-night',
    description:
        'Casual networking event for tech professionals. Meet founders, developers, designers, and product people over drinks.',
    coverImageUrl: 'https://picsum.photos/seed/technight/800/450',
    dateStart: now.add(const Duration(days: 5)),
    dateEnd: now.add(const Duration(days: 5, hours: 4)),
    locationName: 'Johan Franck',
    locationAddress: 'Trg bana Josipa Jelačića 9, 10000 Zagreb',
    locationLat: 45.8129,
    locationLng: 15.9773,
    status: 'published',
    visibility: 'public',
    maxCapacity: 150,
    ticketsSold: 67,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
  batch.set(firestore.collection('events').doc(event4Id), event4.toFirestore());

  final tt4 = TicketTypeModel(
    id: uuid.v4(),
    eventId: event4Id,
    name: 'Free Entry',
    priceAmount: 0,
    quantityTotal: 150,
    quantitySold: 67,
    sortOrder: 0,
    createdAt: now,
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt4.id),
    tt4.toFirestore(),
  );

  // --- Event 5: DevOps Conference Croatia ---
  final event5Id = uuid.v4();
  final event5 = EventModel(
    id: event5Id,
    organizationId: 'org-demo-2',
    categoryId: 'Conference',
    title: 'DevOps Conference Croatia',
    slug: 'devops-conference-croatia',
    description:
        'Two days of DevOps, cloud infrastructure, CI/CD practices, and SRE talks. Featuring hands-on workshops with Kubernetes and Terraform.',
    coverImageUrl: 'https://picsum.photos/seed/devops2025/800/450',
    dateStart: now.add(const Duration(days: 45)),
    dateEnd: now.add(const Duration(days: 46)),
    locationName: 'Hypo Centar',
    locationAddress: 'Slavonska avenija 6, 10000 Zagreb',
    locationLat: 45.8005,
    locationLng: 15.9841,
    status: 'published',
    visibility: 'public',
    maxCapacity: 200,
    ticketsSold: 35,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
  batch.set(firestore.collection('events').doc(event5Id), event5.toFirestore());

  final tt5a = TicketTypeModel(
    id: uuid.v4(),
    eventId: event5Id,
    name: 'Regular',
    description: 'Conference-only ticket for both days',
    priceAmount: 3000,
    quantityTotal: 150,
    quantitySold: 25,
    sortOrder: 0,
    createdAt: now,
  );
  final tt5b = TicketTypeModel(
    id: uuid.v4(),
    eventId: event5Id,
    name: 'Workshop Pass',
    description: 'Conference + hands-on workshop access',
    priceAmount: 4500,
    quantityTotal: 50,
    quantitySold: 10,
    sortOrder: 1,
    createdAt: now,
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt5a.id),
    tt5a.toFirestore(),
  );
  batch.set(
    firestore.collection('ticket_types').doc(tt5b.id),
    tt5b.toFirestore(),
  );

  await batch.commit();
}
