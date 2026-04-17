import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../main.dart';
import '../../../services/storage_access.dart';
import '../../library/providers/library_providers.dart' show allTagsProvider, tagsForArticleProvider;

final _tagChangeTriggerProvider = StateProvider<int>((ref) => 0);

class TagWithCounts {
  final String name;
  final int articleCount;
  final int highlightCount;
  final int noteCount;
  final List<String> allArticleIds;
  
  TagWithCounts({
    required this.name,
    required this.articleCount,
    required this.highlightCount,
    required this.noteCount,
    required this.allArticleIds,
  });
}

class _TagDataAccumulator {
  final List<String> articleIdsForArticle = [];
  final List<String> articleIdsForHighlight = [];
  final List<String> articleIdsForNote = [];
}

final tagListStreamProvider = StreamProvider<List<TagWithCounts>>((ref) {
  ref.watch(_tagChangeTriggerProvider);
  final db = ref.watch(databaseProvider);
  final storage = StorageService();
  
  return db.select(db.tagIndex).watch().asyncExpand((_) async* {
    final results = await db.select(db.tagIndex).get();
    
    final grouped = <String, _TagDataAccumulator>{};
    for (final row in results) {
      grouped.putIfAbsent(row.name, () => _TagDataAccumulator());
      final origin = row.origin;
      if (origin == 'article') {
        grouped[row.name]!.articleIdsForArticle.add(row.articleId);
      } else if (origin == 'highlight') {
        grouped[row.name]!.articleIdsForHighlight.add(row.articleId);
      } else if (origin == 'note') {
        grouped[row.name]!.articleIdsForNote.add(row.articleId);
      }
    }
    
    final appDir = await storage.getAppDirectory();
    final tags = <TagWithCounts>[];
    
    for (final entry in grouped.entries) {
      final tagName = entry.key;
      final articleIdsForArticle = entry.value.articleIdsForArticle.toSet().toList();
      
      // Count highlights by reading from files
      int highlightCount = 0;
      final highlightArticleIds = entry.value.articleIdsForHighlight.toSet().toList();
      for (final articleId in highlightArticleIds) {
        final highlightsFile = File(p.join(appDir.path, articleId, 'highlights.json'));
        if (await highlightsFile.exists()) {
          try {
            final content = await highlightsFile.readAsString();
            final highlights = jsonDecode(content) as List;
            final matchingHighlights = highlights.where((h) {
              final tagList = (h['tags'] as List<dynamic>?)?.cast<String>() ?? [];
              return tagList.contains(tagName);
            });
            highlightCount += matchingHighlights.length;
          } catch (_) {}
        }
      }
      
      // Count notes by reading from files
      int noteCount = 0;
      final noteArticleIds = entry.value.articleIdsForNote.toSet().toList();
      for (final articleId in noteArticleIds) {
        final notesFile = File(p.join(appDir.path, articleId, 'notes.json'));
        if (await notesFile.exists()) {
          try {
            final content = await notesFile.readAsString();
            final notes = jsonDecode(content) as List;
            final matchingNotes = notes.where((n) {
              final tagList = (n['tags'] as List<dynamic>?)?.cast<String>() ?? [];
              return tagList.contains(tagName);
            });
            noteCount += matchingNotes.length;
          } catch (_) {}
        }
      }
      
      final allArticleIds = {
        ...articleIdsForArticle,
        ...highlightArticleIds,
        ...noteArticleIds,
      }.toList();
      
      tags.add(TagWithCounts(
        name: tagName,
        articleCount: articleIdsForArticle.length,
        highlightCount: highlightCount,
        noteCount: noteCount,
        allArticleIds: allArticleIds,
      ));
    }
    
    tags.sort((a, b) => b.articleCount.compareTo(a.articleCount));
    yield tags;
  });
});

void triggerTagChange(WidgetRef ref) {
  ref.read(_tagChangeTriggerProvider.notifier).state++;
  ref.invalidate(allTagsProvider);
  ref.invalidate(tagListStreamProvider);
  
  _reloadAllTagsInCache(ref);
}

Future<void> _reloadAllTagsInCache(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  await db.getAllTags();
  ref.invalidate(allTagsProvider);
  
  final articleIds = await db.select(db.articles).get();
  for (final article in articleIds) {
    ref.invalidate(tagsForArticleProvider(article.id));
  }
}

