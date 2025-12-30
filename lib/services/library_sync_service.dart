import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';
import '../models/article_meta.dart';
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

    // 1. DB Cache holen (nur ID und Timestamp)
    final List<Article> dbEntries = await _db.select(_db.articles).get();

    final Map<String, DateTime?> dbIndex = {
      for (var article in dbEntries) article.id: article.fileLastModified,
    };

    final Set<String> visitedDiskUuids = {};
    int updatedCount = 0;

    // 2. Dateisystem scannen
    // listSync ist schnell, da es nur Verzeichniseinträge liest
    final List<FileSystemEntity> entities = appDir.listSync();

    for (final entity in entities) {
      if (entity is Directory) {
        final String uuid = p.basename(entity.path);
        visitedDiskUuids.add(uuid);

        final File metaFile = File(p.join(entity.path, 'meta.json'));

        if (!metaFile.existsSync()) continue;

        // FAST CHECK: Wann wurde die Datei zuletzt angefasst?
        final DateTime fileModified = metaFile.lastModifiedSync();

        final DateTime? dbModified = dbIndex[uuid];

        // LOGIK:
        // A: Neu (nicht in DB)
        // B: Geändert (File Datum > DB Datum)
        // C: Unverändert (File Datum == DB Datum) -> SKIP!

        bool needsUpdate = false;

        if (dbModified == null) {
          // Fall A: Neu
          needsUpdate = true;
        } else {
          // Fall B: Prüfen ob Datei neuer ist (Toleranz von paar Millisekunden beachten)
          // Wir nutzen isAfter. Syncthing erhält mtime normalerweise.
          if (fileModified.difference(dbModified).abs().inMilliseconds > 1000) {
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          try {
            // NUR HIER lesen wir die Datei wirklich (Teuer!)
            final content = await metaFile.readAsString();
            final jsonMap = jsonDecode(content);
            final meta = ArticleMeta.fromJson(jsonMap);

            // Wir übergeben das fileModified Datum an die DB
            await _db.indexArticle(meta, fileModified);
            updatedCount++;
          } catch (e) {
            print("Fehler beim Parsen von $uuid: $e");
          }
        }
      }
    }

    // 3. Löschen (Was in DB war, aber nicht besucht wurde)
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
}
