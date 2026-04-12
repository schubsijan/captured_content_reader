import 'package:drift/drift.dart';

class Articles extends Table {
  TextColumn get id => text()(); // UUID = Primary Key
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get siteName => text().nullable()();

  // Für Sortierung
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get savedAt => dateTime()();

  // Status (Redundanz zur JSON für schnelle Filter "Ungelesen")
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  RealColumn get progress => real().withDefault(const Constant(0.0))();

  DateTimeColumn get fileLastModified => dateTime().nullable()();

  TextColumn get authors => text().withDefault(const Constant('[]'))();

  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Index für Tags (Autocomplete & Filter)
class TagIndex extends Table {
  TextColumn get name => text()();
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();

  TextColumn get origin => text().withDefault(const Constant('article'))();

  @override
  Set<Column> get primaryKey => {name, articleId, origin}; // Origin in PK aufnehmen
}

// Index für Autoren
class AuthorIndex extends Table {
  TextColumn get name => text()();
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {name, articleId};
}

@DataClassName('DbArticleNote')
class ArticleNotes extends Table {
  TextColumn get id => text()();
  TextColumn get articleId =>
      text().references(Articles, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get tags => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}
