class Book {
  final int id;
  final String book;
  final int lastchapter;
  final String title;
  final String imageUrl;
  final String summary;
  final String partof;
  final int timetoread;
  final String estimatedtime;
  final String keyfigures;

  Book(
      {required this.id,
      required this.book,
      required this.lastchapter,
      required this.title,
      required this.imageUrl,
      required this.summary,
      required this.partof,
      required this.timetoread,
      required this.estimatedtime,
      required this.keyfigures});
}
