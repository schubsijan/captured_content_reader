import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import '../models/article_meta.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Articles, TagIndex, AuthorIndex])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Wir fügen die Spalte hinzu.
          await m.addColumn(articles, articles.fileLastModified);
        }
      },
    );
  }

  // --- Core Logic: Re-Indexing ---
  // Diese Funktion macht die DB synchron mit der meta.json (File-First!)
  Future<void> indexArticle(ArticleMeta meta, DateTime fileModified) async {
    return transaction(() async {
      // 1. Artikel Tabelle Upsert
      await into(articles).insertOnConflictUpdate(
        ArticlesCompanion.insert(
          id: meta.uuid,
          title: meta.title,
          url: meta.url,
          siteName: Value(meta.siteName),
          publishedAt: Value(meta.publishedAt),
          savedAt: meta.savedAt,
          isRead: Value(meta.isRead),
          progress: Value(meta.progress),
          fileLastModified: Value(fileModified),
        ),
      );

      // 2. Tags bereinigen und neu setzen (Delete & Insert Strategie)
      await (delete(
        tagIndex,
      )..where((t) => t.articleId.equals(meta.uuid))).go();

      for (final tag in meta.tags) {
        await into(
          tagIndex,
        ).insert(TagIndexCompanion.insert(name: tag, articleId: meta.uuid));
      }

      // 3. Autoren bereinigen und neu setzen
      await (delete(
        authorIndex,
      )..where((t) => t.articleId.equals(meta.uuid))).go();

      for (final author in meta.authors) {
        await into(authorIndex).insert(
          AuthorIndexCompanion.insert(name: author, articleId: meta.uuid),
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cleanread_index.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
