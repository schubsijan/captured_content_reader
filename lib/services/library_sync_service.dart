import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';
import '../models/article_meta.dart';
import '../models/article_note.dart';
import '../models/highlight.dart';
import 'storage_access.dart';

class LibrarySyncService {
  final StorageService _storage;
  final AppDatabase _db;

  LibrarySyncService(this._storage, this._db);

  Future<void> syncFileSystemToDatabase() async {
    print("Starte Smart-Sync...");
    final Stopwatch stopwatch = Stopwatch()..start();

    final appDir = await _storage.getAppDirectory();
    if (!await appDir.exists()) return;

    final List<Article> dbEntries = await _db.select(_db.articles).get();
    final Map<String, DateTime?> dbIndex = {
      for (var article in dbEntries) article.id: article.fileLastModified,
    };

    final Set<String> visitedDiskUuids = {};
    int updatedCount = 0;

    final List<FileSystemEntity> entities = appDir.listSync();

    for (final entity in entities) {
      if (entity is Directory) {
        final String uuid = p.basename(entity.path);
        visitedDiskUuids.add(uuid);

        final updated = await _processArticleDirectory(
          entity,
          uuid,
          dbIndex[uuid],
        );
        if (updated) updatedCount++;
      }
    }

    final Set<String> toDelete = dbIndex.keys.toSet().difference(
      visitedDiskUuids,
    );

    if (toDelete.isNotEmpty) {
      await (_db.delete(
        _db.articles,
      )..where((tbl) => tbl.id.isIn(toDelete))).go();
      print("Gelöscht: ${toDelete.length}");
    }

    stopwatch.stop();
    print(
      "Sync fertig in ${stopwatch.elapsedMilliseconds}ms. Aktualisiert: $updatedCount, Gelöscht: ${toDelete.length}",
    );
  }

  Future<void> syncSingleArticle(String articleId) async {
    final appDir = await _storage.getAppDirectory();
    final dir = Directory(p.join(appDir.path, articleId));
    if (dir.existsSync()) {
      await _processArticleDirectory(dir, articleId, null, forceUpdate: true);
    }
  }

  Future<bool> _processArticleDirectory(
    Directory dir,
    String uuid,
    DateTime? dbModified, {
    bool forceUpdate = false,
  }) async {
    final metaFile = File(p.join(dir.path, 'meta.json'));
    final notesFile = File(p.join(dir.path, 'notes.json'));
    final highlightsFile = File(p.join(dir.path, 'highlights.json'));

    if (!metaFile.existsSync()) return false;

    DateTime maxModified = metaFile.lastModifiedSync();
    if (notesFile.existsSync()) {
      final nMod = notesFile.lastModifiedSync();
      if (nMod.isAfter(maxModified)) maxModified = nMod;
    }
    if (highlightsFile.existsSync()) {
      final hMod = highlightsFile.lastModifiedSync();
      if (hMod.isAfter(maxModified)) maxModified = hMod;
    }

    bool needsUpdate =
        forceUpdate ||
        dbModified == null ||
        maxModified.difference(dbModified).abs().inMilliseconds > 1000;

    if (needsUpdate) {
      try {
        final metaContent = await metaFile.readAsString();
        final meta = ArticleMeta.fromJson(jsonDecode(metaContent));

        List<ArticleNote> notes = [];
        if (notesFile.existsSync()) {
          final nContent = await notesFile.readAsString();
          notes = (jsonDecode(nContent) as List)
              .map((e) => ArticleNote.fromJson(e))
              .toList();
        }

        List<Highlight> highlights = [];
        if (highlightsFile.existsSync()) {
          final hContent = await highlightsFile.readAsString();
          highlights = (jsonDecode(hContent) as List)
              .map((e) => Highlight.fromJson(e))
              .toList();
        }

        await _db.indexArticle(
          meta,
          maxModified,
          notes: notes,
          highlights: highlights,
        );
        return true;
      } catch (e) {
        print("Fehler beim Parsen von $uuid: $e");
      }
    }
    return false;
  }
}
