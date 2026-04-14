import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';
import '../models/article_meta.dart';
import '../models/article_note.dart';
import '../models/highlight.dart';
import 'storage_access.dart';
import 'dart:isolate';

// --- Datenträger-Klassen für den Datenaustausch mit dem Isolate ---

class ArticleSyncPayload {
  final ArticleMeta meta;
  final DateTime maxModified;
  final List<ArticleNote> notes;
  final List<Highlight> highlights;

  ArticleSyncPayload(this.meta, this.maxModified, this.notes, this.highlights);
}

class SyncResult {
  final List<ArticleSyncPayload> toUpdate;
  final List<String> toDelete;

  SyncResult(this.toUpdate, this.toDelete);
}

// --- Der eigentliche Service ---

class LibrarySyncService {
  final StorageService _storage;
  final AppDatabase _db;

  LibrarySyncService(this._storage, this._db);

  Future<void> syncFileSystemToDatabase() async {
    final Stopwatch stopwatch = Stopwatch()..start();

    final appDir = await _storage.getAppDirectory();

    // ENTFERNT: if (!await appDir.exists()) return;

    // 1. Aktuellen Index aus der Datenbank (Main Thread) holen
    final List<Article> dbEntries = await _db.select(_db.articles).get();
    final Map<String, DateTime?> dbIndex = {
      for (var article in dbEntries) article.id: article.fileLastModified,
    };

    // 2. Intensive Datei-Operationen und Parsing in Isolate auslagern
    final syncResult = await Isolate.run(
      () => _scanDirectoryIsolate(appDir.path, dbIndex),
    );

    // 3. Ergebnisse in die DB schreiben (wieder auf dem Main Thread)
    int updatedCount = syncResult.toUpdate.length;

    for (final payload in syncResult.toUpdate) {
      await _db.indexArticle(
        payload.meta,
        payload.maxModified,
        notes: payload.notes,
        highlights: payload.highlights,
      );
    }

    if (syncResult.toDelete.isNotEmpty) {
      await (_db.delete(
        _db.articles,
      )..where((tbl) => tbl.id.isIn(syncResult.toDelete))).go();
      print("Gelöscht: ${syncResult.toDelete.length}");
    }

    stopwatch.stop();
    print(
      "Sync fertig in ${stopwatch.elapsedMilliseconds}ms. Aktualisiert: $updatedCount, Gelöscht: ${syncResult.toDelete.length}",
    );
  }

  Future<void> syncSingleArticle(String articleId) async {
    final appDir = await _storage.getAppDirectory();
    final dir = Directory(p.join(appDir.path, articleId));

    if (dir.existsSync()) {
      // Nutzt die synchrone Logik, da es sich nur um ein einzelnes Verzeichnis handelt
      final payload = _processArticleDirectorySync(
        dir,
        articleId,
        null,
        forceUpdate: true,
      );

      if (payload != null) {
        await _db.indexArticle(
          payload.meta,
          payload.maxModified,
          notes: payload.notes,
          highlights: payload.highlights,
        );
      }
    }
  }
}

// --- Top-Level Funktionen für den Isolate (Keine Bindung an die Service-Klasse) ---

/// Diese Funktion läuft komplett im Hintergrund-Isolate.
/// Sie nutzt Sync-Funktionen (wie listSync, readAsStringSync), da das Blockieren
/// des Hintergrund-Threads gewollt und am performantesten ist.
SyncResult _scanDirectoryIsolate(
  String rootPath,
  Map<String, DateTime?> dbIndex,
) {
  final rootDir = Directory(rootPath);
  final toUpdate = <ArticleSyncPayload>[];
  final visitedUuids = <String>{};

  // Wir prüfen auf Existenz, aber wir brechen nicht mit return ab.
  // Wenn der Ordner weg ist, wird diese Schleife einfach ignoriert.
  if (rootDir.existsSync()) {
    for (final entity in rootDir.listSync()) {
      if (entity is Directory) {
        final uuid = p.basename(entity.path);
        visitedUuids.add(uuid);

        final payload = _processArticleDirectorySync(
          entity,
          uuid,
          dbIndex[uuid],
        );
        if (payload != null) {
          toUpdate.add(payload);
        }
      }
    }
  }

  // Wenn der Root-Ordner gelöscht wurde, ist visitedUuids leer.
  // toDelete enthält dann ALLE Einträge aus dem dbIndex.
  final toDelete = dbIndex.keys.toSet().difference(visitedUuids).toList();
  return SyncResult(toUpdate, toDelete);
}

/// Analysiert einen einzelnen Ordner, vergleicht Zeitstempel und parst JSONs.
ArticleSyncPayload? _processArticleDirectorySync(
  Directory dir,
  String uuid,
  DateTime? dbModified, {
  bool forceUpdate = false,
}) {
  final metaFile = File(p.join(dir.path, 'meta.json'));
  final notesFile = File(p.join(dir.path, 'notes.json'));
  final highlightsFile = File(p.join(dir.path, 'highlights.json'));

  if (!metaFile.existsSync()) return null;

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
      final metaContent = metaFile.readAsStringSync();
      final meta = ArticleMeta.fromJson(jsonDecode(metaContent));

      List<ArticleNote> notes = [];
      if (notesFile.existsSync()) {
        final nContent = notesFile.readAsStringSync();
        notes = (jsonDecode(nContent) as List)
            .map((e) => ArticleNote.fromJson(e))
            .toList();
      }

      List<Highlight> highlights = [];
      if (highlightsFile.existsSync()) {
        final hContent = highlightsFile.readAsStringSync();
        highlights = (jsonDecode(hContent) as List)
            .map((e) => Highlight.fromJson(e))
            .toList();
      }

      return ArticleSyncPayload(meta, maxModified, notes, highlights);
    } catch (e) {
      print("Fehler beim Parsen von $uuid: $e");
    }
  }
  return null;
}
