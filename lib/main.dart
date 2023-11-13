// ignore_for_file: library_private_types_in_public_api

import 'package:biblepics_tv_app/helper/database.dart';
import 'package:biblepics_tv_app/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:biblepics_tv_app/model/book.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Book>>? booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks('Hebrew Bible');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: booksFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BiblePics TV App',
            theme: ThemeData(
              fontFamily: "Roboto",
              primarySwatch: Colors.deepPurple,
            ),
            home: HomeScreen(
              books: snapshot.data!,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
