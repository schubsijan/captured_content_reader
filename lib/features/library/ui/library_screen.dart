import 'package:captured_content_reader/features/shared/ui/article_actions.dart';
import 'package:captured_content_reader/features/shared/ui/article_meta_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class ArticleListTile extends ConsumerWidget {
  final dynamic article;
  final LibraryFilter currentFilter;

  const ArticleListTile({
    super.key,
    required this.article,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- LOGIK FÜR ARCHIVIEREN (Swipe RECHTS) ---
    final bool isUnreadView = currentFilter == LibraryFilter.unread;

    final archiveIcon = isUnreadView ? Icons.archive : Icons.unarchive;
    final archiveColor = isUnreadView ? Colors.green : Colors.orange;

    return Dismissible(
      key: Key(article.id),
      // Jetzt erlauben wir BEIDE Richtungen
      direction: DismissDirection.horizontal,

      // 1. Hintergrund für Swipe nach RECHTS (Archivieren)
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: archiveColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Icon(
          archiveIcon,
          color: archiveColor.withOpacity(0.8),
          size: 30,
        ),
      ),

      // 2. Hintergrund für Swipe nach LINKS (Löschen)
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2), // Roter Hintergrund
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight, // Icon rechts
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete, color: Colors.red.withOpacity(0.8), size: 30),
      ),

      // 3. Sicherheitsabfrage nur beim Löschen (Optional, aber empfohlen)
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe Links -> Dialog
          return await ArticleActions.confirmDelete(context);
        }
        return true; // Swipe Rechts -> Immer OK
      },

      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // --- ARCHIVIEREN ---
          // Hier müssen wir aufpassen: Die UI entfernt das Item visuell sofort.
          // Unser Helper macht genau das Richtige (Status ändern + Snackbar).
          ArticleActions.toggleReadStatus(context, ref, article);
        } else if (direction == DismissDirection.endToStart) {
          // --- LÖSCHEN ---
          // Hier rufen wir nur executeDelete auf, da confirmDismiss schon true war.
          // popScreen ist false, da wir in der Liste bleiben.
          ArticleActions.executeDelete(
            context,
            ref,
            article.id,
            popScreen: false,
          );
        }
      },

      // Das eigentliche Listen-Item (Card)
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
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
              opacity: isUnreadView ? 1.0 : 0.6,
              child: ArticleMetaDisplay(
                article: article,
                // Wir übergeben den Titel als Middle Content
                middleContent: Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
