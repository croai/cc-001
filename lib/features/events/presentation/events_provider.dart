import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/event_repository.dart';
import '../domain/event_model.dart';
import '../domain/ticket_type_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final publishedEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getPublishedEvents();
});

final eventDetailProvider = StreamProvider.family<EventModel, String>((
  ref,
  eventId,
) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvent(eventId);
});

final ticketTypesProvider =
    StreamProvider.family<List<TicketTypeModel>, String>((ref, eventId) {
      final repo = ref.watch(eventRepositoryProvider);
      return repo.getTicketTypes(eventId);
    });
