import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/article_meta.dart';
import 'storage_access.dart';

class ArticleIngestionService {
  final StorageService _storage;
  final AppDatabase _db;

  ArticleIngestionService(this._storage, this._db);

  /// Nimmt eine rohe HTML Datei (Download), extrahiert Metadaten,
  /// verschiebt sie in die Ordnerstruktur und indexiert sie.
  /// Gibt die ArticleID zurück.
  Future<String> ingestDownloadedFile(File tempFile) async {
    // 1. HTML Parsen & Metadaten extrahieren
    final String content = await tempFile.readAsString();
    final doc = html_parser.parse(content);

    // Suche nach dem Script-Tag vom Add-on
    final metaScript = doc.querySelector('script#cleanread-meta');

    Map<String, dynamic> rawMeta = {};
    if (metaScript != null && metaScript.text.isNotEmpty) {
      try {
        rawMeta = jsonDecode(metaScript.text);
      } catch (e) {
        print("JSON Parse Error in HTML: $e");
      }
    }

    // 2. UUID generieren & Ordner vorbereiten
    final String articleId = const Uuid().v4();

    final appDir = await _storage.getAppDirectory();
    final articleDir = Directory(p.join(appDir.path, articleId));
    await articleDir.create(recursive: true);

    // 3. ArticleMeta Objekt bauen (Merging mit Defaults)
    final meta = ArticleMeta(
      uuid: articleId,
      url: rawMeta['url'] ?? 'unknown',
      title: rawMeta['title'] ?? 'Untitled',
      siteName: rawMeta['siteName'],
      // Add-on sendet Strings, wir brauchen DateTime
      publishedAt: rawMeta['published'] != null
          ? DateTime.tryParse(rawMeta['published'])
          : null,
      savedAt: DateTime.now(),
      authors:
          (rawMeta['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags: [],
    );

    // 4. Dateien schreiben (File-First!)

    // A. content.html verschieben
    final destHtml = p.join(articleDir.path, 'content.html');
    await tempFile.rename(destHtml);

    // B. meta.json schreiben
    final metaFile = File(p.join(articleDir.path, 'meta.json'));
    // pretty print für Debugging-Freude
    await metaFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(meta.toJson()),
    );

    // Holen wir uns den Zeitstempel, den das OS der Datei gegeben hat
    final DateTime fileSavedTime = metaFile.lastModifiedSync();

    // Und speichern diesen in die DB
    await _db.indexArticle(meta, fileSavedTime);

    return articleId;
  }
}
