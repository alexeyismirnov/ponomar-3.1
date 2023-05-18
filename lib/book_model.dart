import 'package:group_list_view/group_list_view.dart';
import 'package:quiver/core.dart';

enum BookContentType { text, html }

class BookPosition {
  BookModel? model;
  IndexPath? index;
  int? chapter;
  String? location;
  dynamic data;

  BookPosition.modelIndex(this.model, this.index, {this.chapter = 0});
  BookPosition.location(this.model, this.location);
  BookPosition.data(this.model, this.data);
  BookPosition.index(this.index, {this.chapter = 0});

  @override
  bool operator ==(covariant BookPosition other) =>
      other.index!.section == index!.section &&
      other.index!.index == index!.index &&
      other.chapter == chapter;

  @override
  int get hashCode => hash3(index!.section.hashCode, index!.index.hashCode, chapter.hashCode);
}

abstract class BookModel {
  String get code;
  BookContentType get contentType;
  String get title;
  String? get author;

  String get lang;
  bool get hasChapters;

  Future get initFuture;

  Future prepare() {
    return Future.value(null);
  }

  List<String> getSections();
  List<String> getItems(int section);

  Future<int> getNumChapters(IndexPath index);

  Future<String> getTitle(BookPosition pos) {
    return Future<String>.value("");
  }

  Future<String?> getComment(int commentId) {
    return Future<String?>.value(null);
  }

  Future<dynamic> getContent(BookPosition pos);

  BookPosition? getNextSection(BookPosition pos) {
    return null;
  }

  BookPosition? getPrevSection(BookPosition pos) {
    return null;
  }

  String? getBookmark(BookPosition pos) {
    return null;
  }

  String getBookmarkName(String bookmark) {
    return "";
  }
}
