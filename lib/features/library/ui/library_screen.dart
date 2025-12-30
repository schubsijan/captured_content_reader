import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/library_providers.dart';
import '../../reader/ui/article_reader_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(librarySyncServiceProvider).syncFileSystemToDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Welcher Filter ist aktiv?
    final currentFilter = ref.watch(libraryFilterProvider);

    // 2. Welchen Stream sollen wir nutzen?
    final asyncArticles = currentFilter == LibraryFilter.unread
        ? ref.watch(unreadArticlesProvider)
        : ref.watch(readArticlesProvider);

    final title = currentFilter == LibraryFilter.unread
        ? "Meine Bibliothek"
        : "Archiv";

    return Scaffold(
      appBar: AppBar(title: Text(title)),

      // <--- NEU: Der Drawer (Hamburger Menü)
      // Flutter fügt automatisch das Icon in die AppBar ein
      // und aktiviert die Swipe-Geste vom linken Rand.
      drawer: const MainDrawer(),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(librarySyncServiceProvider).syncFileSystemToDatabase();
        },
        child: asyncArticles.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Fehler: $err')),
          data: (articles) {
            if (articles.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  Center(
                    child: Text(
                      currentFilter == LibraryFilter.unread
                          ? "Alles gelesen! 🎉"
                          : "Archiv leer.",
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: articles.length,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                final article = articles[index];
                // Wir übergeben den Filter, damit das Tile weiß, wie es swipen soll
                return ArticleListTile(
                  article: article,
                  currentFilter: currentFilter,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// <--- NEU: Drawer Widget
class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(libraryFilterProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.library_books, size: 48),
                const SizedBox(height: 12),
                Text(
                  'CleanRead',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inbox),
            title: const Text('Bibliothek'),
            selected: currentFilter == LibraryFilter.unread,
            onTap: () {
              // State ändern
              ref.read(libraryFilterProvider.notifier).state =
                  LibraryFilter.unread;
              Navigator.pop(context); // Drawer schließen
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archiv (Gelesen)'),
            selected: currentFilter == LibraryFilter.read,
            onTap: () {
              ref.read(libraryFilterProvider.notifier).state =
                  LibraryFilter.read;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// <--- UPDATE: ArticleListTile mit Kontext-Logik
class ArticleListTile extends ConsumerWidget {
  final dynamic article;
  final LibraryFilter currentFilter; // <--- NEU

  const ArticleListTile({
    super.key,
    required this.article,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    // Wir drehen die Logik um, je nachdem wo wir sind
    final bool isUnreadView = currentFilter == LibraryFilter.unread;

    // Bibliothek: Swipe markiert als Gelesen (True)
    // Archiv: Swipe markiert als Ungelesen (False) -> "Zurück in Bibliothek"
    final bool targetStatus = isUnreadView;

    final icon = isUnreadView ? Icons.archive : Icons.unarchive;
    final color = isUnreadView ? Colors.green : Colors.orange;
    final text = isUnreadView ? "Archiviert" : "Wiederhergestellt";

    return Dismissible(
      key: Key(article.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2), // Hellerer Hintergrund
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Icon(icon, color: color.withOpacity(0.8), size: 30),
      ),
      onDismissed: (direction) {
        ref
            .read(articleRepositoryProvider)
            .updateReadStatus(article.id, targetStatus);

        // 1. Alte Snackbars sofort entfernen (verhindert Warteschlange)
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(text),
            duration: const Duration(milliseconds: 2000),

            behavior: SnackBarBehavior.floating,

            action: SnackBarAction(
              label: "Rückgängig",
              textColor: Colors.yellowAccent,
              onPressed: () {
                ref
                    .read(articleRepositoryProvider)
                    .updateReadStatus(article.id, !targetStatus);
                // Beim Klick auf Undo die SnackBar sofort ausblenden
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        // Ausgegraut im Archiv (Visual Cues)
        color: isUnreadView ? Colors.grey.shade50 : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ArticleReaderScreen(articleId: article.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Opacity(
              // Text etwas blasser im Archiv
              opacity: isUnreadView ? 1.0 : 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (article.siteName != null) ...[
                        Flexible(
                          child: Text(
                            article.siteName!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "•",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        // Im Archiv zeigen wir vielleicht eher "Zuletzt geändert"?
                        // Aber savedAt ist auch ok. Bleiben wir konsistent.
                        dateFormat.format(article.savedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
