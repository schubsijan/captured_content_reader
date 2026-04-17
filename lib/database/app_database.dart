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
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(articles, articles.fileLastModified);
        }
        if (from < 3) {
          await m.addColumn(articles, articles.authors);
        }
        if (from < 4) {
          await m.addColumn(articles, articles.note);
        }
        if (from < 5) {
          await m.createTable(articleNotes);
        }
        if (from < 6) {
          await m.addColumn(articleNotes, articleNotes.tags);
        }
        if (from < 7) {
          await m.addColumn(tagIndex, tagIndex.origin);
        }
        if (from < 8) {
          await m.drop(tagIndex);
          await m.createTable(tagIndex);
        }
        if (from < 9) {
          // isRead (bool) -> readAt (DateTime nullable)
          final tableInfo = await customSelect(
            "PRAGMA table_info(articles)",
          ).get();
          final hasIsRead = tableInfo.any((row) => row.data['name'] == 'is_read');
          final hasReadAt = tableInfo.any((row) => row.data['name'] == 'read_at');

          if (!hasReadAt && hasIsRead) {
            await m.addColumn(articles, articles.readAt);
            // Use CURRENT_TIMESTAMP instead of strftime for better compatibility
            await customStatement(
              "UPDATE articles SET read_at = CURRENT_TIMESTAMP WHERE is_read = 1",
            );
            await customStatement("ALTER TABLE articles DROP COLUMN is_read");
          } else if (hasReadAt && hasIsRead) {
            await customStatement("ALTER TABLE articles DROP COLUMN is_read");
          }
        }
      },
    );
  }

  // --- Core Logic: Re-Indexing ---
  // Diese Funktion synchronisiert die DB mit dem Dateisystem (Source of Truth).
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
          readAt: Value(meta.readAt),
          progress: Value(meta.progress),
          fileLastModified: Value(fileModified),
          authors: Value(jsonEncode(meta.authors)),
          note: Value(meta.note),
        ),
      );

      // 2. Bestehende Verknüpfungen löschen, um Dubletten oder verwaiste Tags zu vermeiden
      await (delete(
        tagIndex,
      )..where((t) => t.articleId.equals(meta.uuid))).go();
      await (delete(
        authorIndex,
      )..where((t) => t.articleId.equals(meta.uuid))).go();
      await (delete(
        articleNotes,
      )..where((t) => t.articleId.equals(meta.uuid))).go();

      // 3. Tags nach Herkunft getrennt speichern

      // A. Tags aus der meta.json (Eigentliche Artikel-Tags)
      for (final tag in meta.tags) {
        await into(tagIndex).insertOnConflictUpdate(
          TagIndexCompanion.insert(
            name: tag,
            articleId: meta.uuid,
            origin: const Value('article'),
          ),
        );
      }

      // B. Tags aus Notizen extrahieren
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

      // C. Tags aus Highlights extrahieren
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

      // 4. Autoren-Index neu aufbauen
      for (final author in meta.authors.toSet()) {
        await into(authorIndex).insertOnConflictUpdate(
          AuthorIndexCompanion.insert(name: author, articleId: meta.uuid),
        );
      }

      // 5. Notizen-Index neu aufbauen
      for (final note in notes) {
        await into(articleNotes).insert(
          ArticleNotesCompanion.insert(
            id: note.id,
            articleId: meta.uuid,
            content: note.content,
            createdAt: note.createdAt,
            tags: Value(jsonEncode(note.tags)),
          ),
        );
      }
    });
  }

  // Hilfsmethode für Autocomplete/Filter-Listen
  Future<List<String>> getAllTags() async {
    final query = selectOnly(tagIndex, distinct: true)
      ..addColumns([tagIndex.name]);
    final results = await query.get();
    return results.map((row) => row.read(tagIndex.name)!).toList();
  }

  // Stream für die UI (ArticleMetaDisplay)
  Stream<List<String>> watchTagsForArticle(String articleId) {
    final query = select(tagIndex)
      ..where((t) => t.articleId.equals(articleId))
      ..where((t) => t.origin.equals('article'));
    return query.watch().map((rows) => rows.map((r) => r.name).toList());
  }

  // Spezial-Sync für Artikelnotizen (wird von NoteService genutzt)
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
            tags: Value(jsonEncode(note.tags)),
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
    // Nutzt Hintergrund-Isolate für bessere UI-Performance
    return NativeDatabase.createInBackground(file);
  });
}
