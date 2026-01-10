import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import '../../../database/app_database.dart';
import '../../../models/article_meta.dart';
import '../../../services/storage_access.dart';

class ArticleRepository {
  final AppDatabase _db;
  final StorageService _storage; // <--- NEU: Für File-Zugriff

  ArticleRepository(this._db, this._storage);

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

  /// Setzt den Lesestatus eines Artikels (File-First + DB Sync)
  /// [isRead] = true -> Als gelesen markieren (verschwindet aus Liste)
  /// [isRead] = false -> Als ungelesen markieren (taucht wieder auf = Undo)
  Future<void> updateReadStatus(String articleId, bool isRead) async {
    // 1. Pfad zur meta.json ermitteln
    final appDir = await _storage.getAppDirectory();
    final metaFile = File(p.join(appDir.path, articleId, 'meta.json'));

    if (!await metaFile.exists()) {
      print("Meta file not found for $articleId");
      return;
    }

    try {
      // 2. FILE UPDATE (Atomar)
      final content = await metaFile.readAsString();
      final jsonMap = jsonDecode(content);
      final meta = ArticleMeta.fromJson(jsonMap);

      // Status ändern (nutzt copyWith aus freezed)
      final updatedMeta = meta.copyWith(isRead: isRead);

      // Schreiben (Atomar via .tmp)
      final tempFile = File('${metaFile.path}.tmp');
      await tempFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(updatedMeta.toJson()),
        flush: true,
      );
      await tempFile.rename(metaFile.path);

      // 3. DB UPDATE (Damit die UI reagiert)
      await (_db.update(
        _db.articles,
      )..where((t) => t.id.equals(articleId))).write(
        ArticlesCompanion(
          isRead: Value(isRead), // Hier nutzen wir den Parameter
          // Optional: fileLastModified updaten, damit Sync beim nächsten Start bescheid weiß
          fileLastModified: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      print("Error updating read status: $e");
      rethrow;
    }
  }

  /// Löscht einen Artikel komplett (Ordner + DB Eintrag).
  /// ACHTUNG: Das ist destruktiv und kann ohne Backup nicht rückgängig gemacht werden.
  Future<void> deleteArticle(String articleId) async {
    // 1. Ordner im Dateisystem löschen
    final appDir = await _storage.getAppDirectory();
    final articleDir = Directory(p.join(appDir.path, articleId));

    if (await articleDir.exists()) {
      await articleDir.delete(recursive: true);
    }

    // 2. Aus der Datenbank entfernen
    await (_db.delete(_db.articles)..where((t) => t.id.equals(articleId))).go();
  }

  /// Aktualisiert die Metadaten eines Artikels (Titel, Autoren, etc.)
  Future<void> updateArticleMeta(String articleId, ArticleMeta newMeta) async {
    final appDir = await _storage.getAppDirectory();
    final metaFile = File(p.join(appDir.path, articleId, 'meta.json'));

    if (!await metaFile.exists()) return;

    // 1. FILE UPDATE
    // Wir schreiben das komplette neue Meta-Objekt
    final tempFile = File('${metaFile.path}.tmp');
    await tempFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(newMeta.toJson()),
      flush: true,
    );
    await tempFile.rename(metaFile.path);

    // 2. DB UPDATE
    // Wir nutzen die existierende Index-Logik, da sie alles abdeckt (Tags, Autoren, etc.)
    // und auch das fileLastModified aktualisiert.
    final fileLastModified = DateTime.now(); // oder metaFile.lastModifiedSync()
    await _db.indexArticle(newMeta, fileLastModified);
  }
}
