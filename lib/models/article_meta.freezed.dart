// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ArticleMeta _$ArticleMetaFromJson(Map<String, dynamic> json) {
  return _ArticleMeta.fromJson(json);
}

/// @nodoc
mixin _$ArticleMeta {
  String get uuid => throw _privateConstructorUsedError; // ID des Ordners
  String get url => throw _privateConstructorUsedError;
  String get title =>
      throw _privateConstructorUsedError; // Nullable, da Parser sie vielleicht nicht findet
  String? get siteName => throw _privateConstructorUsedError;
  DateTime? get publishedAt =>
      throw _privateConstructorUsedError; // Standardwerte für Arrays, damit JSON sauber bleibt
  List<String> get authors => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get savedAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;

  /// Serializes this ArticleMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleMetaCopyWith<ArticleMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleMetaCopyWith<$Res> {
  factory $ArticleMetaCopyWith(
    ArticleMeta value,
    $Res Function(ArticleMeta) then,
  ) = _$ArticleMetaCopyWithImpl<$Res, ArticleMeta>;
  @useResult
  $Res call({
    String uuid,
    String url,
    String title,
    String? siteName,
    DateTime? publishedAt,
    List<String> authors,
    List<String> tags,
    DateTime savedAt,
    bool isRead,
    double progress,
  });
}

/// @nodoc
class _$ArticleMetaCopyWithImpl<$Res, $Val extends ArticleMeta>
    implements $ArticleMetaCopyWith<$Res> {
  _$ArticleMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? url = null,
    Object? title = null,
    Object? siteName = freezed,
    Object? publishedAt = freezed,
    Object? authors = null,
    Object? tags = null,
    Object? savedAt = null,
    Object? isRead = null,
    Object? progress = null,
  }) {
    return _then(
      _value.copyWith(
            uuid: null == uuid
                ? _value.uuid
                : uuid // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            siteName: freezed == siteName
                ? _value.siteName
                : siteName // ignore: cast_nullable_to_non_nullable
                      as String?,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            authors: null == authors
                ? _value.authors
                : authors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            savedAt: null == savedAt
                ? _value.savedAt
                : savedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleMetaImplCopyWith<$Res>
    implements $ArticleMetaCopyWith<$Res> {
  factory _$$ArticleMetaImplCopyWith(
    _$ArticleMetaImpl value,
    $Res Function(_$ArticleMetaImpl) then,
  ) = __$$ArticleMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uuid,
    String url,
    String title,
    String? siteName,
    DateTime? publishedAt,
    List<String> authors,
    List<String> tags,
    DateTime savedAt,
    bool isRead,
    double progress,
  });
}

/// @nodoc
class __$$ArticleMetaImplCopyWithImpl<$Res>
    extends _$ArticleMetaCopyWithImpl<$Res, _$ArticleMetaImpl>
    implements _$$ArticleMetaImplCopyWith<$Res> {
  __$$ArticleMetaImplCopyWithImpl(
    _$ArticleMetaImpl _value,
    $Res Function(_$ArticleMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? url = null,
    Object? title = null,
    Object? siteName = freezed,
    Object? publishedAt = freezed,
    Object? authors = null,
    Object? tags = null,
    Object? savedAt = null,
    Object? isRead = null,
    Object? progress = null,
  }) {
    return _then(
      _$ArticleMetaImpl(
        uuid: null == uuid
            ? _value.uuid
            : uuid // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        siteName: freezed == siteName
            ? _value.siteName
            : siteName // ignore: cast_nullable_to_non_nullable
                  as String?,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        authors: null == authors
            ? _value._authors
            : authors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        savedAt: null == savedAt
            ? _value.savedAt
            : savedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleMetaImpl implements _ArticleMeta {
  const _$ArticleMetaImpl({
    required this.uuid,
    required this.url,
    required this.title,
    this.siteName,
    this.publishedAt,
    final List<String> authors = const [],
    final List<String> tags = const [],
    required this.savedAt,
    this.isRead = false,
    this.progress = 0.0,
  }) : _authors = authors,
       _tags = tags;

  factory _$ArticleMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleMetaImplFromJson(json);

  @override
  final String uuid;
  // ID des Ordners
  @override
  final String url;
  @override
  final String title;
  // Nullable, da Parser sie vielleicht nicht findet
  @override
  final String? siteName;
  @override
  final DateTime? publishedAt;
  // Standardwerte für Arrays, damit JSON sauber bleibt
  final List<String> _authors;
  // Standardwerte für Arrays, damit JSON sauber bleibt
  @override
  @JsonKey()
  List<String> get authors {
    if (_authors is EqualUnmodifiableListView) return _authors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authors);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime savedAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final double progress;

  @override
  String toString() {
    return 'ArticleMeta(uuid: $uuid, url: $url, title: $title, siteName: $siteName, publishedAt: $publishedAt, authors: $authors, tags: $tags, savedAt: $savedAt, isRead: $isRead, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleMetaImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.siteName, siteName) ||
                other.siteName == siteName) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            const DeepCollectionEquality().equals(other._authors, _authors) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uuid,
    url,
    title,
    siteName,
    publishedAt,
    const DeepCollectionEquality().hash(_authors),
    const DeepCollectionEquality().hash(_tags),
    savedAt,
    isRead,
    progress,
  );

  /// Create a copy of ArticleMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleMetaImplCopyWith<_$ArticleMetaImpl> get copyWith =>
      __$$ArticleMetaImplCopyWithImpl<_$ArticleMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleMetaImplToJson(this);
  }
}

abstract class _ArticleMeta implements ArticleMeta {
  const factory _ArticleMeta({
    required final String uuid,
    required final String url,
    required final String title,
    final String? siteName,
    final DateTime? publishedAt,
    final List<String> authors,
    final List<String> tags,
    required final DateTime savedAt,
    final bool isRead,
    final double progress,
  }) = _$ArticleMetaImpl;

  factory _ArticleMeta.fromJson(Map<String, dynamic> json) =
      _$ArticleMetaImpl.fromJson;

  @override
  String get uuid; // ID des Ordners
  @override
  String get url;
  @override
  String get title; // Nullable, da Parser sie vielleicht nicht findet
  @override
  String? get siteName;
  @override
  DateTime? get publishedAt; // Standardwerte für Arrays, damit JSON sauber bleibt
  @override
  List<String> get authors;
  @override
  List<String> get tags;
  @override
  DateTime get savedAt;
  @override
  bool get isRead;
  @override
  double get progress;

  /// Create a copy of ArticleMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleMetaImplCopyWith<_$ArticleMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
