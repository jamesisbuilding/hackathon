import 'package:dio/dio.dart';

class EventsApiClient {
  EventsApiClient({required this.endpoint, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              headers: const {'Content-Type': 'application/json'},
            ),
          );

  final String endpoint;
  final Dio _dio;

  Future<EventsPayload> fetchEvents({required String uid}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: <String, dynamic>{'uid': uid},
    );

    final data = response.data ?? <String, dynamic>{};
    return EventsPayload.fromJson(data);
  }
}

class EventsPayload {
  EventsPayload({required this.events, required this.users});

  factory EventsPayload.fromJson(Map<String, dynamic> json) {
    final eventsJson = (json['events'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final usersJson = (json['users'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return EventsPayload(
      events: eventsJson.map(Event.fromJson).toList(),
      users: usersJson.map(EventUser.fromJson).toList(),
    );
  }

  final List<Event> events;
  final List<EventUser> users;
}

class Event {
  Event({
    required this.id,
    required this.uid,
    required this.eventTitle,
    required this.startTimeLocal,
    required this.endTimeLocal,
    required this.eventType,
    required this.eventName,
    required this.eventDescription,
    required this.participantUserUuids,
    required this.callConversationId,
    required this.callSid,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int? ?? 0,
      uid: json['uid'] as String? ?? '',
      eventTitle: json['event_title'] as String? ?? '',
      startTimeLocal: DateTime.tryParse(
            json['start_time_local'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endTimeLocal: DateTime.tryParse(
            json['end_time_local'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      eventType: json['event_type'] as String? ?? '',
      eventName: json['event_name'] as String? ?? '',
      eventDescription: json['event_description'] as String? ?? '',
      participantUserUuids:
          (json['participant_user_uuids'] as List<dynamic>? ?? <dynamic>[])
              .map((e) => e.toString())
              .toList(),
      callConversationId: json['call_conversation_id'] as String? ?? '',
      callSid: json['call_sid'] as String? ?? '',
      createdAt: DateTime.tryParse(
            json['created_at'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final int id;
  final String uid;
  final String eventTitle;
  final DateTime startTimeLocal;
  final DateTime endTimeLocal;
  final String eventType;
  final String eventName;
  final String eventDescription;
  final List<String> participantUserUuids;
  final String callConversationId;
  final String callSid;
  final DateTime createdAt;
}

class EventUser {
  EventUser({
    required this.userUuid,
    required this.name,
    required this.city,
    required this.bio,
  });

  factory EventUser.fromJson(Map<String, dynamic> json) {
    return EventUser(
      userUuid: json['user_uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }

  final String userUuid;
  final String name;
  final String city;
  final String bio;
}

