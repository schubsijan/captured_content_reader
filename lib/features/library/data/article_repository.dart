import 'package:drift/drift.dart';
import 'package:drift/drift.dart' as drift;

import '../../../database/app_database.dart';
import '../../../models/article_meta.dart';
import 'file_data_source.dart';

class ArticleRepository {
  final AppDatabase _db;
  final FileDataSource _fileSource;

  ArticleRepository(this._db, this._fileSource);

  Stream<List<Article>> watchUnreadArticles() {
    return (_db.select(_db.articles)
          ..where((t) => t.isRead.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.savedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Article>> watchReadArticles() {
    return (_db.select(_db.articles)
          ..where((t) => t.isRead.equals(true))
          ..orderBy([
            // fileLastModified wird beim Statuswechsel aktualisiert -> ideal für "zuletzt gelesen"
            (t) => OrderingTerm(
              expression: t.fileLastModified,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<void> updateReadStatus(String articleId, bool isRead) async {
    // 1. Lesen
    final meta = await _fileSource.readMeta(articleId);
    if (meta == null) return;

    // 2. Updaten
    final updatedMeta = meta.copyWith(isRead: isRead);

    // 3. File-First speichern
    await _fileSource.writeMetaAtomic(articleId, updatedMeta);

    // 4. Cache (DB) aktualisieren
    await (_db.update(
      _db.articles,
    )..where((t) => t.id.equals(articleId))).write(
      ArticlesCompanion(
        isRead: drift.Value(isRead),
        fileLastModified: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteArticle(String articleId) async {
    // 1. File-First: Den Ordner auf dem Dateisystem löschen
    await _fileSource.deleteArticleFolder(articleId);

    // 2. Ephemeren Cache (DB) bereinigen
    await (_db.delete(_db.articles)..where((t) => t.id.equals(articleId))).go();
  }

  Future<void> updateArticleTags(String articleId, List<String> newTags) async {
    // 1. Aktuelle Metadaten von der Disk lesen
    final meta = await _fileSource.readMeta(articleId);
    if (meta == null) return;

    // 2. Kopie mit neuen Tags erstellen
    final updatedMeta = meta.copyWith(tags: newTags);

    // 3. File-First: Atomar auf die Disk schreiben
    await _fileSource.writeMetaAtomic(articleId, updatedMeta);

    // 4. Cache (DB) synchronisieren
    // Wir nutzen indexArticle, da es Tags, Autoren und den Artikel-Eintrag
    // sauber neu aufbaut und verknüpft.
    final fileLastModified = DateTime.now();
    await _db.indexArticle(updatedMeta, fileLastModified);
  }

  /// Aktualisiert die Metadaten eines Artikels (Titel, Autoren, etc.)
  Future<void> updateArticleMeta(String articleId, ArticleMeta newMeta) async {
    // 1. File-First: Das komplette, neue Meta-Objekt atomar auf die Disk schreiben
    await _fileSource.writeMetaAtomic(articleId, newMeta);

    // 2. Cache (DB) synchronisieren
    final fileLastModified = DateTime.now();
    await _db.indexArticle(newMeta, fileLastModified);
  }
}
