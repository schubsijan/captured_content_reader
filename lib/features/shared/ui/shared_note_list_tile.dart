import 'package:flutter/material.dart';
import '../../../models/article_note.dart';

class NoteWithArticleId {
  final ArticleNote note;
  final String articleId;

  NoteWithArticleId({required this.note, required this.articleId});
}

class SharedNoteListTile extends StatelessWidget {
  final ArticleNote note;
  final String? articleId;
  final String? articleTitle;
  final String? articleAuthors;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SharedNoteListTile({
    super.key,
    required this.note,
    this.articleId,
    this.articleTitle,
    this.articleAuthors,
    this.onTap,
    this.onLongPress,
  });

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTags = note.tags.isNotEmpty;

    final cardChildren = <Widget>[];

    if (articleTitle != null) {
      cardChildren.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              articleTitle!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (articleAuthors != null && articleAuthors!.isNotEmpty)
              Text(
                articleAuthors!,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    cardChildren.add(
      Text(
        note.content,
        style: TextStyle(color: Colors.grey.shade800),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (hasTags) {
      cardChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: note.tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cardChildren,
          ),
        ),
      ),
    );
  }
}

