import 'package:flutter/material.dart';

import '../../core/network/events_api_client.dart';
import '../instagram_frame/src/menu.dart';

class EventNavigationArgs {
  EventNavigationArgs({required this.eventId});

  final int eventId;
}

class EventsPage extends StatefulWidget {
  const EventsPage({required this.eventsClient, super.key});

  static const routeName = '/events';

  final EventsApiClient eventsClient;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<EventsPayload> _future;
  final ScrollController _scrollController = ScrollController();

  int? _targetEventId;

  @override
  void initState() {
    super.initState();
    _future = widget.eventsClient.fetchEvents(uid: 'user-callflow');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is EventNavigationArgs) {
      _targetEventId = args.eventId;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = widget.eventsClient.fetchEvents(uid: 'user-callflow');
              });
              await _future;
            },
            child: FutureBuilder<EventsPayload>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 280,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Failed to load events.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }

                final payload = snapshot.data;
                if (payload == null || payload.events.isEmpty) {
                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 280,
                        child: Center(child: Text('No events available.')),
                      ),
                    ],
                  );
                }

                final usersById = {
                  for (final u in payload.users) u.userUuid: u,
                };

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_targetEventId != null) {
                    final index = payload.events.indexWhere(
                      (event) => event.id == _targetEventId,
                    );
                    if (index >= 0 && _scrollController.hasClients) {
                      _scrollController.animateTo(
                        index * 220,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      _targetEventId = null;
                    }
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: payload.events.length,
                  itemBuilder: (context, index) {
                    final event = payload.events[index];
                    final participants = event.participantUserUuids
                        .map((id) => usersById[id])
                        .whereType<EventUser>()
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.eventTitle.isNotEmpty
                                  ? event.eventTitle
                                  : event.eventName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.eventDescription,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${event.startTimeLocal} - ${event.endTimeLocal}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (participants.isNotEmpty) ...[
                              Text(
                                'Participants',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: participants.map((user) {
                                  return Chip(
                                    label: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                        if (user.city.isNotEmpty)
                                          Text(
                                            user.city,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          HoverMenu(navigationContext: context),
        ],
      ),
    );
  }
}
