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
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      bookId: json['bookId'],
      commentText: json['commentText'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
