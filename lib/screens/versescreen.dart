// ignore_for_file: non_constant_identifier_names, avoid_types_as_parameter_names, must_be_immutable, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:biblepics_tv_app/helper/database.dart';
import 'package:biblepics_tv_app/model/verse.dart';
import 'package:flutter/services.dart';

class VerseScreen extends StatefulWidget {
  final String book;
  final int chapter;
  late int nextCh;

  VerseScreen(
      {required this.book, required this.chapter, required this.nextCh});

  @override
  _VerseScreenState createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  bool controlsVisible = false;

  // Method to handle image load failure
  void _handleImageLoadFailure(int index) {}

  List<Verse> verses = [];
  PageController _pageController = PageController();
  int selectedCardIndex = 0;
  Timer? _autoPlayTimer;
  Timer? _controlsTimer;
  bool isPlaying = true;
  int totalSlides = 0;
  int remainingSlides = 0;
  late FocusNode _focusNode;
  void navigateToNextChapter(BuildContext context) {
    Navigator.pop(context);
    int newIndex = widget.nextCh;
    if (!(widget.nextCh == widget.chapter)) {
      newIndex = selectedCardIndex + 1;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerseScreen(
            book: widget.book,
            chapter: widget.nextCh,
            nextCh: newIndex,
          ),
        ),
      );
    }
  }

  void _changeFocus(int direction) {
    int newIndex = selectedCardIndex + direction;
    if (newIndex >= 0 && newIndex < verses.length) {
      setState(() {
        selectedCardIndex = newIndex;
        remainingSlides = totalSlides - newIndex - 1;
      });

      _pageController.animateToPage(
        selectedCardIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    if (newIndex == verses.length) {
      navigateToNextChapter(context);
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    fetchVerse(widget.book, widget.chapter).then((fetchedVerses) {
      setState(() {
        verses = fetchedVerses;
        totalSlides = verses.length;
        remainingSlides = totalSlides;
      });
    }).catchError((error) {
      print('An error occurred while fetching verses: $error');
    });

    _pageController = PageController();
    _autoPlayTimer = startAutoPlayTimer();
    _controlsTimer = startControlsTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    _controlsTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Timer startAutoPlayTimer() {
    return Timer.periodic(const Duration(seconds: 5), (timer) {
      _changeFocus(1);
    });
  }

  Timer startControlsTimer() {
    return Timer.periodic(const Duration(seconds: 5), (timer) {
      // Hide controls after 5 seconds of inactivity
      if (controlsVisible) {
        _hideControls();
      }
    });
  }

  void resetAutoPlayTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = startAutoPlayTimer();
  }

  void resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = startControlsTimer();
  }

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      resetAutoPlayTimer();
    } else {
      _autoPlayTimer?.cancel();
    }
  }

  void openVideoPlayerLayout() {
    setState(() {
      selectedCardIndex = _pageController.page?.toInt() ?? 0;
      remainingSlides = totalSlides - selectedCardIndex - 1;
      _showControls();
    });
  }

  void _showControls() {
    setState(() {
      controlsVisible = true;
    });
    _focusNode.requestFocus();
    resetControlsTimer();
  }

  void _hideControls() {
    setState(() {
      controlsVisible = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          resetControlsTimer(); // Restart the controls timer on any key press

          if (controlsVisible) {
            // If controls are visible, handle key events
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowRight:
                _changeFocus(1);
                resetAutoPlayTimer();
                break;
              case LogicalKeyboardKey.arrowLeft:
                _changeFocus(-1);
                resetAutoPlayTimer();
                break;
              case LogicalKeyboardKey.enter:
              case LogicalKeyboardKey.select:
                togglePlayPause();
                break;
              default:
                openVideoPlayerLayout();
                break;
            }
          } else {
            // If controls are not visible, show controls and start timer to hide them
            openVideoPlayerLayout();
            resetAutoPlayTimer();
          }
        }
      },
      focusNode: _focusNode,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // PageView
              PageView.builder(
                controller: _pageController,
                itemCount: verses.length,
                onPageChanged: (index) {
                  setState(() {
                    selectedCardIndex = index;
                    remainingSlides = totalSlides - index - 1;
                  });
                },
                itemBuilder: (context, index) {
                  return buildVerseCard(index);
                },
              ),

              if (controlsVisible) buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVerseCard(int index) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (verses[index].imagefound)
                Container(
                  width: MediaQuery.of(context).size.height * 0.65,
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      verses[index].imageurl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              (verses[index].imagefound)
                  ? const SizedBox(height: 10)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
              (!verses[index].imagefound)
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      width: MediaQuery.of(context).size.width * 0.6,
                      alignment: Alignment.center,
                      child: Text(
                        verses[index].versetext,
                        style: TextStyle(
                          fontFamily: "Cardo",
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        verses[index].versetext,
                        style: TextStyle(
                          fontFamily: "Cardo",
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    )
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(10),
              color: Colors.black,
              child: Text(
                "${widget.book}, ${widget.chapter}:${verses[selectedCardIndex].verse}",
                style: TextStyle(
                  fontFamily: "Cardo",
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildControlsOverlay() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back, size: 40, color: Colors.grey),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous,
                    size: 40, color: Colors.grey),
                onPressed: () {
                  _changeFocus(-1);
                  resetAutoPlayTimer();
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40, color: Colors.white),
                onPressed: () {
                  togglePlayPause();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 40, color: Colors.grey),
                onPressed: () {
                  _changeFocus(1);
                  resetAutoPlayTimer();
                },
              ),
            ],
          ),

          // Progress bar
          LinearProgressIndicator(
            value:
                totalSlides > 0 ? 1.0 - (remainingSlides / totalSlides) : 1.0,
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.grey.withOpacity(0.5)),
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
