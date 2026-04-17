import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../database/app_database.dart';
import '../../../main.dart';
import '../../../services/storage_access.dart';

class TagOverview {
  final String name;
  final int articleCount;
  final int highlightCount;
  final int noteCount;
  final List<String> articleIds;

  TagOverview({
    required this.name,
    required this.articleCount,
    required this.highlightCount,
    required this.noteCount,
    required this.articleIds,
  });
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final tagListProvider =
    StateNotifierProvider<TagListNotifier, AsyncValue<List<TagOverview>>>((
      ref,
    ) {
      return TagListNotifier(ref);
    });

class TagListNotifier extends StateNotifier<AsyncValue<List<TagOverview>>> {
  final Ref _ref;

  TagListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadTags();

    _ref.listen(databaseProvider, (_, __) {
      _loadTags();
    });
  }

  Future<void> _loadTags() async {
    try {
      final db = _ref.read(databaseProvider);
      final storage = _ref.read(storageServiceProvider);

      final results = await db.select(db.tagIndex).get();

      // Group by name + origin to distinguish between article tags, highlights, and notes
      final groupedByName = <String, Set<String>>{}; // Article IDs per tag
      final highlightOrigins = <String, Set<String>>{}; // Article IDs for highlights
      final noteOrigins = <String, Set<String>>{}; // Article IDs for notes

      for (final row in results) {
        final name = row.name;
        final articleId = row.articleId;
        final origin = row.origin;

        groupedByName.putIfAbsent(name, () => {});
        groupedByName[name]!.add(articleId);

        if (origin == 'highlight') {
          highlightOrigins.putIfAbsent(name, () => {});
          highlightOrigins[name]!.add(articleId);
        } else if (origin == 'note') {
          noteOrigins.putIfAbsent(name, () => {});
          noteOrigins[name]!.add(articleId);
        }
      }

      final appDir = await storage.getAppDirectory();
      final tags = <TagOverview>[];

      for (final entry in groupedByName.entries) {
        final tagName = entry.key;
        final uniqueArticleIds = entry.value.toList();
        final highlightArticleIds = highlightOrigins[tagName]?.toList() ?? [];
        final noteArticleIds = noteOrigins[tagName]?.toList() ?? [];

        int highlightCount = 0;
        int noteCount = 0;

        // Count highlights - only for articles that have this tag on a highlight
        for (final articleId in highlightArticleIds) {
          final highlightsFile = File(
            p.join(appDir.path, articleId, 'highlights.json'),
          );
          if (await highlightsFile.exists()) {
            try {
              final content = await highlightsFile.readAsString();
              final highlights = jsonDecode(content) as List;
              final matchingHighlights = highlights.where((h) {
                final tagList = h['tags'] as List<dynamic>?;
                return tagList?.contains(tagName) ?? false;
              });
              highlightCount += matchingHighlights.length;
            } catch (_) {}
          }
        }

        // Count notes - only for articles that have this tag on a note
        for (final articleId in noteArticleIds) {
          final notesFile = File(p.join(appDir.path, articleId, 'notes.json'));
          if (await notesFile.exists()) {
            try {
              final content = await notesFile.readAsString();
              final notes = jsonDecode(content) as List;
              final matchingNotes = notes.where((n) {
                final tagList = n['tags'] as List<dynamic>?;
                return tagList?.contains(tagName) ?? false;
              });
              noteCount += matchingNotes.length;
            } catch (_) {}
          }
        }

        tags.add(
          TagOverview(
            name: tagName,
            articleCount: uniqueArticleIds.length,
            highlightCount: highlightCount,
            noteCount: noteCount,
            articleIds: uniqueArticleIds,
          ),
        );
      }

      tags.sort((a, b) => b.articleCount.compareTo(a.articleCount));
      state = AsyncValue.data(tags);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void refresh() {
    _loadTags();
  }
}

final tagListInvalidatorProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(tagListProvider.notifier).refresh();
  };
});

void invalidateAllTagProviders(WidgetRef ref) {
  ref.invalidate(tagListProvider);
}

final tagArticlesProvider = FutureProvider.family<List<Article>, String>((
  ref,
  tagName,
) async {
  final db = ref.watch(databaseProvider);

  final articleIdsQuery = db.selectOnly(db.tagIndex, distinct: true)
    ..addColumns([db.tagIndex.articleId])
    ..where(db.tagIndex.name.equals(tagName));

  final rows = await articleIdsQuery.get();
  final articleIds = rows
      .map((row) => row.read(db.tagIndex.articleId)!)
      .toList();

  if (articleIds.isEmpty) return [];

  final articlesQuery = db.select(db.articles)
    ..where((t) => t.id.isIn(articleIds));

  return articlesQuery.get();
});
