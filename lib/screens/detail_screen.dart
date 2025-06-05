import 'package:flutter/material.dart';
import '/models/book.dart';
import 'package:bookhub/services/book_service.dart';
import 'package:bookhub/models/rating.dart' as rating_model;
import 'package:bookhub/models/comment.dart' as comment_model;
import 'package:bookhub/screens/rating_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class DetailScreen extends StatefulWidget {
  static const String routeName = '/detail';
  final Book book;

  const DetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isBookmarked = false;
  final BookService _bookService = BookService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth
  User? _currentUser; // Untuk menyimpan data pengguna yang sedang login

  List<rating_model.Rating> _ratings = [];
  List<comment_model.Comment> _comments = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  int _numberOfRatings = 0;

  final TextEditingController _commentController = TextEditingController();
  bool _isCommentSubmitting = false;
  bool _showAllComments = false;

  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadBookmarkedStatus();
    _fetchRatingsAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkedStatus() async {
    try {
      final isFavorite = await _bookService.isBookFavorite(widget.book.id);
      setState(() {
        isBookmarked = isFavorite;
      });
    } catch (e) {
      print('Error loading bookmark status: $e');
    }
  }

  Future<void> _fetchRatingsAndComments() async {
    try {
      final ratings = await _bookService.getRatings(widget.book.id);
      final comments = await _bookService.getComments(widget.book.id);

      double totalRating = 0.0;
      for (var rating in ratings) {
        totalRating += rating.ratingValue;
      }
      double avgRating =
          ratings.isNotEmpty ? totalRating / ratings.length : 0.0;

      final Set<String> uniqueUserIds = comments.map((c) => c.userId).toSet();
      final Map<String, String> fetchedUserNames = {};
      for (final userId in uniqueUserIds) {
        final userName = await _bookService.getUserName(userId);
        fetchedUserNames[userId] = userName ?? 'Anonymous';
      }

      setState(() {
        _ratings = ratings;
        _comments = comments
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _averageRating = avgRating;
        _numberOfRatings = ratings.length;
        _userNames = fetchedUserNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching ratings and comments: $e');
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, please enable them in settings.')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
  }

  Future<String> _getCityFromPosition(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            placemarks.first.country ??
            'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      print('Error during geocoding for saving comment: $e');
      return 'Unknown Location (Error)';
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a comment before submitting.')),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment.')),
      );
      return;
    }

    setState(() {
      _isCommentSubmitting = true;
    });

    Position? position = await _determinePosition();
    double latitude = 0.0;
    double longitude = 0.0;
    String city = 'Unknown Location';

    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;
      city = await _getCityFromPosition(position);
    } else {
      print('Could not determine current position for comment.');
    }

    try {
      await _bookService.addComment(
        bookId: widget.book.id,
        commentText: _commentController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        city: city,
      );

      _commentController.clear();
      await _fetchRatingsAndComments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment submitted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit comment.')),
      );
      print('Error submitting comment: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCommentSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to delete comments.')),
      );
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _bookService.deleteComment(widget.book.id, commentId);
        await _fetchRatingsAndComments();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment.')),
        );
        print('Error deleting comment: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;

    final List<comment_model.Comment> commentsToShow =
        _showAllComments ? _comments : _comments.take(3).toList();
    final bool hasMoreComments = _comments.length > 3;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              book.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: 120,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  book.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Author: ${book.author}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Published on: ${book.date}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  _averageRating.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '/5',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  ' ($_numberOfRatings ratings)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            Text(
                              book.genre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${book.pages} ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Pages',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Synopsis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.synopsis,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _comments.isEmpty
                          ? Text(
                              'No comments yet.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.7),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: commentsToShow.length,
                              itemBuilder: (context, index) {
                                final comment = commentsToShow[index];
                                final userName =
                                    _userNames[comment.userId] ?? 'Anonymous';

                                final bool canDelete = _currentUser != null &&
                                    _currentUser!.uid == comment.userId;

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(
                                      12.0), // Padding di dalam container
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade900
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    boxShadow: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // NEW: align items to start
                                        children: [
                                          Expanded(
                                            // NEW: expanded to take available space
                                            child: Text(
                                              userName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // NEW: prevent text from overflowing
                                            ),
                                          ),
                                          if (canDelete)
                                            // NEW: Icon tong sampah langsung tanpa PopupMenuButton,
                                            // Menggunakan Padding untuk mengontrol space
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 0.0,
                                                  bottom:
                                                      0.0), // Sedikit padding kiri
                                              child: InkWell(
                                                // Menggunakan InkWell agar bisa diklik
                                                onTap: () =>
                                                    _deleteComment(comment.id),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size:
                                                      18, // Ukuran ikon agar tidak makan banyak tempat
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comment.commentText,
                                          style: const TextStyle(fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lat: ${comment.latitude.toStringAsFixed(4)}, Lng: ${comment.longitude.toStringAsFixed(4)} - ${comment.timestamp.toLocal().toString().split('.')[0]}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      if (hasMoreComments && !_showAllComments)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllComments = true;
                                });
                              },
                              child: Text(
                                'More Comments (${_comments.length - 3} hidden)',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Add a Comment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your comment here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Theme.of(context).colorScheme.surface,
                          filled: true,
                        ),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isCommentSubmitting || _currentUser == null
                                  ? null
                                  : _submitComment,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: const Color(0xFF233973),
                          ),
                          child: _isCommentSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _currentUser == null
                                      ? 'Login to Comment'
                                      : 'Submit Comment',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });

                    if (_currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'You must be logged in to favorite a book.')),
                      );
                      setState(() {
                        isBookmarked = !isBookmarked;
                      });
                      return;
                    }

                    if (isBookmarked) {
                      await _bookService.addToFavorites(widget.book.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${widget.book.title} added to favorites')),
                      );
                    } else {
                      await _bookService.removeFromFavorites(widget.book.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${widget.book.title} removed from favorites')),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to update favorites')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor:
                      isBookmarked ? Colors.red : const Color(0xFF233973),
                ),
                child: Text(
                  isBookmarked ? 'Remove From Favorites' : 'Add To Favorites',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('You must be logged in to give a rating.')),
                    );
                    return;
                  }
                  await Navigator.pushNamed(
                    context,
                    RatingScreen.routeName,
                    arguments: book,
                  );
                  _fetchRatingsAndComments();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: const Color(0xFFEF760C),
                ),
                child: const Text(
                  'Give Rating',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
