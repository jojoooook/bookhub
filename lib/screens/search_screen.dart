import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookhub/data/book_data.dart';
import 'package:bookhub/models/book.dart'; 

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
  int _currentIndex = 2;

  List<Book> get bookData => books;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches(); 
    _loadSearchResults();
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

  void _loadSearchResults() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? savedResults = prefs.getStringList('searchResults');

  if (savedResults != null) {
    setState(() {
      _searchResults = savedResults
          .map((bookJson) => Book.fromJson(bookJson)) // Konversi dari JSON
          .toList();
    });
  } else {
    setState(() {
      _searchResults = [];
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

  void _removeSearchResult(int index) async {
  setState(() {
    _searchResults.removeAt(index);
  });
  _saveSearchResults(); // Simpan ulang hasil pencarian
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
      final newResults = results.where((newBook) => !_searchResults.contains(newBook)).toList();

      if (newResults.isNotEmpty) {
        _searchResults.addAll(newResults);
        _saveSearchResults();
        _isBookFound = true;
        _addRecentSearch(query); 
      } else {
        _isBookFound = false; 
      }
      if (!_isBookFound) {
        _showNoBookFoundDialog();
      }
    }
  });
}
  
  void _saveSearchResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> resultsToSave =
        _searchResults.map((book) => book.toJson()).toList(); // Konversi ke JSON
    await prefs.setStringList('searchResults', resultsToSave);
}


  void _showNoBookFoundDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Pemberitahuan'),
        content: Text('Buku tidak ditemukan'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
      );
    },
  );
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
            border: InputBorder.none,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('recentSearches');
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: Text('Clear All Recent Searches'),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('searchResults'); // Hapus data dari storage
              setState(() {
                _searchResults.clear();
              });
            },
            child: Text('Clear All Search Result'),
          ),

          if (_recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0, 
                runSpacing: 4.0, 
                children: _recentSearches.map((search) {
                  return Chip(
                    label: Text(search),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      _removeRecentSearch(search); 
                    },
                  );
                }).toList(),
              ),
            ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final book = _searchResults[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text('Author: ${book.author} | Genre: ${book.genre}'),
                    leading: Image.asset(book.imageUrl), 
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeSearchResult(index); // Hapus hasil pencarian individu
                      },
                    ),

                    onTap: () {
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}