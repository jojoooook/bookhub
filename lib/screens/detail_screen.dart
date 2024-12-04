import 'package:flutter/material.dart';
import '/models/book.dart';
import '/data/book_data.dart'; // Import data buku
import 'package:bookhub/screens/home_screen.dart';

class DetailScreen extends StatelessWidget {
  final int bookIndex; // Index buku dalam daftar

  static const String routeName = '/detail';

  DetailScreen({required this.bookIndex}); // Constructor menerima index buku

  @override
  Widget build(BuildContext context) {
    final Book book = books[bookIndex]; // Ambil buku berdasarkan index

    return Scaffold(
      backgroundColor: Colors.white, // Mengubah background menjadi putih
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian tombol back dan Gambar serta Informasi Penulis
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                      },
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      // Judul Buku di atas gambar
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Gambar Buku
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          book.imageUrl,
                          fit: BoxFit.cover,
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
                        ),
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
                // Box untuk rating, genre, pages dengan warna abu-abu
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // Warna abu-abu
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
                      // Rating bintang
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${book.rating} ',
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Tambahkan logika untuk bookmark
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), // padding horizontal lebih kecil
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: const Color(0xFF233973),
                ),
                child: const Text(
                  'Add To Bookmark',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16), // Jarak antar tombol
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Tambahkan logika untuk memberi rating
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), // padding horizontal lebih kecil
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: const Color(0xFFEF760C),
                ),
                child: const Text(
                  'Give Rating',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}