// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleMetaImpl _$$ArticleMetaImplFromJson(Map<String, dynamic> json) =>
    _$ArticleMetaImpl(
      uuid: json['uuid'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      siteName: json['siteName'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      savedAt: DateTime.parse(json['savedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$ArticleMetaImplToJson(_$ArticleMetaImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'url': instance.url,
      'title': instance.title,
      'siteName': instance.siteName,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'authors': instance.authors,
      'tags': instance.tags,
      'savedAt': instance.savedAt.toIso8601String(),
      'isRead': instance.isRead,
      'progress': instance.progress,
    };
