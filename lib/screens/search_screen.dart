import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookhub/data/book_data.dart';
import 'package:bookhub/models/book.dart';
import 'package:bookhub/screens/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  List<Book> _searchResults = [];
  bool _isBookFound = true;

  List<Book> get bookData => books;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentSearches = prefs.getStringList('recentSearches');
    if (recentSearches != null) {
      setState(() {
        _recentSearches = recentSearches;
      });
    }
  }

  void _addRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentSearches = prefs.getStringList('recentSearches') ?? [];
    if (!recentSearches.contains(search)) {
      recentSearches.add(search);
      await prefs.setStringList('recentSearches', recentSearches);
      setState(() {
        _recentSearches = recentSearches;
      });
    }
  }

  void _removeRecentSearch(String search) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentSearches = prefs.getStringList('recentSearches') ?? [];
    recentSearches.remove(search);
    await prefs.setStringList('recentSearches', recentSearches);
    setState(() {
      _recentSearches = recentSearches;
    });
  }

  void _searchBook() {
    final query = _searchController.text.toLowerCase();
    final results = bookData.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query);
    }).toList();

    setState(() {
      if (query.isNotEmpty) {
        if (results.isNotEmpty) {
          _searchResults = results;
          _isBookFound = true;
          _addRecentSearch(query);
        } else {
          _isBookFound = false;
        }
      }
    });
  }

  void _removeSearchResult(int index) {
    setState(() {
      _searchResults.removeAt(index);
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search titles, topics, or authors',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchBook();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Input tidak boleh kosong')),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchBook();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Input tidak boleh kosong')),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      await prefs.remove('recentSearches');
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: Text('Clear All', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          if (_recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _recentSearches.map((search) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = search;
                      _searchBook();
                    },
                    child: Chip(
                      label: Text(search),
                      deleteIcon: Icon(Icons.close),
                      onDeleted: () {
                        _removeRecentSearch(search);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_searchResults.isNotEmpty || !_isBookFound)
            Expanded(
              child: _isBookFound
                  ? ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final book = _searchResults[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(
                        'Author: ${book.author} | Genre: ${book.genre}'),
                    leading: Image.asset(book.imageUrl, width: 50),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeSearchResult(index);
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        DetailScreen.routeName,
                        arguments: book,
                      );
                    },
                  );
                },
              )
                  : Center(
                child: Text(
                  'No books found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
