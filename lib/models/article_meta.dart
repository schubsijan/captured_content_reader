import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_meta.freezed.dart';
part 'article_meta.g.dart';

@freezed
class ArticleMeta with _$ArticleMeta {
  const factory ArticleMeta({
    required String uuid, // ID des Ordners
    required String url,
    required String title,

    // Nullable, da Parser sie vielleicht nicht findet
    String? siteName,
    DateTime? publishedAt,

    // Standardwerte für Arrays, damit JSON sauber bleibt
    @Default([]) List<String> authors,
    @Default([]) List<String> tags,

    required DateTime savedAt,

    @Default(false) bool isRead,
    @Default(0.0) double progress,
  }) = _ArticleMeta;

  factory ArticleMeta.fromJson(Map<String, dynamic> json) =>
      _$ArticleMetaFromJson(json);
}
