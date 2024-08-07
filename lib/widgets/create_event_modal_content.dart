// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spaceshare/models/event.dart';
import 'event_form.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class CreateEventModalContent extends StatefulWidget {
  const CreateEventModalContent({super.key});

  @override
  _CreateEventModalContentState createState() =>
      _CreateEventModalContentState();
}

class _CreateEventModalContentState extends State<CreateEventModalContent> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int selectedCategoryId = 1;

  Future<Event?> _createEvent(
      BuildContext context, Map<String, dynamic> eventData) async {
    final EventService eventService = EventService(ApiService());

    try {
      final event = await eventService.createEvent(eventData);
      return event;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t(context)!.creationEventFailed}: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                t(context)!.eventTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
            EventForm(
              eventNameController: eventNameController,
              descriptionController: descriptionController,
              buttonText: t(context)!.createEventButton,
              onSubmit: () async {
                final Map<String, dynamic> eventData = {
                  'name': eventNameController.text,
                  'description': descriptionController.text,
                  'category': selectedCategoryId,
                };

                final event = await _createEvent(context, eventData);
                if (event != null && context.mounted) {
                  context.go('/events/${event.id}');
                }
              },
              onCategorySelected: (int categoryId) {
                setState(() {
                  selectedCategoryId = categoryId;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
