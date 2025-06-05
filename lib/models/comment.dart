import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String bookId;
  final String commentText;
  final double latitude;
  final double longitude;
  final String city;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.commentText,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'commentText': commentText,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    DateTime parsedTimestamp;
    if (json['timestamp'] is Timestamp) {
      parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
    } else {
      print(
          'Warning: Timestamp for comment is not a Firestore Timestamp object. Using DateTime.now(). Raw value: ${json['timestamp']}');
      parsedTimestamp = DateTime.now();
    }

    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      bookId: json['bookId'] ?? '',
      commentText: json['commentText'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] ??
          'Unknown City', // Defaults to 'Unknown City' if not found
      timestamp: parsedTimestamp,
    );
  }
}
