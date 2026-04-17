// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ArticleMeta _$ArticleMetaFromJson(Map<String, dynamic> json) => _ArticleMeta(
  uuid: json['uuid'] as String,
  url: json['url'] as String,
  title: json['title'] as String,
  siteName: json['siteName'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.tryParse(json['publishedAt'] as String? ?? ''),
  authors:
      (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  savedAt: DateTime.parse(json['savedAt'] as String),
  // Migration: Wenn readAt fehlt aber isRead=true, setze readAt auf savedAt (mit Fehlerbehandlung)
  readAt: json['readAt'] != null
      ? DateTime.tryParse(json['readAt'] as String? ?? '')
      : (json['isRead'] == true
          ? (DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now())
          : null),
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  note: json['note'] as String?,
);

Map<String, dynamic> _$ArticleMetaToJson(_ArticleMeta instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'url': instance.url,
      'title': instance.title,
      'siteName': instance.siteName,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'authors': instance.authors,
      'tags': instance.tags,
      'savedAt': instance.savedAt.toIso8601String(),
      // Rückwärtskompatibilität: isRead als bool speichern
      'isRead': instance.isRead,
      // readAt speichern (oder now wenn isRead true aber readAt null - sollte nicht passieren)
      'readAt': instance.readAt?.toIso8601String() ??
          (instance.isRead ? DateTime.now().toIso8601String() : null),
      'progress': instance.progress,
      'note': instance.note,
    };
