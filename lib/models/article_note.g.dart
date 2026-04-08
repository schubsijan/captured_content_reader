// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleNoteImpl _$$ArticleNoteImplFromJson(Map<String, dynamic> json) =>
    _$ArticleNoteImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ArticleNoteImplToJson(_$ArticleNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
