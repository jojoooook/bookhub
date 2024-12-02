// lib/models/book.dart

class Book {
  final String title;
  final String author;
  final String imageUrl;
  final String genre;
  final double rating;

  Book({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.genre,
    required this.rating,
  });
}
