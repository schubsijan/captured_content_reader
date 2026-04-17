import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../database/app_database.dart';
import '../../../main.dart';
import '../../../services/storage_access.dart';
import '../../../models/highlight.dart';
import '../../../models/article_note.dart';
import '../../shared/ui/shared_article_list_tile.dart';
import '../../shared/ui/shared_highlight_list_tile.dart';
import '../../shared/ui/shared_note_list_tile.dart';
import '../../reader/ui/article_reader_screen.dart';
import '../providers/tag_management_providers.dart';

class TagDetailScreen extends ConsumerWidget {
  final String tagName;

  const TagDetailScreen({super.key, required this.tagName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tagName),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Artikel'),
              Tab(text: 'Highlights'),
              Tab(text: 'Notizen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ArticleList(tagName: tagName),
            _HighlightList(tagName: tagName),
            _NoteList(tagName: tagName),
          ],
        ),
      ),
    );
  }
}

final _tagIndexChangeProvider = StreamProvider<void>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.tagIndex).watch().map((_) {});
});

final tagArticlesStreamProvider = StreamProvider.family<List<Article>, String>((
  ref,
  tagName,
) {
  final db = ref.watch(databaseProvider);

  ref.watch(_tagIndexChangeProvider);

  return db.select(db.tagIndex).watch().asyncExpand((_) async* {
    final articleIdsQuery = db.selectOnly(db.tagIndex, distinct: true)
      ..addColumns([db.tagIndex.articleId])
      ..where(db.tagIndex.name.equals(tagName))
      ..where(db.tagIndex.origin.equals('article'));

    final rows = await articleIdsQuery.get();
    final articleIds = rows
        .map((row) => row.read(db.tagIndex.articleId)!)
        .toList();

    if (articleIds.isEmpty) {
      yield <Article>[];
      return;
    }

    final articlesQuery = db.select(db.articles)
      ..where((t) => t.id.isIn(articleIds));

    yield* articlesQuery.watch();
  });
});

final tagHighlightsStreamProvider =
    StreamProvider.family<List<HighlightWithArticleId>, String>((ref, tagName) {
      final db = ref.watch(databaseProvider);

      ref.watch(_tagIndexChangeProvider);

      return db.select(db.tagIndex).watch().asyncExpand((_) async* {
        final storage = StorageService();
        final appDir = await storage.getAppDirectory();

        final articleIdsQuery = db.selectOnly(db.tagIndex, distinct: true)
          ..addColumns([db.tagIndex.articleId])
          ..where(db.tagIndex.name.equals(tagName))
          ..where(db.tagIndex.origin.equals('highlight'));

        final rows = await articleIdsQuery.get();
        final articleIds = rows
            .map((row) => row.read(db.tagIndex.articleId)!)
            .toList();

        final highlights = <HighlightWithArticleId>[];

        for (final articleId in articleIds) {
          final highlightsFile = File(
            p.join(appDir.path, articleId, 'highlights.json'),
          );
          if (await highlightsFile.exists()) {
            try {
              final content = await highlightsFile.readAsString();
              final items = jsonDecode(content) as List;

              for (final item in items) {
                final tags =
                    (item['tags'] as List<dynamic>?)?.cast<String>() ?? [];
                if (tags.contains(tagName)) {
                  highlights.add(
                    HighlightWithArticleId(
                      highlight: Highlight.fromJson(item),
                      articleId: articleId,
                    ),
                  );
                }
              }
            } catch (_) {}
          }
        }

        yield highlights;
      });
    });

final tagNotesStreamProvider =
    StreamProvider.family<List<NoteWithArticleId>, String>((ref, tagName) {
      final db = ref.watch(databaseProvider);

      ref.watch(_tagIndexChangeProvider);

      return db.select(db.tagIndex).watch().asyncExpand((_) async* {
        final storage = StorageService();
        final appDir = await storage.getAppDirectory();

        final articleIdsQuery = db.selectOnly(db.tagIndex, distinct: true)
          ..addColumns([db.tagIndex.articleId])
          ..where(db.tagIndex.name.equals(tagName))
          ..where(db.tagIndex.origin.equals('note'));

        final rows = await articleIdsQuery.get();
        final articleIds = rows
            .map((row) => row.read(db.tagIndex.articleId)!)
            .toList();

        final notes = <NoteWithArticleId>[];

        for (final articleId in articleIds) {
          final notesFile = File(p.join(appDir.path, articleId, 'notes.json'));
          if (await notesFile.exists()) {
            try {
              final content = await notesFile.readAsString();
              final items = jsonDecode(content) as List;

              for (final item in items) {
                final tags =
                    (item['tags'] as List<dynamic>?)?.cast<String>() ?? [];
                if (tags.contains(tagName)) {
                  notes.add(
                    NoteWithArticleId(
                      note: ArticleNote.fromJson(item),
                      articleId: articleId,
                    ),
                  );
                }
              }
            } catch (_) {}
          }
        }

        notes.sort((a, b) => b.note.createdAt.compareTo(a.note.createdAt));
        yield notes;
      });
    });

class _ArticleList extends ConsumerWidget {
  final String tagName;

  const _ArticleList({required this.tagName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(tagArticlesStreamProvider(tagName));

    return articlesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Fehler: $err')),
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(child: Text('Keine Artikel mit diesem Tag'));
        }

        return ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return _ArticleListTile(article: article);
          },
        );
      },
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  final Article article;

  const _ArticleListTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return SharedArticleListTile(
      article: article,
      isRead: article.readAt != null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleReaderScreen(articleId: article.id),
          ),
        );
      },
    );
  }
}

class _HighlightList extends ConsumerWidget {
  final String tagName;

  const _HighlightList({required this.tagName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsAsync = ref.watch(tagHighlightsStreamProvider(tagName));

    return highlightsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Fehler: $err')),
      data: (highlights) {
        if (highlights.isEmpty) {
          return const Center(child: Text('Keine Highlights mit diesem Tag'));
        }

        return ListView.builder(
          itemCount: highlights.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final item = highlights[index];
            return _HighlightListTile(item: item);
          },
        );
      },
    );
  }
}

class _NoteList extends ConsumerWidget {
  final String tagName;

  const _NoteList({required this.tagName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(tagNotesStreamProvider(tagName));

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Fehler: $err')),
      data: (notes) {
        if (notes.isEmpty) {
          return const Center(child: Text('Keine Notizen mit diesem Tag'));
        }

        return ListView.builder(
          itemCount: notes.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final item = notes[index];
            return _NoteListTile(item: item);
          },
        );
      },
    );
  }
}

class _HighlightListTile extends StatelessWidget {
  final HighlightWithArticleId item;

  const _HighlightListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return SharedHighlightListTile(
      highlight: item.highlight,
      articleId: item.articleId,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleReaderScreen(
              articleId: item.articleId,
              scrollToHighlightId: item.highlight.id,
            ),
          ),
        );
      },
    );
  }
}

class _NoteListTile extends StatelessWidget {
  final NoteWithArticleId item;

  const _NoteListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return SharedNoteListTile(
      note: item.note,
      articleId: item.articleId,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleReaderScreen(
              articleId: item.articleId,
              scrollToNoteId: item.note.id,
            ),
          ),
        );
      },
    );
  }
}
