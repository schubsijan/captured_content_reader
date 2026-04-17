import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/article_note.dart';

class NoteWithArticleId {
  final ArticleNote note;
  final String articleId;

  NoteWithArticleId({required this.note, required this.articleId});
}

class SharedNoteListTile extends StatelessWidget {
  final ArticleNote note;
  final String? articleId;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SharedNoteListTile({
    super.key,
    required this.note,
    this.articleId,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(note.createdAt);
    final hasTags = note.tags.isNotEmpty;

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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Notiz',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: TextStyle(color: Colors.grey.shade800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasTags) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: note.tags.map((tag) => _buildTagChip(tag)).toList(),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
