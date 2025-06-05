import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/comment.dart';
import '../models/rating.dart';
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
          .map((doc) => Book.fromJson(doc.data()))
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
        return Book.fromJson(docSnapshot.data()!);
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
          .map((doc) => Book.fromJson(doc.data()))
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
      rethrow;
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
      rethrow;
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

  // Add comment to a book
  Future<void> addComment({
    required String bookId,
    required String commentText,
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final commentRef = _firestore
            .collection(collectionPath)
            .doc(bookId)
            .collection('comments')
            .doc();

        await commentRef.set({
          'id': commentRef.id,
          'userId': user.uid,
          'bookId': bookId,
          'commentText': commentText,
          'latitude': latitude,
          'longitude': longitude,
          'city': city,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Get comments for a book
  Future<List<Comment>> getComments(String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .doc(bookId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Comment.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<void> deleteComment(String bookId, String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Ambil komentar untuk memastikan pengguna yang menghapus adalah pemiliknya
        final commentDoc = await _firestore
            .collection(collectionPath)
            .doc(bookId)
            .collection('comments')
            .doc(commentId)
            .get();

        if (commentDoc.exists && commentDoc.data()?['userId'] == user.uid) {
          await _firestore
              .collection(collectionPath)
              .doc(bookId)
              .collection('comments')
              .doc(commentId)
              .delete();
        } else {
          throw Exception('You are not authorized to delete this comment.');
        }
      } else {
        throw Exception('User not logged in.');
      }
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  // Add rating to a book by user
  // This method will create or update a user's rating for a specific book.
  Future<void> addRating({
    required String bookId,
    required double ratingValue,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Use user.uid as the document ID for ratings to ensure only one rating per user per book
        final ratingRef = _firestore
            .collection(collectionPath)
            .doc(bookId)
            .collection('ratings')
            .doc(user.uid); // Document ID is the user's UID

        await ratingRef.set({
          'id': ratingRef
              .id, // The ID of the rating document (same as user.uid here)
          'userId': user.uid,
          'bookId': bookId,
          'ratingValue': ratingValue,
        });
      }
    } catch (e) {
      print('Error adding rating: $e');
      rethrow;
    }
  }

  // Get ratings for a book
  Future<List<Rating>> getRatings(String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .doc(bookId)
          .collection('ratings')
          .get();

      return querySnapshot.docs
          .map((doc) => Rating.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching ratings: $e');
      return [];
    }
  }

  Future<double?> getUserRating(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore
            .collection(collectionPath)
            .doc(bookId)
            .collection('ratings')
            .doc(user.uid) // Query using the user's UID
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final ratingData = docSnapshot.data()!;
          return (ratingData['ratingValue'] as num?)?.toDouble();
        }
      }
      return null; // User not logged in or no rating found
    } catch (e) {
      print('Error getting user rating: $e');
      return null;
    }
  }

  Future<String?> getUserName(String userId) async {
    try {
      // Asumsi: Koleksi 'users' ada dan doc ID-nya adalah userId
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.data()!['name'] as String?; // Ambil field 'name'
      }
      return null; // Pengguna tidak ditemukan atau tidak punya field 'name'
    } catch (e) {
      print('Error fetching user name for ID $userId: $e');
      return null;
    }
  }
}
