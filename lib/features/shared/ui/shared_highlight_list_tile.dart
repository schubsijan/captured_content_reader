import 'package:flutter/material.dart';
import '../../../models/highlight.dart';

class HighlightWithArticleId {
  final Highlight highlight;
  final String articleId;

  HighlightWithArticleId({required this.highlight, required this.articleId});
}

class SharedHighlightListTile extends StatelessWidget {
  final Highlight highlight;
  final String? articleId;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SharedHighlightListTile({
    super.key,
    required this.highlight,
    this.articleId,
    this.onTap,
    this.onLongPress,
  });

  Color _parseColor(String colorStr) {
    try {
      final hex = colorStr.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = _parseColor(highlight.color);
    final cleanText = highlight.text.replaceAll('\n', ' ').trim();
    final hasNote = highlight.note != null && highlight.note!.trim().isNotEmpty;
    final hasTags = highlight.tags.isNotEmpty;
    final hasContent = hasNote || hasTags;
    final bool isUnderline = highlight.type == HighlightType.underline;

    final TextStyle highlightStyle = TextStyle(
      fontStyle: FontStyle.italic,
      color: Colors.black87,
      fontSize: 13,
      height: 1.4,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
      decorationColor: isUnderline ? highlightColor : null,
      decorationThickness: isUnderline ? 3.0 : null,
      backgroundColor: isUnderline
          ? Colors.transparent
          : highlightColor.withValues(alpha: 0.4),
    );

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
                  color: highlightColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isUnderline ? 'Unterstrichen' : 'Highlight',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"$cleanText"',
                style: highlightStyle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasContent) ...[
                if (hasNote) ...[
                  const SizedBox(height: 8),
                  Text(
                    highlight.note!,
                    style: TextStyle(color: Colors.grey.shade900),
                  ),
                ],
                if (hasTags) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: highlight.tags
                        .map((tag) => _buildTagChip(tag))
                        .toList(),
                  ),
                ],
              ],
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
