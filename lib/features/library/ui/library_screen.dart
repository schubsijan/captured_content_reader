import 'package:captured_content_reader/features/shared/ui/article_meta_display.dart';
import 'package:captured_content_reader/services/library_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_providers.dart';
import '../../reader/ui/article_reader_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final bool isArchive;

  const LibraryScreen({super.key, this.isArchive = false});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncArticles = widget.isArchive
        ? ref.watch(readArticlesProvider)
        : ref.watch(unreadArticlesProvider);

    final title = widget.isArchive ? "Archiv" : "Meine Bibliothek";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isArchive
                              ? Icons.archive_outlined
                              : Icons.library_books_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.isArchive
                              ? 'Keine gelesenen Artikel'
                              : 'Keine ungelesenen Artikel',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Dismissible(
                  key: Key(article.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (widget.isArchive ? Colors.orange : Colors.green)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24),
                    child: Icon(
                      widget.isArchive ? Icons.unarchive : Icons.archive,
                      color: widget.isArchive ? Colors.orange : Colors.green,
                      size: 30,
                    ),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Artikel löschen?'),
                          content: const Text(
                            'Diese Aktion kann nicht rückgängig gemacht werden.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Abbrechen'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Löschen',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      ref
                          .read(articleRepositoryProvider)
                          .updateReadStatus(article.id, article.readAt == null);
                    } else {
                      ref
                          .read(articleRepositoryProvider)
                          .deleteArticle(article.id);
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 0,
                    color: article.readAt != null
                        ? Colors.grey.shade200
                        : Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArticleReaderScreen(articleId: article.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Opacity(
                          opacity: article.readAt != null ? 0.6 : 1.0,
                          child: ArticleMetaDisplay(
                            article: article,
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
              },
            );
          },
        ),
      ),
    );
  }
}
