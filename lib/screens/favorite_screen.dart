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
        bookmarkedBooks = books.map((book) => Book.fromJson(jsonDecode(book))).toList();
      });
    }
  }

  Future<void> _removeBookmark(Book book) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> books = prefs.getStringList('bookmarkedBooks') ?? [];

    books.removeWhere((b) => Book.fromJson(jsonDecode(b)).title == book.title);

    await prefs.setStringList('bookmarkedBooks', books);

    setState(() {
      bookmarkedBooks.remove(book);
    });
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} removed from bookmark')),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadBookmarkedBooks(); // Load bookmark saat halaman dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main'); // Navigasi ke MainScreen
          },
        ),
      ),
      body: Container(
        color: Colors.grey[200], // Background color
        child: bookmarkedBooks.isEmpty
            ? const Center(child: Text('No bookmarks found', style: TextStyle(fontSize: 16)))
            : Padding(
                padding: const EdgeInsets.all(10.0), // Padding untuk grid
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Jumlah kotak per baris
                    crossAxisSpacing: 12.0, // Jarak horizontal antar kotak
                    mainAxisSpacing: 20.0, // Jarak vertikal antar kotak
                    childAspectRatio: 0.7, // Rasio lebar ke tinggi kotak
                  ),
                  itemCount: bookmarkedBooks.length,
                  itemBuilder: (context, index) {
                    final book = bookmarkedBooks[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.all(8),
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Gambar Buku
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                book.imageUrl,
                                fit: BoxFit.contain, // Gambar tidak akan terpotong
                              ),
                            ),
                          ),
                          // Nama Buku
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              book.author,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeBookmark(book),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}