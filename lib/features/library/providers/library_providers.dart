import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/app_database.dart';
import '../../../main.dart'; // Zugriff auf den globalen databaseProvider (oder du definierst ihn hier neu)
import '../data/article_repository.dart';
import '../../../services/library_sync_service.dart';
import '../../../services/storage_access.dart';

enum LibraryFilter { unread, read }

final libraryFilterProvider = StateProvider<LibraryFilter>(
  (ref) => LibraryFilter.unread,
);

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final storage = ref.watch(storageServiceProvider);
  return ArticleRepository(db, storage);
});

final unreadArticlesProvider = StreamProvider<List<Article>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.watchUnreadArticles();
});

final readArticlesProvider = StreamProvider<List<Article>>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.watchReadArticles();
});

final singleArticleProvider = StreamProvider.family<Article?, String>((
  ref,
  id,
) {
  final db = ref.watch(databaseProvider);

  // Abfrage auf die DB für genau eine ID
  return (db.select(
    db.articles,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();
});

// 1. Storage Provider (simpel)
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

// 2. Sync Service Provider
final librarySyncServiceProvider = Provider<LibrarySyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final storage = ref.watch(storageServiceProvider);
  return LibrarySyncService(storage, db);
});
