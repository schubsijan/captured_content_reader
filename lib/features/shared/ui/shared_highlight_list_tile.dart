import 'package:flutter/material.dart';
import '../../../models/highlight.dart';

class SharedHighlightListTile extends StatelessWidget {
  final Highlight highlight;
  final String? articleId;
  final String? articleTitle;
  final String? articleAuthors;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SharedHighlightListTile({
    super.key,
    required this.highlight,
    this.articleId,
    this.articleTitle,
    this.articleAuthors,
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
    final highlightColor = _parseColor(highlight.color);
    final cleanText = highlight.text.replaceAll('\n', ' ').trim();
    final hasNote = highlight.note != null && highlight.note!.trim().isNotEmpty;
    final hasTags = highlight.tags.isNotEmpty;
    final bool isUnderline = highlight.type == HighlightType.underline;

    final highlightStyle = TextStyle(
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

    final cardChildren = <Widget>[];
    
    if (articleTitle != null) {
      cardChildren.add(Column(
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
      ));
    }
    
    cardChildren.add(Text(
      '"$cleanText"',
      style: highlightStyle,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    ));
    
    if (hasNote) {
      cardChildren.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          highlight.note!,
          style: TextStyle(color: Colors.grey.shade900),
        ),
      ));
    }
    
    if (hasTags) {
      cardChildren.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 6.0,
          runSpacing: 4.0,
          children: highlight.tags
              .map((tag) => _buildTagChip(tag))
              .toList(),
        ),
      ));
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