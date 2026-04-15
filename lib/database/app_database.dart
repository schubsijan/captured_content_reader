import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import '../models/article_meta.dart';
import '../models/article_note.dart';
import '../models/highlight.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Articles, TagIndex, AuthorIndex, ArticleNotes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

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
        if (from < 3) {
          // <--- NEU: Migration für Version 3
          await m.addColumn(articles, articles.authors);
        }
        if (from < 4) {
          // <--- NEU: Migration für Version 4
          await m.addColumn(articles, articles.note);
        }
        if (from < 5) {
          await m.createTable(articleNotes);
        }
        if (from < 6) {
          // <--- NEU
          await m.addColumn(articleNotes, articleNotes.tags);
        }
        if (from < 7) {
          // Spalte origin hinzufügen
          await m.addColumn(tagIndex, tagIndex.origin);
        }
        if (from < 8) {
          await m.drop(tagIndex);
          await m.createTable(tagIndex);
        }
      },
    );
  }

  // --- Core Logic: Re-Indexing ---
  // Diese Funktion macht die DB synchron mit der meta.json (File-First!)
  Future<void> indexArticle(
    ArticleMeta meta,
    DateTime fileModified, {
    List<ArticleNote> notes = const [],
    List<Highlight> highlights = const [],
  }) async {
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
          authors: Value(jsonEncode(meta.authors)),
          note: Value(meta.note),
        ),
      );

      await (delete(
        tagIndex,
      )..where((t) => t.articleId.equals(meta.uuid))).go();

      // 3. Tags nach Herkunft getrennt speichern

      // A. Artikel-Tags
      for (final tag in meta.tags) {
        await into(tagIndex).insertOnConflictUpdate(
          TagIndexCompanion.insert(
            name: tag,
            articleId: meta.uuid,
            origin: const Value('article'),
          ),
        );
      }

      // B. Tags aus Notizen
      for (final n in notes) {
        for (final tag in n.tags) {
          await into(tagIndex).insertOnConflictUpdate(
            TagIndexCompanion.insert(
              name: tag,
              articleId: meta.uuid,
              origin: const Value('note'),
            ),
          );
        }
      }

      // C. Tags aus Highlights
      for (final h in highlights) {
        for (final tag in h.tags) {
          await into(tagIndex).insertOnConflictUpdate(
            TagIndexCompanion.insert(
              name: tag,
              articleId: meta.uuid,
              origin: const Value('highlight'),
            ),
          );
        }
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

      await (delete(
        articleNotes,
      )..where((t) => t.articleId.equals(meta.uuid))).go();
      for (final note in notes) {
        await into(articleNotes).insert(
          ArticleNotesCompanion.insert(
            id: note.id,
            articleId: meta.uuid,
            content: note.content,
            createdAt: note.createdAt,
            tags: Value(jsonEncode(note.tags)), // <--- NEU
          ),
        );
      }
    });
  }

  Future<List<String>> getAllTags() async {
    final query = selectOnly(tagIndex, distinct: true)
      ..addColumns([tagIndex.name]);
    final results = await query.get();
    return results.map((row) => row.read(tagIndex.name)!).toList();
  }

  Stream<List<String>> watchTagsForArticle(String articleId) {
    final query = select(tagIndex)
      ..where((t) => t.articleId.equals(articleId))
      ..where((t) => t.origin.equals('article'));
    return query.watch().map((rows) => rows.map((r) => r.name).toList());
  }

  Future<void> syncNotes(String articleId, List<ArticleNote> notes) async {
    return transaction(() async {
      await (delete(
        articleNotes,
      )..where((t) => t.articleId.equals(articleId))).go();
      for (final note in notes) {
        await into(articleNotes).insert(
          ArticleNotesCompanion.insert(
            id: note.id,
            articleId: articleId,
            content: note.content,
            createdAt: note.createdAt,
          ),
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
