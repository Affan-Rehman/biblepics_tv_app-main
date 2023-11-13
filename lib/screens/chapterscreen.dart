// ignore_for_file: library_private_types_in_public_api

import 'package:biblepics_tv_app/model/chapter.dart';
import 'package:biblepics_tv_app/screens/versescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblepics_tv_app/helper/database.dart';

class ChaptersScreen extends StatefulWidget {
  final String book;

  ChaptersScreen({required this.book});

  @override
  _ChaptersScreenState createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  List<Chapter> chapters = [];
  ScrollController _scrollController = ScrollController();
  int selectedCardIndex = 0; // Track the index of the selected card
  FocusNode? initialFocusNode; // Add a FocusNode variable

  @override
  void initState() {
    super.initState();
    fetchChapters(widget.book).then((fetchedChapters) {
      setState(() {
        chapters = fetchedChapters;
        initialFocusNode = FocusNode(); // Initialize the initial focus node
      });
    }).catchError((error) {
      print('An error occurred while fetching chapters: $error');
    });

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    initialFocusNode?.dispose(); // Dispose of the initial focus node
    super.dispose();
  }

  void _handleArrowKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _changeFocus(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _changeFocus(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _navigateToVerseScreen();
      }
    }
  }

  void _changeFocus(int direction) {
    if (selectedCardIndex + direction >= 0 &&
        selectedCardIndex + direction < chapters.length) {
      // Change the focus
      setState(() {
        selectedCardIndex += direction;
      });

      // Calculate the target scroll position
      final targetPosition = _scrollController.position.pixels +
          direction * (_scrollController.position.viewportDimension - 20);

      // Smoothly scroll to the target position
      _scrollController.animateTo(
        targetPosition,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  void _navigateToVerseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseScreen(
          book: chapters[selectedCardIndex].book,
          chapter: chapters[selectedCardIndex].chapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chapters',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) => _handleArrowKey(event),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final isFocused = index == selectedCardIndex;

              return Focus(
                focusNode: index == 0 ? initialFocusNode : null,
                child: GestureDetector(
                  onTap: () {
                    _navigateToVerseScreen();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: isFocused ? 250 : 200,
                          height: isFocused ? 150 : 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: isFocused
                                ? Border.all(
                                    color: Colors.black.withOpacity(0.6),
                                    width: 2.0)
                                : null,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: isFocused
                                  ? Border.all(color: Colors.grey, width: 2.0)
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  isFocused ? 15.0 : 12.0),
                              child: Image.network(
                                chapters[index].imageurl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapters[index].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Opacity(
                                opacity: 0.6,
                                child: Text(
                                  chapters[index].summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
