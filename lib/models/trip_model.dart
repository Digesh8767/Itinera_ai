import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';

class TripModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String destination;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final List<ItineraryItem> itinerary;

  @HiveField(8)
  final TripStatus status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.imageUrl,
    required this.itinerary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  TripModel copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? imageUrl,
    List<ItineraryItem>? itinerary,
    TripStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      itinerary: itinerary ?? this.itinerary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'itinerary': itinerary.map((item) => item.toJson()).toList(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      title: json['title'],
      destination: json['destination'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      description: json['description'],
      imageUrl: json['imageUrl'],
      itinerary:
          (json['itinerary'] as List)
              .map((item) => ItineraryItem.fromJson(item))
              .toList(),
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.planning,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    destination,
    startDate,
    endDate,
    description,
    imageUrl,
    itinerary,
    status,
    createdAt,
    updatedAt,
  ];
}

@HiveType(typeId: 1)
class ItineraryItem extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final ItineraryItemType type;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final double? latitude;

  @HiveField(9)
  final double? longitude;

  @HiveField(10)
  final bool isCompleted;

  const ItineraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isCompleted = false,
  });

  ItineraryItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    ItineraryItemType? type,
    String? imageUrl,
    double? latitude,
    double? longitude,
    bool? isCompleted,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'type': type.name,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isCompleted': isCompleted,
    };
  }

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      type: ItineraryItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ItineraryItemType.activity,
      ),
      imageUrl: json['imageUrl'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
    type,
    imageUrl,
    latitude,
    longitude,
    isCompleted,
  ];
}

@HiveType(typeId: 2)
enum TripStatus {
  @HiveField(0)
  planning,

  @HiveField(1)
  active,

  @HiveField(2)
  completed,

  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 3)
enum ItineraryItemType {
  @HiveField(0)
  accommodation,

  @HiveField(1)
  activity,

  @HiveField(2)
  restaurant,

  @HiveField(3)
  transportation,

  @HiveField(4)
  sightseeing,
}
