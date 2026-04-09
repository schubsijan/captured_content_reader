// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ArticleNote _$ArticleNoteFromJson(Map<String, dynamic> json) {
  return _ArticleNote.fromJson(json);
}

/// @nodoc
mixin _$ArticleNote {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this ArticleNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleNoteCopyWith<ArticleNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleNoteCopyWith<$Res> {
  factory $ArticleNoteCopyWith(
    ArticleNote value,
    $Res Function(ArticleNote) then,
  ) = _$ArticleNoteCopyWithImpl<$Res, ArticleNote>;
  @useResult
  $Res call({String id, String content, DateTime createdAt, List<String> tags});
}

/// @nodoc
class _$ArticleNoteCopyWithImpl<$Res, $Val extends ArticleNote>
    implements $ArticleNoteCopyWith<$Res> {
  _$ArticleNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? createdAt = null,
    Object? tags = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleNoteImplCopyWith<$Res>
    implements $ArticleNoteCopyWith<$Res> {
  factory _$$ArticleNoteImplCopyWith(
    _$ArticleNoteImpl value,
    $Res Function(_$ArticleNoteImpl) then,
  ) = __$$ArticleNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String content, DateTime createdAt, List<String> tags});
}

/// @nodoc
class __$$ArticleNoteImplCopyWithImpl<$Res>
    extends _$ArticleNoteCopyWithImpl<$Res, _$ArticleNoteImpl>
    implements _$$ArticleNoteImplCopyWith<$Res> {
  __$$ArticleNoteImplCopyWithImpl(
    _$ArticleNoteImpl _value,
    $Res Function(_$ArticleNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? createdAt = null,
    Object? tags = null,
  }) {
    return _then(
      _$ArticleNoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleNoteImpl implements _ArticleNote {
  const _$ArticleNoteImpl({
    required this.id,
    required this.content,
    required this.createdAt,
    final List<String> tags = const [],
  }) : _tags = tags;

  factory _$ArticleNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleNoteImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final DateTime createdAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'ArticleNote(id: $id, content: $content, createdAt: $createdAt, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    content,
    createdAt,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of ArticleNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleNoteImplCopyWith<_$ArticleNoteImpl> get copyWith =>
      __$$ArticleNoteImplCopyWithImpl<_$ArticleNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleNoteImplToJson(this);
  }
}

abstract class _ArticleNote implements ArticleNote {
  const factory _ArticleNote({
    required final String id,
    required final String content,
    required final DateTime createdAt,
    final List<String> tags,
  }) = _$ArticleNoteImpl;

  factory _ArticleNote.fromJson(Map<String, dynamic> json) =
      _$ArticleNoteImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  List<String> get tags;

  /// Create a copy of ArticleNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleNoteImplCopyWith<_$ArticleNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
