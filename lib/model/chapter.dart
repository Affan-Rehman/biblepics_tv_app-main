class Chapter {
  final int id;
  final String book;
  final int chapter;
  final String title;
  final String summary;
  final int number_of_verses;
  final int time_to_read;
  final String figures;
  final String commentary;
  final String imageurl;

  Chapter(
      {required this.id,
      required this.book,
      required this.chapter,
      required this.title,
      required this.summary,
      required this.number_of_verses,
      required this.time_to_read,
      required this.figures,
      required this.commentary,
      required this.imageurl});
}
