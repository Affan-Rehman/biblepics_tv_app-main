class Verse {
  bool imageLoadFailed = false;
  final int id;
  final String book;
  final int chapter;
  final int verse;
  final String versetext;
  final String title;
  final String summary;
  final bool imagefound;
  final String imageurl;
  final int bible_version_id;
  final String figures;
  final String topics;

  Verse(
      {required this.id,
      required this.book,
      required this.chapter,
      required this.verse,
      required this.versetext,
      required this.title,
      required this.summary,
      required this.imagefound,
      required this.imageurl,
      required this.bible_version_id,
      required this.figures,
      required this.topics});
}
