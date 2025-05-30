// lib/models/book.dart

import 'dart:convert';

class Book {
  final String title;
  final String author;
  final String imageUrl;
  final String genre;
  final double rating;
  final String pages;
  final String synopsis;
  final String date;

  Book({
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

  // Konversi dari JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      imageUrl: json['imageUrl'],
      synopsis: json['synopsis'],
      genre: json['genre'],
      date: json['date'],
      pages: json['pages'],
      rating: json['rating'].toDouble(),
    );
  }
}
