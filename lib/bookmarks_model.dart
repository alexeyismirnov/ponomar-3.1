import 'package:easy_localization/easy_localization.dart';
import 'package:group_list_view/src/index_path.dart';

import 'dart:async';

import 'book_model.dart';
import 'globals.dart';

class BookmarksModel extends BookModel {
  static late List<BookModel> books;

  List<String> bookmarks = [];

  @override
  String get code => "Bookmarks";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "bookmarks".tr();

  @override
  String? author;

  @override
  String lang = "";

  @override
  bool get hasChapters => false;

  @override
  Future get initFuture => Future.value(null);

  BookmarksModel();

  @override
  List<String> getSections() => ConfigParamExt.bookmarks.val().length == 0 ? [] : [""];

  @override
  Future getContent(BookPosition pos) => Future.value(null);

  @override
  List<String> getItems(int section) {
    List<String> arr = [];
    bookmarks = [];

    for (var b in ConfigParamExt.bookmarks.val()) {
      try {
        final comp = b.split("_");
        final model = books.where((f) => f.code == comp[0]).first;

        bookmarks.add(b);
        arr.add(model.getBookmarkName(b));
      } catch (e) {
        print(e);
      }
    }

    return arr;
  }

  BookPosition? resolveBookmarkAt(int row) {
    try {
      final comp = bookmarks[row].split("_");
      final model = books.where((f) => f.code == comp[0]).first;
      final index = IndexPath(section: int.parse(comp[1]), index: int.parse(comp[2]));
      final chapter = comp.length == 4 ? int.parse(comp[3]) : 0;

      return BookPosition.modelIndex(model, index, chapter: chapter);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
