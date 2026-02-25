import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uuid/uuid.dart';

import '../../../app/theme.dart';
import '../domain/event_model.dart';
import '../domain/ticket_type_model.dart';

import 'events_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController(text: '100');
  final _ticketNameController = TextEditingController(
    text: 'General Admission',
  );
  final _ticketPriceController = TextEditingController(text: '0');
  final _ticketQtyController = TextEditingController(text: '100');
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _ticketNameController.dispose();
    _ticketPriceController.dispose();
    _ticketQtyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventDate),
      );
      setState(() {
        _eventDate = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 18,
          time?.minute ?? 0,
        );
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      final eventId = uuid.v4();
      final capacity = int.tryParse(_capacityController.text) ?? 100;

      final event = EventModel(
        id: eventId,
        organizationId: 'user-created',
        title: _titleController.text,
        slug: _titleController.text.toLowerCase().replaceAll(' ', '-'),
        description: _descriptionController.text,
        dateStart: _eventDate,
        locationName: _locationController.text,
        status: 'published',
        visibility: 'public',
        maxCapacity: capacity,
        ticketsSold: 0,
        createdAt: now,
        updatedAt: now,
        publishedAt: now,
      );

      final repo = ref.read(eventRepositoryProvider);
      await repo.createEvent(event);

      // Create ticket type
      final priceEur = double.tryParse(_ticketPriceController.text) ?? 0;
      final priceCents = (priceEur * 100).round();
      final ticketQty = int.tryParse(_ticketQtyController.text) ?? capacity;

      final ticketType = TicketTypeModel(
        id: uuid.v4(),
        eventId: eventId,
        name: _ticketNameController.text,
        priceAmount: priceCents,
        quantityTotal: ticketQty,
        quantitySold: 0,
        sortOrder: 0,
        createdAt: now,
      );
      await repo.createTicketType(ticketType);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event created!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Title required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              title: Text(
                '${_eventDate.day}.${_eventDate.month}.${_eventDate.year}. ${_eventDate.hour}:${_eventDate.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Change'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Max Capacity',
                prefixIcon: Icon(Icons.people_outline),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            Text(
              'Ticket Type',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ticketNameController,
              decoration: const InputDecoration(labelText: 'Ticket Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ticketPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (EUR)',
                      prefixText: '€ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _ticketQtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createEvent,
                child: _isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publish Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
