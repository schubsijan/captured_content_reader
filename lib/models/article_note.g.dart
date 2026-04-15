// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ArticleNote _$ArticleNoteFromJson(Map<String, dynamic> json) => _ArticleNote(
  id: json['id'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ArticleNoteToJson(_ArticleNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
    };
