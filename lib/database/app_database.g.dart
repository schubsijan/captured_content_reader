// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ArticlesTable extends Articles with TableInfo<$ArticlesTable, Article> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fileLastModifiedMeta = const VerificationMeta(
    'fileLastModified',
  );
  @override
  late final GeneratedColumn<DateTime> fileLastModified =
      GeneratedColumn<DateTime>(
        'file_last_modified',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    siteName,
    publishedAt,
    savedAt,
    isRead,
    progress,
    fileLastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Article> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('file_last_modified')) {
      context.handle(
        _fileLastModifiedMeta,
        fileLastModified.isAcceptableOrUnknown(
          data['file_last_modified']!,
          _fileLastModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Article map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Article(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      fileLastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}file_last_modified'],
      ),
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class Article extends DataClass implements Insertable<Article> {
  final String id;
  final String title;
  final String url;
  final String? siteName;
  final DateTime? publishedAt;
  final DateTime savedAt;
  final bool isRead;
  final double progress;
  final DateTime? fileLastModified;
  const Article({
    required this.id,
    required this.title,
    required this.url,
    this.siteName,
    this.publishedAt,
    required this.savedAt,
    required this.isRead,
    required this.progress,
    this.fileLastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || siteName != null) {
      map['site_name'] = Variable<String>(siteName);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['is_read'] = Variable<bool>(isRead);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || fileLastModified != null) {
      map['file_last_modified'] = Variable<DateTime>(fileLastModified);
    }
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      siteName: siteName == null && nullToAbsent
          ? const Value.absent()
          : Value(siteName),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      savedAt: Value(savedAt),
      isRead: Value(isRead),
      progress: Value(progress),
      fileLastModified: fileLastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(fileLastModified),
    );
  }

  factory Article.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Article(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      siteName: serializer.fromJson<String?>(json['siteName']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      progress: serializer.fromJson<double>(json['progress']),
      fileLastModified: serializer.fromJson<DateTime?>(
        json['fileLastModified'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'siteName': serializer.toJson<String?>(siteName),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'progress': serializer.toJson<double>(progress),
      'fileLastModified': serializer.toJson<DateTime?>(fileLastModified),
    };
  }

  Article copyWith({
    String? id,
    String? title,
    String? url,
    Value<String?> siteName = const Value.absent(),
    Value<DateTime?> publishedAt = const Value.absent(),
    DateTime? savedAt,
    bool? isRead,
    double? progress,
    Value<DateTime?> fileLastModified = const Value.absent(),
  }) => Article(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    siteName: siteName.present ? siteName.value : this.siteName,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    savedAt: savedAt ?? this.savedAt,
    isRead: isRead ?? this.isRead,
    progress: progress ?? this.progress,
    fileLastModified: fileLastModified.present
        ? fileLastModified.value
        : this.fileLastModified,
  );
  Article copyWithCompanion(ArticlesCompanion data) {
    return Article(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      progress: data.progress.present ? data.progress.value : this.progress,
      fileLastModified: data.fileLastModified.present
          ? data.fileLastModified.value
          : this.fileLastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Article(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('siteName: $siteName, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('isRead: $isRead, ')
          ..write('progress: $progress, ')
          ..write('fileLastModified: $fileLastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    url,
    siteName,
    publishedAt,
    savedAt,
    isRead,
    progress,
    fileLastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Article &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.siteName == this.siteName &&
          other.publishedAt == this.publishedAt &&
          other.savedAt == this.savedAt &&
          other.isRead == this.isRead &&
          other.progress == this.progress &&
          other.fileLastModified == this.fileLastModified);
}

class ArticlesCompanion extends UpdateCompanion<Article> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> siteName;
  final Value<DateTime?> publishedAt;
  final Value<DateTime> savedAt;
  final Value<bool> isRead;
  final Value<double> progress;
  final Value<DateTime?> fileLastModified;
  final Value<int> rowid;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.siteName = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.progress = const Value.absent(),
    this.fileLastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticlesCompanion.insert({
    required String id,
    required String title,
    required String url,
    this.siteName = const Value.absent(),
    this.publishedAt = const Value.absent(),
    required DateTime savedAt,
    this.isRead = const Value.absent(),
    this.progress = const Value.absent(),
    this.fileLastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       url = Value(url),
       savedAt = Value(savedAt);
  static Insertable<Article> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? siteName,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? savedAt,
    Expression<bool>? isRead,
    Expression<double>? progress,
    Expression<DateTime>? fileLastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (siteName != null) 'site_name': siteName,
      if (publishedAt != null) 'published_at': publishedAt,
      if (savedAt != null) 'saved_at': savedAt,
      if (isRead != null) 'is_read': isRead,
      if (progress != null) 'progress': progress,
      if (fileLastModified != null) 'file_last_modified': fileLastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticlesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? url,
    Value<String?>? siteName,
    Value<DateTime?>? publishedAt,
    Value<DateTime>? savedAt,
    Value<bool>? isRead,
    Value<double>? progress,
    Value<DateTime?>? fileLastModified,
    Value<int>? rowid,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      siteName: siteName ?? this.siteName,
      publishedAt: publishedAt ?? this.publishedAt,
      savedAt: savedAt ?? this.savedAt,
      isRead: isRead ?? this.isRead,
      progress: progress ?? this.progress,
      fileLastModified: fileLastModified ?? this.fileLastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (fileLastModified.present) {
      map['file_last_modified'] = Variable<DateTime>(fileLastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('siteName: $siteName, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('isRead: $isRead, ')
          ..write('progress: $progress, ')
          ..write('fileLastModified: $fileLastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagIndexTable extends TagIndex
    with TableInfo<$TagIndexTable, TagIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [name, articleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name, articleId};
  @override
  TagIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagIndexData(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
    );
  }

  @override
  $TagIndexTable createAlias(String alias) {
    return $TagIndexTable(attachedDatabase, alias);
  }
}

class TagIndexData extends DataClass implements Insertable<TagIndexData> {
  final String name;
  final String articleId;
  const TagIndexData({required this.name, required this.articleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['article_id'] = Variable<String>(articleId);
    return map;
  }

  TagIndexCompanion toCompanion(bool nullToAbsent) {
    return TagIndexCompanion(name: Value(name), articleId: Value(articleId));
  }

  factory TagIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagIndexData(
      name: serializer.fromJson<String>(json['name']),
      articleId: serializer.fromJson<String>(json['articleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'articleId': serializer.toJson<String>(articleId),
    };
  }

  TagIndexData copyWith({String? name, String? articleId}) => TagIndexData(
    name: name ?? this.name,
    articleId: articleId ?? this.articleId,
  );
  TagIndexData copyWithCompanion(TagIndexCompanion data) {
    return TagIndexData(
      name: data.name.present ? data.name.value : this.name,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagIndexData(')
          ..write('name: $name, ')
          ..write('articleId: $articleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, articleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagIndexData &&
          other.name == this.name &&
          other.articleId == this.articleId);
}

class TagIndexCompanion extends UpdateCompanion<TagIndexData> {
  final Value<String> name;
  final Value<String> articleId;
  final Value<int> rowid;
  const TagIndexCompanion({
    this.name = const Value.absent(),
    this.articleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagIndexCompanion.insert({
    required String name,
    required String articleId,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       articleId = Value(articleId);
  static Insertable<TagIndexData> custom({
    Expression<String>? name,
    Expression<String>? articleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (articleId != null) 'article_id': articleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagIndexCompanion copyWith({
    Value<String>? name,
    Value<String>? articleId,
    Value<int>? rowid,
  }) {
    return TagIndexCompanion(
      name: name ?? this.name,
      articleId: articleId ?? this.articleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagIndexCompanion(')
          ..write('name: $name, ')
          ..write('articleId: $articleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthorIndexTable extends AuthorIndex
    with TableInfo<$AuthorIndexTable, AuthorIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthorIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleIdMeta = const VerificationMeta(
    'articleId',
  );
  @override
  late final GeneratedColumn<String> articleId = GeneratedColumn<String>(
    'article_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES articles (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [name, articleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'author_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthorIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('article_id')) {
      context.handle(
        _articleIdMeta,
        articleId.isAcceptableOrUnknown(data['article_id']!, _articleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_articleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name, articleId};
  @override
  AuthorIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthorIndexData(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      articleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_id'],
      )!,
    );
  }

  @override
  $AuthorIndexTable createAlias(String alias) {
    return $AuthorIndexTable(attachedDatabase, alias);
  }
}

class AuthorIndexData extends DataClass implements Insertable<AuthorIndexData> {
  final String name;
  final String articleId;
  const AuthorIndexData({required this.name, required this.articleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['article_id'] = Variable<String>(articleId);
    return map;
  }

  AuthorIndexCompanion toCompanion(bool nullToAbsent) {
    return AuthorIndexCompanion(name: Value(name), articleId: Value(articleId));
  }

  factory AuthorIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthorIndexData(
      name: serializer.fromJson<String>(json['name']),
      articleId: serializer.fromJson<String>(json['articleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'articleId': serializer.toJson<String>(articleId),
    };
  }

  AuthorIndexData copyWith({String? name, String? articleId}) =>
      AuthorIndexData(
        name: name ?? this.name,
        articleId: articleId ?? this.articleId,
      );
  AuthorIndexData copyWithCompanion(AuthorIndexCompanion data) {
    return AuthorIndexData(
      name: data.name.present ? data.name.value : this.name,
      articleId: data.articleId.present ? data.articleId.value : this.articleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthorIndexData(')
          ..write('name: $name, ')
          ..write('articleId: $articleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, articleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthorIndexData &&
          other.name == this.name &&
          other.articleId == this.articleId);
}

class AuthorIndexCompanion extends UpdateCompanion<AuthorIndexData> {
  final Value<String> name;
  final Value<String> articleId;
  final Value<int> rowid;
  const AuthorIndexCompanion({
    this.name = const Value.absent(),
    this.articleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthorIndexCompanion.insert({
    required String name,
    required String articleId,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       articleId = Value(articleId);
  static Insertable<AuthorIndexData> custom({
    Expression<String>? name,
    Expression<String>? articleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (articleId != null) 'article_id': articleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthorIndexCompanion copyWith({
    Value<String>? name,
    Value<String>? articleId,
    Value<int>? rowid,
  }) {
    return AuthorIndexCompanion(
      name: name ?? this.name,
      articleId: articleId ?? this.articleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (articleId.present) {
      map['article_id'] = Variable<String>(articleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthorIndexCompanion(')
          ..write('name: $name, ')
          ..write('articleId: $articleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $TagIndexTable tagIndex = $TagIndexTable(this);
  late final $AuthorIndexTable authorIndex = $AuthorIndexTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    articles,
    tagIndex,
    authorIndex,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tag_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'articles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('author_index', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ArticlesTableCreateCompanionBuilder =
    ArticlesCompanion Function({
      required String id,
      required String title,
      required String url,
      Value<String?> siteName,
      Value<DateTime?> publishedAt,
      required DateTime savedAt,
      Value<bool> isRead,
      Value<double> progress,
      Value<DateTime?> fileLastModified,
      Value<int> rowid,
    });
typedef $$ArticlesTableUpdateCompanionBuilder =
    ArticlesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> url,
      Value<String?> siteName,
      Value<DateTime?> publishedAt,
      Value<DateTime> savedAt,
      Value<bool> isRead,
      Value<double> progress,
      Value<DateTime?> fileLastModified,
      Value<int> rowid,
    });

final class $$ArticlesTableReferences
    extends BaseReferences<_$AppDatabase, $ArticlesTable, Article> {
  $$ArticlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TagIndexTable, List<TagIndexData>>
  _tagIndexRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tagIndex,
    aliasName: $_aliasNameGenerator(db.articles.id, db.tagIndex.articleId),
  );

  $$TagIndexTableProcessedTableManager get tagIndexRefs {
    final manager = $$TagIndexTableTableManager(
      $_db,
      $_db.tagIndex,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tagIndexRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuthorIndexTable, List<AuthorIndexData>>
  _authorIndexRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.authorIndex,
    aliasName: $_aliasNameGenerator(db.articles.id, db.authorIndex.articleId),
  );

  $$AuthorIndexTableProcessedTableManager get authorIndexRefs {
    final manager = $$AuthorIndexTableTableManager(
      $_db,
      $_db.authorIndex,
    ).filter((f) => f.articleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_authorIndexRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fileLastModified => $composableBuilder(
    column: $table.fileLastModified,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tagIndexRefs(
    Expression<bool> Function($$TagIndexTableFilterComposer f) f,
  ) {
    final $$TagIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tagIndex,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagIndexTableFilterComposer(
            $db: $db,
            $table: $db.tagIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> authorIndexRefs(
    Expression<bool> Function($$AuthorIndexTableFilterComposer f) f,
  ) {
    final $$AuthorIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.authorIndex,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthorIndexTableFilterComposer(
            $db: $db,
            $table: $db.authorIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fileLastModified => $composableBuilder(
    column: $table.fileLastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<DateTime> get fileLastModified => $composableBuilder(
    column: $table.fileLastModified,
    builder: (column) => column,
  );

  Expression<T> tagIndexRefs<T extends Object>(
    Expression<T> Function($$TagIndexTableAnnotationComposer a) f,
  ) {
    final $$TagIndexTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tagIndex,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagIndexTableAnnotationComposer(
            $db: $db,
            $table: $db.tagIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> authorIndexRefs<T extends Object>(
    Expression<T> Function($$AuthorIndexTableAnnotationComposer a) f,
  ) {
    final $$AuthorIndexTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.authorIndex,
      getReferencedColumn: (t) => t.articleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthorIndexTableAnnotationComposer(
            $db: $db,
            $table: $db.authorIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesTable,
          Article,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (Article, $$ArticlesTableReferences),
          Article,
          PrefetchHooks Function({bool tagIndexRefs, bool authorIndexRefs})
        > {
  $$ArticlesTableTableManager(_$AppDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> siteName = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<DateTime?> fileLastModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                title: title,
                url: url,
                siteName: siteName,
                publishedAt: publishedAt,
                savedAt: savedAt,
                isRead: isRead,
                progress: progress,
                fileLastModified: fileLastModified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String url,
                Value<String?> siteName = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                required DateTime savedAt,
                Value<bool> isRead = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<DateTime?> fileLastModified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                title: title,
                url: url,
                siteName: siteName,
                publishedAt: publishedAt,
                savedAt: savedAt,
                isRead: isRead,
                progress: progress,
                fileLastModified: fileLastModified,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tagIndexRefs = false, authorIndexRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tagIndexRefs) db.tagIndex,
                    if (authorIndexRefs) db.authorIndex,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tagIndexRefs)
                        await $_getPrefetchedData<
                          Article,
                          $ArticlesTable,
                          TagIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._tagIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).tagIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (authorIndexRefs)
                        await $_getPrefetchedData<
                          Article,
                          $ArticlesTable,
                          AuthorIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$ArticlesTableReferences
                              ._authorIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArticlesTableReferences(
                                db,
                                table,
                                p0,
                              ).authorIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.articleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesTable,
      Article,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (Article, $$ArticlesTableReferences),
      Article,
      PrefetchHooks Function({bool tagIndexRefs, bool authorIndexRefs})
    >;
typedef $$TagIndexTableCreateCompanionBuilder =
    TagIndexCompanion Function({
      required String name,
      required String articleId,
      Value<int> rowid,
    });
typedef $$TagIndexTableUpdateCompanionBuilder =
    TagIndexCompanion Function({
      Value<String> name,
      Value<String> articleId,
      Value<int> rowid,
    });

final class $$TagIndexTableReferences
    extends BaseReferences<_$AppDatabase, $TagIndexTable, TagIndexData> {
  $$TagIndexTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArticlesTable _articleIdTable(_$AppDatabase db) => db.articles
      .createAlias($_aliasNameGenerator(db.tagIndex.articleId, db.articles.id));

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TagIndexTableFilterComposer
    extends Composer<_$AppDatabase, $TagIndexTable> {
  $$TagIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagIndexTableOrderingComposer
    extends Composer<_$AppDatabase, $TagIndexTable> {
  $$TagIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagIndexTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagIndexTable> {
  $$TagIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagIndexTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagIndexTable,
          TagIndexData,
          $$TagIndexTableFilterComposer,
          $$TagIndexTableOrderingComposer,
          $$TagIndexTableAnnotationComposer,
          $$TagIndexTableCreateCompanionBuilder,
          $$TagIndexTableUpdateCompanionBuilder,
          (TagIndexData, $$TagIndexTableReferences),
          TagIndexData,
          PrefetchHooks Function({bool articleId})
        > {
  $$TagIndexTableTableManager(_$AppDatabase db, $TagIndexTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagIndexTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagIndexCompanion(
                name: name,
                articleId: articleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String articleId,
                Value<int> rowid = const Value.absent(),
              }) => TagIndexCompanion.insert(
                name: name,
                articleId: articleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TagIndexTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable: $$TagIndexTableReferences
                                    ._articleIdTable(db),
                                referencedColumn: $$TagIndexTableReferences
                                    ._articleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TagIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagIndexTable,
      TagIndexData,
      $$TagIndexTableFilterComposer,
      $$TagIndexTableOrderingComposer,
      $$TagIndexTableAnnotationComposer,
      $$TagIndexTableCreateCompanionBuilder,
      $$TagIndexTableUpdateCompanionBuilder,
      (TagIndexData, $$TagIndexTableReferences),
      TagIndexData,
      PrefetchHooks Function({bool articleId})
    >;
typedef $$AuthorIndexTableCreateCompanionBuilder =
    AuthorIndexCompanion Function({
      required String name,
      required String articleId,
      Value<int> rowid,
    });
typedef $$AuthorIndexTableUpdateCompanionBuilder =
    AuthorIndexCompanion Function({
      Value<String> name,
      Value<String> articleId,
      Value<int> rowid,
    });

final class $$AuthorIndexTableReferences
    extends BaseReferences<_$AppDatabase, $AuthorIndexTable, AuthorIndexData> {
  $$AuthorIndexTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArticlesTable _articleIdTable(_$AppDatabase db) =>
      db.articles.createAlias(
        $_aliasNameGenerator(db.authorIndex.articleId, db.articles.id),
      );

  $$ArticlesTableProcessedTableManager get articleId {
    final $_column = $_itemColumn<String>('article_id')!;

    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_articleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuthorIndexTableFilterComposer
    extends Composer<_$AppDatabase, $AuthorIndexTable> {
  $$AuthorIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$ArticlesTableFilterComposer get articleId {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuthorIndexTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthorIndexTable> {
  $$AuthorIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArticlesTableOrderingComposer get articleId {
    final $$ArticlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableOrderingComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuthorIndexTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthorIndexTable> {
  $$AuthorIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$ArticlesTableAnnotationComposer get articleId {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.articleId,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuthorIndexTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthorIndexTable,
          AuthorIndexData,
          $$AuthorIndexTableFilterComposer,
          $$AuthorIndexTableOrderingComposer,
          $$AuthorIndexTableAnnotationComposer,
          $$AuthorIndexTableCreateCompanionBuilder,
          $$AuthorIndexTableUpdateCompanionBuilder,
          (AuthorIndexData, $$AuthorIndexTableReferences),
          AuthorIndexData,
          PrefetchHooks Function({bool articleId})
        > {
  $$AuthorIndexTableTableManager(_$AppDatabase db, $AuthorIndexTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthorIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthorIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthorIndexTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> articleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthorIndexCompanion(
                name: name,
                articleId: articleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String articleId,
                Value<int> rowid = const Value.absent(),
              }) => AuthorIndexCompanion.insert(
                name: name,
                articleId: articleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AuthorIndexTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({articleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (articleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.articleId,
                                referencedTable: $$AuthorIndexTableReferences
                                    ._articleIdTable(db),
                                referencedColumn: $$AuthorIndexTableReferences
                                    ._articleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuthorIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthorIndexTable,
      AuthorIndexData,
      $$AuthorIndexTableFilterComposer,
      $$AuthorIndexTableOrderingComposer,
      $$AuthorIndexTableAnnotationComposer,
      $$AuthorIndexTableCreateCompanionBuilder,
      $$AuthorIndexTableUpdateCompanionBuilder,
      (AuthorIndexData, $$AuthorIndexTableReferences),
      AuthorIndexData,
      PrefetchHooks Function({bool articleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$TagIndexTableTableManager get tagIndex =>
      $$TagIndexTableTableManager(_db, _db.tagIndex);
  $$AuthorIndexTableTableManager get authorIndex =>
      $$AuthorIndexTableTableManager(_db, _db.authorIndex);
}
