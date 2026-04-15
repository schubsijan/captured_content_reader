import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_meta.freezed.dart';
part 'article_meta.g.dart';

@freezed
abstract class ArticleMeta with _$ArticleMeta {
  // <--- 'abstract' hinzufügen
  const factory ArticleMeta({
    required String uuid,
    required String url,
    required String title,
    String? siteName,
    DateTime? publishedAt,
    @Default([]) List<String> authors,
    @Default([]) List<String> tags,
    required DateTime savedAt,
    @Default(false) bool isRead,
    @Default(0.0) double progress,
    String? note,
  }) = _ArticleMeta;

  factory ArticleMeta.fromJson(Map<String, dynamic> json) =>
      _$ArticleMetaFromJson(json);
}
