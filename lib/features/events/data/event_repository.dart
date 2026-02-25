import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/event_model.dart';
import '../domain/ticket_type_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<EventModel>> getPublishedEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'published')
        .orderBy('dateStart', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<EventModel> getEvent(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((doc) => EventModel.fromFirestore(doc));
  }

  Stream<List<TicketTypeModel>> getTicketTypes(String eventId) {
    return _firestore
        .collection('ticket_types')
        .where('eventId', isEqualTo: eventId)
        .orderBy('sortOrder', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TicketTypeModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> createEvent(EventModel event) async {
    await _firestore
        .collection('events')
        .doc(event.id)
        .set(event.toFirestore());
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _firestore.collection('events').doc(eventId).update(data);
  }

  Future<void> createTicketType(TicketTypeModel ticketType) async {
    await _firestore
        .collection('ticket_types')
        .doc(ticketType.id)
        .set(ticketType.toFirestore());
  }
}
