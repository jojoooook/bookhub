import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionPath = 'books';

  // Fetch all books from Firestore
  Future<List<Book>> getBooks() async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs
          .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  // Get a single book by ID
  Future<Book?> getBookById(String bookId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionPath).doc(bookId).get();
      if (docSnapshot.exists) {
        return Book.fromJson(docSnapshot.data()! as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching book: $e');
      return null;
    }
  }

  // Get books by genre
  Future<List<Book>> getBooksByGenre(String genre) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .where('genre', isEqualTo: genre)
          .get();
      return querySnapshot.docs
          .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching books by genre: $e');
      return [];
    }
  }

  // Add book to user's favorites
  Future<void> addToFavorites(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(bookId)
            .set({
          'bookId': bookId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      throw e;
    }
  }

  // Remove book from user's favorites
  Future<void> removeFromFavorites(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(bookId)
            .delete();
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      throw e;
    }
  }

  // Get user's favorite books
  Future<List<Book>> getFavoriteBooks() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final favoritesSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get();

        final List<String> bookIds = favoritesSnapshot.docs
            .map((doc) => doc.data()['bookId'] as String)
            .toList();

        final List<Book> favoriteBooks = [];
        for (String bookId in bookIds) {
          final book = await getBookById(bookId);
          if (book != null) {
            favoriteBooks.add(book);
          }
        }
        return favoriteBooks;
      }
      return [];
    } catch (e) {
      print('Error fetching favorite books: $e');
      return [];
    }
  }

  // Check if a book is in user's favorites
  Future<bool> isBookFavorite(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(bookId)
            .get();
        return docSnapshot.exists;
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
