import 'package:flutter/material.dart';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:captured_content_reader/features/library/providers/library_providers.dart';
import 'article_meta_display.dart';

class SharedArticleListTile extends StatelessWidget {
  final Article article;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SharedArticleListTile({
    super.key,
    required this.article,
    this.isRead = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: isRead ? Colors.grey.shade200 : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Opacity(
            opacity: isRead ? 0.6 : 1.0,
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
    );
  }
}

class DismissibleSharedArticleListTile extends StatelessWidget {
  final Article article;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final LibraryFilter filter;

  const DismissibleSharedArticleListTile({
    super.key,
    required this.article,
    required this.isRead,
    required this.onTap,
    this.onArchive,
    this.onDelete,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final isUnreadView = filter == LibraryFilter.unread;
    final archiveIcon = isUnreadView ? Icons.archive : Icons.unarchive;
    final archiveColor = isUnreadView ? Colors.green : Colors.orange;

    return Dismissible(
      key: Key(article.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: archiveColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Icon(
          archiveIcon,
          color: archiveColor.withValues(alpha: 0.8),
          size: 30,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.red, size: 30),
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
          onArchive?.call();
        } else {
          onDelete?.call();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        color: isRead ? Colors.grey.shade200 : Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Opacity(
              opacity: isRead ? 0.6 : 1.0,
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
  }
}
