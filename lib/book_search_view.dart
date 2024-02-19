import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:otzaria/main_window_view.dart';


class BookSearchScreen extends StatefulWidget {
  final void Function(TabWindow tab) openFileCallback;
  const BookSearchScreen({
    Key? key, required this.openFileCallback
  }) : super(key: key);

  @override
  BookSearchScreenState createState() => BookSearchScreenState();
}

class BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController searchController = TextEditingController();
  // get all files from the directory "אוצריא"
  final List<String> books = Directory('אוצריא')
      .listSync(recursive: true)
      .whereType<File>().map((e) => e.path).toList();
  List<String> _searchResults = [];

  Future<void> _searchBooks(String query) async{
    final results = books.where((book) {
      final bookName = book.split('\\').last.toLowerCase();
      // if all the words seperated by spaces exist in the book name, even not in order, return true
       bool result = true;
      for (final word in query.split(' ')) {
        result = result && bookName.contains(word.toLowerCase());
      }
      return result;
    }).toList();
    
    //sort the results by their levenstien distance
    if (query.isNotEmpty){
       results.sort((a, b) =>  ratio(query, b.split('\\').last.trim().toLowerCase()).compareTo(
                           ratio(query,a.split('\\').last.trim().toLowerCase()))
    ,);}
    // sort alphabetic
    else {
      results.sort((a,b)=> a.split('\\').last.trim().compareTo(
                           b.split('\\').last.trim()));
      }

       setState(() {
      _searchResults = results;
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() async=>
        _searchBooks(searchController.text)
      );  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('חיפוש ספר'),
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                autofocus: true,
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'הקלד שם ספר: ',
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final book = _searchResults[index];
                    return ListTile(
                        title: Text(book.split('\\').last),
                        onTap: () {
                          widget.openFileCallback(
                            BookTabWindow(
                               book,
                               0
                              )
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}