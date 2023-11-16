// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblepics_tv_app/model/book.dart';
import 'package:biblepics_tv_app/screens/chapterscreen.dart';

class HomeScreen extends StatefulWidget {
  final List<Book> books;

  const HomeScreen({required this.books});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _focusNode = FocusNode();
  int selectedBookIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _firstBookKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set initial focus to the first book icon when the app launches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToSelectedBook() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        selectedBookIndex * 220.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Colors.black),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/genesis.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.54, 0.76),
                          radius: 1,
                          colors: [Color(0x19131314), Color(0xFF131314)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.63,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Creation • ${widget.books[selectedBookIndex].estimatedtime} • ",
                              style: TextStyle(
                                color: const Color(0xFFC4C7C5).withOpacity(0.6),
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.books[selectedBookIndex].title,
                              style: const TextStyle(
                                color: Color(0xFFE2E2E2),
                                fontSize: 36,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Text(
                                widget.books[selectedBookIndex].summary,
                                style: TextStyle(
                                  color:
                                      const Color(0xFFC4C7C5).withOpacity(0.6),
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Focus(
                    focusNode: _focusNode,
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                          if (selectedBookIndex < widget.books.length - 1) {
                            setState(() {
                              selectedBookIndex++;
                            });
                            scrollToSelectedBook();
                          }
                          return KeyEventResult.handled;
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.arrowLeft) {
                          if (selectedBookIndex > 0) {
                            setState(() {
                              selectedBookIndex--;
                            });
                            scrollToSelectedBook();
                          }
                          return KeyEventResult.handled;
                        }
                        if (event.logicalKey == LogicalKeyboardKey.enter ||
                            event.logicalKey == LogicalKeyboardKey.select) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChaptersScreen(
                                book: widget.books[selectedBookIndex].title,
                              ),
                            ),
                          );
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.books.length,
                      itemBuilder: (context, index) {
                        final isFocused = index == selectedBookIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBookIndex = index;
                            });
                            scrollToSelectedBook();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              key: isFocused ? _firstBookKey : null,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: isFocused ? 250 : 220,
                                    height: isFocused ? 150 : 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        widget.books[index].imageUrl,
                                        width: 220,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          if (error
                                                  is NetworkImageLoadException &&
                                              error.statusCode == 403) {
                                            return Image.asset(
                                              "assets/images/placeholder.webp",
                                              width: 220,
                                              height: 120,
                                              fit: BoxFit.fill,
                                            );
                                          } else {
                                            return Image.asset(
                                              "assets/images/placeholder.webp",
                                              width: 220,
                                              height: 120,
                                              fit: BoxFit.fill,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  if (isFocused)
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 1, end: 1.1),
                                      duration:
                                          const Duration(milliseconds: 50),
                                      builder: (context, scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        width: 226,
                                        height: 137,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                            ),
                                          ],
                                        ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
