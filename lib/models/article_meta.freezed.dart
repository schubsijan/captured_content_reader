// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArticleMeta {

 String get uuid; String get url; String get title; String? get siteName; DateTime? get publishedAt; List<String> get authors; List<String> get tags; DateTime get savedAt; bool get isRead; double get progress; String? get note;
/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleMetaCopyWith<ArticleMeta> get copyWith => _$ArticleMetaCopyWithImpl<ArticleMeta>(this as ArticleMeta, _$identity);

  /// Serializes this ArticleMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArticleMeta&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&const DeepCollectionEquality().equals(other.authors, authors)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,url,title,siteName,publishedAt,const DeepCollectionEquality().hash(authors),const DeepCollectionEquality().hash(tags),savedAt,isRead,progress,note);

@override
String toString() {
  return 'ArticleMeta(uuid: $uuid, url: $url, title: $title, siteName: $siteName, publishedAt: $publishedAt, authors: $authors, tags: $tags, savedAt: $savedAt, isRead: $isRead, progress: $progress, note: $note)';
}


}

/// @nodoc
abstract mixin class $ArticleMetaCopyWith<$Res>  {
  factory $ArticleMetaCopyWith(ArticleMeta value, $Res Function(ArticleMeta) _then) = _$ArticleMetaCopyWithImpl;
@useResult
$Res call({
 String uuid, String url, String title, String? siteName, DateTime? publishedAt, List<String> authors, List<String> tags, DateTime savedAt, bool isRead, double progress, String? note
});




}
/// @nodoc
class _$ArticleMetaCopyWithImpl<$Res>
    implements $ArticleMetaCopyWith<$Res> {
  _$ArticleMetaCopyWithImpl(this._self, this._then);

  final ArticleMeta _self;
  final $Res Function(ArticleMeta) _then;

/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? url = null,Object? title = null,Object? siteName = freezed,Object? publishedAt = freezed,Object? authors = null,Object? tags = null,Object? savedAt = null,Object? isRead = null,Object? progress = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArticleMeta].
extension ArticleMetaPatterns on ArticleMeta {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArticleMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArticleMeta value)  $default,){
final _that = this;
switch (_that) {
case _ArticleMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArticleMeta value)?  $default,){
final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String url,  String title,  String? siteName,  DateTime? publishedAt,  List<String> authors,  List<String> tags,  DateTime savedAt,  bool isRead,  double progress,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
return $default(_that.uuid,_that.url,_that.title,_that.siteName,_that.publishedAt,_that.authors,_that.tags,_that.savedAt,_that.isRead,_that.progress,_that.note);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String url,  String title,  String? siteName,  DateTime? publishedAt,  List<String> authors,  List<String> tags,  DateTime savedAt,  bool isRead,  double progress,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ArticleMeta():
return $default(_that.uuid,_that.url,_that.title,_that.siteName,_that.publishedAt,_that.authors,_that.tags,_that.savedAt,_that.isRead,_that.progress,_that.note);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String url,  String title,  String? siteName,  DateTime? publishedAt,  List<String> authors,  List<String> tags,  DateTime savedAt,  bool isRead,  double progress,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ArticleMeta() when $default != null:
return $default(_that.uuid,_that.url,_that.title,_that.siteName,_that.publishedAt,_that.authors,_that.tags,_that.savedAt,_that.isRead,_that.progress,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArticleMeta implements ArticleMeta {
  const _ArticleMeta({required this.uuid, required this.url, required this.title, this.siteName, this.publishedAt, final  List<String> authors = const [], final  List<String> tags = const [], required this.savedAt, this.isRead = false, this.progress = 0.0, this.note}): _authors = authors,_tags = tags;
  factory _ArticleMeta.fromJson(Map<String, dynamic> json) => _$ArticleMetaFromJson(json);

@override final  String uuid;
@override final  String url;
@override final  String title;
@override final  String? siteName;
@override final  DateTime? publishedAt;
 final  List<String> _authors;
@override@JsonKey() List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  DateTime savedAt;
@override@JsonKey() final  bool isRead;
@override@JsonKey() final  double progress;
@override final  String? note;

/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleMetaCopyWith<_ArticleMeta> get copyWith => __$ArticleMetaCopyWithImpl<_ArticleMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArticleMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticleMeta&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&const DeepCollectionEquality().equals(other._authors, _authors)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,url,title,siteName,publishedAt,const DeepCollectionEquality().hash(_authors),const DeepCollectionEquality().hash(_tags),savedAt,isRead,progress,note);

@override
String toString() {
  return 'ArticleMeta(uuid: $uuid, url: $url, title: $title, siteName: $siteName, publishedAt: $publishedAt, authors: $authors, tags: $tags, savedAt: $savedAt, isRead: $isRead, progress: $progress, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ArticleMetaCopyWith<$Res> implements $ArticleMetaCopyWith<$Res> {
  factory _$ArticleMetaCopyWith(_ArticleMeta value, $Res Function(_ArticleMeta) _then) = __$ArticleMetaCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String url, String title, String? siteName, DateTime? publishedAt, List<String> authors, List<String> tags, DateTime savedAt, bool isRead, double progress, String? note
});




}
/// @nodoc
class __$ArticleMetaCopyWithImpl<$Res>
    implements _$ArticleMetaCopyWith<$Res> {
  __$ArticleMetaCopyWithImpl(this._self, this._then);

  final _ArticleMeta _self;
  final $Res Function(_ArticleMeta) _then;

/// Create a copy of ArticleMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? url = null,Object? title = null,Object? siteName = freezed,Object? publishedAt = freezed,Object? authors = null,Object? tags = null,Object? savedAt = null,Object? isRead = null,Object? progress = null,Object? note = freezed,}) {
  return _then(_ArticleMeta(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
