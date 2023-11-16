// Import the postgres package
import 'package:biblepics_tv_app/model/chapter.dart';
import 'package:biblepics_tv_app/model/verse.dart';
import 'package:postgres/postgres.dart';
import 'package:biblepics_tv_app/model/book.dart';

// Function to connect to the database
Future<PostgreSQLConnection> connectToDB() async {
  var connection = PostgreSQLConnection(
    '35.170.207.144', // Replace with your host
    5432, // Replace with your port
    'bibleprod', // Replace with your database name
    username: 'bible', // Replace with your username
    password: 'tfYk@UQ5P96d', // Replace with your password
  );
  await connection.open();
  return connection;
}

// Function to perform a query
Future<List<Book>> fetchBooks(String partOf) async {
  var connection = await connectToDB();
  List<List<dynamic>> results = await connection.query(
      "SELECT * FROM playground_books ORDER BY bookid",
      substitutionValues: {
        'partOf': partOf,
      });
  List<Book> books = results.map((row) {
    return Book(
      id: row[0],
      title: row[1],
      imageUrl:
          '${'${'https://d3owcl6pd5zkqc.cloudfront.net/images/' + row[1]}/' + row[1]}.webp',
      summary: row[4],
      estimatedtime: row[6],
      keyfigures: row[5],
      // Add other fields as necessary
    );
  }).toList();

  await connection.close();

  return books;
}

// Function to perform a query
Future<List<Chapter>> fetchChapters(String book) async {
  var connection = await connectToDB();
  List<List<dynamic>> results = await connection.query(
      "SELECT * FROM playground_chap_titles WHERE book = @book ORDER BY id",
      substitutionValues: {
        'book': book,
      });

  List<Chapter> chapters = results.map((row) {
    return Chapter(
      id: row[0],
      book: row[1],
      chapter: row[2],
      title: row[3],
      summary: row[4],
      number_of_verses: row[5],
      time_to_read: row[6],
      figures: row[7],
      commentary: row[8],
      imageurl: row[9],
    );
  }).toList();

  await connection.close();

  return chapters;
}

// Function to perform a query
Future<List<Verse>> fetchVerse(String book, int chapter) async {
  var connection = await connectToDB();
  List<List<dynamic>> results = await connection.query(
      "SELECT * FROM playground_verses WHERE book = @book AND chapter = @chapter ORDER BY id",
      substitutionValues: {
        'book': book,
        'chapter': chapter,
      });

  List<Verse> verses = results.map((row) {
    return Verse(
      id: row[0],
      book: row[1],
      chapter: row[2],
      verse: row[3],
      versetext: row[4],
      title: row[5],
      summary: row[6],
      imagefound: row[7],
      imageurl: row[8],
      bible_version_id: row[9],
      figures: row[10],
      topics: row[11],
    );
  }).toList();

  await connection.close();

  return verses;
}
