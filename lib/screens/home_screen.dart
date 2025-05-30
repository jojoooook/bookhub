import 'package:flutter/material.dart';
import '/models/book.dart';
import 'package:bookhub/data/book_data.dart';
import 'package:bookhub/data/user_data.dart';
import 'package:bookhub/screens/detail_screen.dart';
import 'package:bookhub/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Fantasy';
  final List<String> categories = [
    'Fantasy',
    'Romance',
    'Mystery',
    'Thriller',
    'Comedy'
  ];

  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = AuthService();
    final firebaseUser = authService.currentUser;
    if (firebaseUser != null) {
      final userData = await authService.fetchUserProfile(firebaseUser.uid);
      print('Fetched userData: $userData'); // Debug print
      setState(() {
        userName = userData?['name'] ?? firebaseUser.email ?? 'Guest';
      });
      print('Set userName: $userName'); // Debug print
    } else {
      setState(() {
        userName = 'Guest';
      });
      print('No firebase user, set userName to Guest'); // Debug print
    }
  }

  List<Book> get filteredBooks {
    return books.where((book) => book.genre == _selectedCategory).toList();
  }

  List<Book> get recentlyAddedBooks {
    return books.length > 10
        ? books.sublist(books.length - 10).reversed.toList()
        : books.reversed.toList();
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF233973) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 40.0),
                child: Text(
                  'Hello, ${userName ?? 'Guest'}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'Recently Added Books',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentlyAddedBooks.length,
                  itemBuilder: (context, index) {
                    final book = recentlyAddedBooks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          DetailScreen.routeName,
                          arguments: book,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    book.imageUrl,
                                    height: 180,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    book.title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Batasi maksimal 2 baris
                                    overflow: TextOverflow
                                        .ellipsis, // Tambahkan elipsis jika terlalu panjang
                                  ),
                                ),
                                SizedBox(height: 2),
                                Center(
                                  child: Text(
                                    '${book.author}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    '${book.rating}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildCategoryButton(category),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Books in $_selectedCategory category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          DetailScreen.routeName,
                          arguments: book,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    book.imageUrl,
                                    height: 180,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  book.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Ukuran font lebih kecil
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2, // Batas 2 baris
                                  overflow: TextOverflow
                                      .ellipsis, // Potong teks dengan elipsis
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${book.author}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    '${book.rating}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
