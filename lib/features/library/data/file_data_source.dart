import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../models/article_meta.dart';
import '../../../services/storage_access.dart';

class FileDataSource {
  final StorageService _storage;

  FileDataSource(this._storage);

  Future<File> _getMetaFile(String articleId) async {
    final appDir = await _storage.getAppDirectory();
    return File(p.join(appDir.path, articleId, 'meta.json'));
  }

  Future<ArticleMeta?> readMeta(String articleId) async {
    final file = await _getMetaFile(articleId);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return ArticleMeta.fromJson(jsonDecode(content));
  }

  Future<void> writeMetaAtomic(String articleId, ArticleMeta meta) async {
    final file = await _getMetaFile(articleId);
    final tempFile = File('${file.path}.tmp');

    await tempFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(meta.toJson()),
      flush: true,
    );
    await tempFile.rename(file.path);
  }

  Future<void> deleteArticleFolder(String articleId) async {
    final appDir = await _storage.getAppDirectory();
    final articleDir = Directory(p.join(appDir.path, articleId));

    if (await articleDir.exists()) {
      await articleDir.delete(recursive: true);
    }
  }
}
