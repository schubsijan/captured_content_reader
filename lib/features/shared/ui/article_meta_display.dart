import 'dart:convert';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:captured_content_reader/features/tags/ui/tag_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../library/providers/library_providers.dart';
import 'article_tag_dialog.dart';

class ArticleMetaDisplay extends ConsumerWidget {
  final Article article;
  final Widget? middleContent;
  final bool compact;
  final bool showTopRow;
  final bool showAuthors;
  final bool showTags;

  const ArticleMetaDisplay({
    super.key,
    required this.article,
    this.middleContent,
    this.compact = false,
    this.showTopRow = true,
    this.showAuthors = true,
    this.showTags = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final tagsAsync = ref.watch(tagsForArticleProvider(article.id));

    List<String> authorsList = [];
    try {
      if (article.authors.isNotEmpty) {
        authorsList = List<String>.from(jsonDecode(article.authors));
      }
    } catch (_) {}
    final authorsString = authorsList.join(" & ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- ZEILE 1: Webseite & Datum ---
        if (showTopRow)
          Row(
            children: [
              if (article.siteName != null)
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
              if (article.siteName != null && article.publishedAt != null) ...[
                const SizedBox(width: 8),
                const Text(
                  "•",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 8),
              ],
              if (article.publishedAt != null)
                Text(
                  dateFormat.format(article.publishedAt!),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),

        if (middleContent != null) ...[
          SizedBox(height: compact ? 2 : 4),
          middleContent!,
        ],

        // --- ZEILE 3: Autoren ---
        if (showAuthors && authorsString.isNotEmpty) ...[
          SizedBox(height: compact ? 1 : 2),
          Text(
            authorsString,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // --- ZEILE 4: Artikel-Tags ---
        if (showTags)
          Padding(
            padding: EdgeInsets.only(
              top: compact ? 2 : 4,
            ), // Reduzierter Abstand nach oben zu den Autoren
            child: Row(
              children: [
                Expanded(
                  child: tagsAsync.when(
                    data: (tags) {
                      if (tags.isEmpty) return const SizedBox.shrink();
                      return ShaderMask(
                        shaderCallback: (Rect rect) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.85, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.hardEdge,
                          child: Row(
                            children: [
                              ...tags.map(
                                (tag) => InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: _buildTagChip(tag),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TagDetailScreen(tagName: tag),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.only(left: 4),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.6),
                  ),
                  onPressed: () {
                    final currentTags = tagsAsync.value ?? [];
                    showDialog(
                      context: context,
                      builder: (context) => ArticleTagDialog(
                        articleId: article.id,
                        initialTags: currentTags,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }
}
