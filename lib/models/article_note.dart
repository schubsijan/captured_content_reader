import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_note.freezed.dart';
part 'article_note.g.dart';

@freezed
class ArticleNote with _$ArticleNote {
  const factory ArticleNote({
    required String id,
    required String content,
    required DateTime createdAt,
    @Default([]) List<String> tags,
  }) = _ArticleNote;

  factory ArticleNote.fromJson(Map<String, dynamic> json) =>
      _$ArticleNoteFromJson(json);
}
