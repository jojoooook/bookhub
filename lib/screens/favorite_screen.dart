import 'package:flutter/material.dart';
import '/models/book.dart'; // Import model Book
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteScreen extends StatefulWidget {
  static const routeName = '/favorite';
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Book> bookmarkedBooks = [];

  Future<void> _loadBookmarkedBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? books = prefs.getStringList('bookmarkedBooks');
    if (books != null) {
      setState(() {
        bookmarkedBooks =
            books.map((book) => Book.fromJson(jsonDecode(book))).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarkedBooks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookmarkedBooks();
    setState(() {
      _loadBookmarkedBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Teks "Bookmarks" berada di tengah atas
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 24.0),
              child: Center(
                child: Text(
                  'Bookmarks',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Grid buku
            Expanded(
              child: bookmarkedBooks.isEmpty
                  ? const Center(
                child: Text(
                  'No bookmarks found',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Jumlah kolom dalam grid
                  crossAxisSpacing: 12.0, // Jarak horizontal antar kotak
                  mainAxisSpacing: 20.0, // Jarak vertikal antar kotak
                  childAspectRatio: 0.55, // Rasio kotak untuk gambar + teks
                ),
                itemCount: bookmarkedBooks.length,
                itemBuilder: (context, index) {
                  final book = bookmarkedBooks[index];

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: book,
                      );
                        _loadBookmarkedBooks();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Gambar Buku dengan ukuran tetap menggunakan AspectRatio
                          AspectRatio(
                            aspectRatio: 3 / 4, // Rasio gambar 3:4
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.asset(
                                book.imageUrl,
                                fit: BoxFit.cover, // Gambar memenuhi area
                              ),
                            ),
                          ),
                          // Nama Buku dengan batas 2 baris
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
