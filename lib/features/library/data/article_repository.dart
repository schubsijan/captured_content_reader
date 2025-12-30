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
}
