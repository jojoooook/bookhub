class Rating {
  final String id;
  final String userId;
  final String bookId;
  final double ratingValue;

  Rating({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.ratingValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'ratingValue': ratingValue,
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      bookId: json['bookId'] ?? '',
      ratingValue: (json['ratingValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