Future<void> renameTag(WidgetRef ref, String oldName, String newName) async {
  final db = ref.read(databaseProvider);
  final storage = ref.read(storageServiceProvider);
  final appDir = await storage.getAppDirectory();
  
  if (newName.trim().isEmpty || newName == oldName) return;
  
  await db.customStatement(
    'UPDATE ${db.tagIndex.actualTableName} SET name = ? WHERE name = ?',
    [newName.trim(), oldName],
  );
  
  final articleIdsQuery = db.selectOnly(db.tagIndex, distinct: true)
    ..addColumns([db.tagIndex.articleId])
    ..where(db.tagIndex.name.equals(newName.trim()));
  final rows = await articleIdsQuery.get();
  final articleIds = rows.map((row) => row.read(db.tagIndex.articleId)!).toSet();
  
  for (final articleId in articleIds) {
    final metaFile = File(p.join(appDir.path, articleId, 'meta.json'));
    if (await metaFile.exists()) {
      try {
        final content = await metaFile.readAsString();
        final meta = jsonDecode(content);
        final tags = (meta['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        if (tags.contains(oldName)) {
          final newTags = tags.map((t) => t == oldName ? newName.trim() : t).toList();
          meta['tags'] = newTags;
          await metaFile.writeAsString(jsonEncode(meta));
        }
      } catch (_) {}
    }
    
    final highlightsFile = File(p.join(appDir.path, articleId, 'highlights.json'));
    if (await highlightsFile.exists()) {
      try {
        final content = await highlightsFile.readAsString();
        final highlights = jsonDecode(content) as List;
        bool changed = false;
        for (final h in highlights) {
          final tags = (h['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          if (tags.contains(oldName)) {
            final idx = tags.indexOf(oldName);
            tags[idx] = newName.trim();
            h['tags'] = tags;
            changed = true;
          }
        }
        if (changed) {
          await highlightsFile.writeAsString(jsonEncode(highlights));
        }
      } catch (_) {}
    }
    
    final notesFile = File(p.join(appDir.path, articleId, 'notes.json'));
    if (await notesFile.exists()) {
      try {
        final content = await notesFile.readAsString();
        final notes = jsonDecode(content) as List;
        bool changed = false;
        for (final n in notes) {
          final tags = (n['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          if (tags.contains(oldName)) {
            final idx = tags.indexOf(oldName);
            tags[idx] = newName.trim();
            n['tags'] = tags;
            changed = true;
          }
        }
        if (changed) {
          await notesFile.writeAsString(jsonEncode(notes));
        }
      } catch (_) {}
    }
  }
  
  triggerTagChange(ref);
}

Future<void> deleteTag(WidgetRef ref, String tagName) async {
  final db = ref.read(databaseProvider);
  final storage = ref.read(storageServiceProvider);
  final appDir = await storage.getAppDirectory();
  
  final articleIdsQuery = db.selectOnly(db.tagIndex, distinct: true)
    ..addColumns([db.tagIndex.articleId])
    ..where(db.tagIndex.name.equals(tagName));
  final rows = await articleIdsQuery.get();
  final articleIds = rows.map((row) => row.read(db.tagIndex.articleId)!).toSet();
  
  for (final articleId in articleIds) {
    final metaFile = File(p.join(appDir.path, articleId, 'meta.json'));
    if (await metaFile.exists()) {
      try {
        final content = await metaFile.readAsString();
        final meta = jsonDecode(content);
        final tags = (meta['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        if (tags.contains(tagName)) {
          final newTags = tags.where((t) => t != tagName).toList();
          meta['tags'] = newTags;
          await metaFile.writeAsString(jsonEncode(meta));
        }
      } catch (_) {}
    }
    
    final highlightsFile = File(p.join(appDir.path, articleId, 'highlights.json'));
    if (await highlightsFile.exists()) {
      try {
        final content = await highlightsFile.readAsString();
        final highlights = jsonDecode(content) as List;
        bool changed = false;
        for (final h in highlights) {
          final tags = (h['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          if (tags.contains(tagName)) {
            final newTags = tags.where((t) => t != tagName).toList();
            h['tags'] = newTags;
            changed = true;
          }
        }
        if (changed) {
          await highlightsFile.writeAsString(jsonEncode(highlights));
        }
      } catch (_) {}
    }
    
    final notesFile = File(p.join(appDir.path, articleId, 'notes.json'));
    if (await notesFile.exists()) {
      try {
        final content = await notesFile.readAsString();
        final notes = jsonDecode(content) as List;
        bool changed = false;
        for (final n in notes) {
          final tags = (n['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          if (tags.contains(tagName)) {
            final newTags = tags.where((t) => t != tagName).toList();
            n['tags'] = newTags;
            changed = true;
          }
        }
        if (changed) {
          await notesFile.writeAsString(jsonEncode(notes));
        }
      } catch (_) {}
    }
  }
  
  await db.customStatement(
    'DELETE FROM ${db.tagIndex.actualTableName} WHERE name = ?',
    [tagName],
  );
  
  triggerTagChange(ref);
}