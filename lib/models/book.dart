// lib/models/book.dart

import 'dart:convert';

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
  String toJson() {
    return '{"title": "$title", "author": "$author", "genre": "$genre", "imageUrl": "$imageUrl"}';
  }

  // Konversi dari JSON
  factory Book.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return Book(
      title: data['title'],
      author: data['author'],
      genre: data['genre'],
      imageUrl: data['imageUrl'], 
      rating: data['rating'],
    );
  }
}
