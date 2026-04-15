// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArticleNote {

 String get id; String get content; DateTime get createdAt; List<String> get tags;
/// Create a copy of ArticleNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleNoteCopyWith<ArticleNote> get copyWith => _$ArticleNoteCopyWithImpl<ArticleNote>(this as ArticleNote, _$identity);

  /// Serializes this ArticleNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArticleNote&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,createdAt,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ArticleNote(id: $id, content: $content, createdAt: $createdAt, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ArticleNoteCopyWith<$Res>  {
  factory $ArticleNoteCopyWith(ArticleNote value, $Res Function(ArticleNote) _then) = _$ArticleNoteCopyWithImpl;
@useResult
$Res call({
 String id, String content, DateTime createdAt, List<String> tags
});




}
/// @nodoc
class _$ArticleNoteCopyWithImpl<$Res>
    implements $ArticleNoteCopyWith<$Res> {
  _$ArticleNoteCopyWithImpl(this._self, this._then);

  final ArticleNote _self;
  final $Res Function(ArticleNote) _then;

/// Create a copy of ArticleNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? createdAt = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ArticleNote].
extension ArticleNotePatterns on ArticleNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArticleNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArticleNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArticleNote value)  $default,){
final _that = this;
switch (_that) {
case _ArticleNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArticleNote value)?  $default,){
final _that = this;
switch (_that) {
case _ArticleNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  DateTime createdAt,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArticleNote() when $default != null:
return $default(_that.id,_that.content,_that.createdAt,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  DateTime createdAt,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _ArticleNote():
return $default(_that.id,_that.content,_that.createdAt,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  DateTime createdAt,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _ArticleNote() when $default != null:
return $default(_that.id,_that.content,_that.createdAt,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArticleNote implements ArticleNote {
  const _ArticleNote({required this.id, required this.content, required this.createdAt, final  List<String> tags = const []}): _tags = tags;
  factory _ArticleNote.fromJson(Map<String, dynamic> json) => _$ArticleNoteFromJson(json);

@override final  String id;
@override final  String content;
@override final  DateTime createdAt;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of ArticleNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleNoteCopyWith<_ArticleNote> get copyWith => __$ArticleNoteCopyWithImpl<_ArticleNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArticleNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticleNote&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,createdAt,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ArticleNote(id: $id, content: $content, createdAt: $createdAt, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ArticleNoteCopyWith<$Res> implements $ArticleNoteCopyWith<$Res> {
  factory _$ArticleNoteCopyWith(_ArticleNote value, $Res Function(_ArticleNote) _then) = __$ArticleNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, DateTime createdAt, List<String> tags
});




}
/// @nodoc
class __$ArticleNoteCopyWithImpl<$Res>
    implements _$ArticleNoteCopyWith<$Res> {
  __$ArticleNoteCopyWithImpl(this._self, this._then);

  final _ArticleNote _self;
  final $Res Function(_ArticleNote) _then;

/// Create a copy of ArticleNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? createdAt = null,Object? tags = null,}) {
  return _then(_ArticleNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
