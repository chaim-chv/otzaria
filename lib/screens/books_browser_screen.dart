import 'package:flutter/material.dart';
import 'dart:io';

class BooksBrowser extends StatefulWidget {
  final void Function(String, int) openBookCallback;
  final void Function() closeLeftPaneCallback;
  final String libraryRootPath;

  const BooksBrowser(
      {Key? key,
      required this.openBookCallback,
      required this.libraryRootPath,
      required this.closeLeftPaneCallback})
      : super(key: key);

  @override
  BooksBrowserState createState() => BooksBrowserState();
}

class BooksBrowserState extends State<BooksBrowser> {
  late Directory directory;
  late List<FileSystemEntity> _fileList;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    _fileList =
        Directory(widget.libraryRootPath + Platform.pathSeparator + "אוצריא")
            .listSync()
            .toList();

    selectedIndex = 0;
  }

  void navigateUp() {
    if (directory.path.split(Platform.pathSeparator).last != "אוצריא") {
      setState(() {
        directory = directory.parent;
        _fileList = directory.listSync().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('דפדוף בספרייה'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_upward),
          tooltip: 'חזרה לתיקיה הקודמת',
          onPressed: navigateUp,
        ),
      ),
      body: Focus(
        focusNode: FocusNode(),
        autofocus: true,
        child: ListView.builder(
          itemCount: _fileList.length,
          itemBuilder: (context, index) {
            FileSystemEntity entity = _fileList[index];
            return ListTile(
              title: Text(entity.path.split(Platform.pathSeparator).last),
              leading: entity is Directory
                  ? const Icon(Icons.folder)
                  : const Icon(Icons.library_books),
              onTap: () {
                if (entity is Directory) {
                  setState(() {
                    directory = entity;
                    _fileList = Directory(entity.path).listSync().toList();
                  });
                } else if (entity is File) {
                  widget.closeLeftPaneCallback();
                  widget.openBookCallback(entity.path, 0);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
