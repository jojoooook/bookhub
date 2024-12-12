import 'package:bookhub/screens/favorite_screen.dart';
import 'package:bookhub/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '/models/book.dart';
import '/data/book_data.dart'; // Import data buku
import '/screens/home_screen.dart';
import 'package:bookhub/screens/rating_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  static const String routeName = '/detail';
  final Book book;
  const DetailScreen({super.key, required this.book});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
 
}

class _DetailScreenState extends State<DetailScreen> {
  bool isBookmarked = false; // Menyimpan status bookmark


  Future<void> _loadBookmarkedBooks() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? books = prefs.getStringList('bookmarkedBooks');
  if (books != null) {
    setState(() {
      isBookmarked = books.contains(widget.book.title);
    });
  }
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarkedBooks(); // Load bookmark saat widget diinisialisasi
  }



  @override
  Widget build(BuildContext context) {
    // Mendapatkan objek buku yang dikirim melalui arguments
    final Book book = ModalRoute.of(context)!.settings.arguments as Book; // Ambil buku langsung
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                      // Penulis Buku
                      Text(
                        'Author: ${book.author}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Tanggal Publikasi Buku
                      Text(
                        'Published on: ${book.date}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
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
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${book.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            '/5',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // Garis pemisah
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      // Genre
                      Text(
                        book.genre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      // Garis pemisah
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      // Jumlah halaman
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${book.pages} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Pages',
                              style: TextStyle(
                                fontSize:  14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Sinopsis
                const Text(
                  'Synopsis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.synopsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  List<String> bookmarkedBooks =
                      prefs.getStringList("bookmarkedBooks") ?? [];

                  setState(() {
                    if (isBookmarked) {
                      // Hapus buku dari bookmark
                      bookmarkedBooks.removeWhere((book) =>
                          Book.fromJson(jsonDecode(book)).title == widget.book.title);
                      isBookmarked = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.book.title} removed from bookmark')));
                    } else {
                      // Tambahkan buku ke bookmark
                      bookmarkedBooks.add(jsonEncode(widget.book.toJson()));
                      isBookmarked = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.book.title} added to bookmark')));
                    }
                  });

                  await prefs.setStringList("bookmarkedBooks", bookmarkedBooks);
                },

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: isBookmarked ? Colors.red : const Color(0xFF233973),
                ),
                child: Text(
                  isBookmarked ? 'Remove From Bookmark' : 'Add To Bookmark',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RatingScreen.routeName,
                    arguments: book,
                  );
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
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


