class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String genre;
  final double rating; // This might be an average rating, or initial rating
  final String pages;
  final String synopsis;
  final String date; // Consider using DateTime if you need date calculations

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.genre,
    required this.rating,
    required this.pages,
    required this.synopsis,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'synopsis': synopsis,
      'genre': genre,
      'date': date,
      'pages': pages,
      'rating': rating,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown Author',
      imageUrl:
          json['imageUrl'] ?? 'assets/images/placeholder.png', // Fallback image
      synopsis: json['synopsis'] ?? 'No synopsis available.',
      genre: json['genre'] ?? 'Unknown',
      date: json['date'] ?? 'Unknown Date',
      pages: json['pages'] ?? 'N/A',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
