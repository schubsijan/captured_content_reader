import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleMetaDisplay extends StatelessWidget {
  final dynamic article; // Nutze den generierten 'Article' Typ, wenn möglich
  final Widget? middleContent; // Optional: Für den Titel in der Library
  final bool compact; // Optional: Falls du Abstände variieren willst

  const ArticleMetaDisplay({
    super.key,
    required this.article,
    this.middleContent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    // 1. Autoren Logik kapseln
    List<String> authorsList = [];
    try {
      if (article.authors != null && article.authors.isNotEmpty) {
        authorsList = List<String>.from(jsonDecode(article.authors));
      }
    } catch (_) {
      // Fail silently
    }
    final authorsString = authorsList.join(" & ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- ZEILE 1: Site Name & Datum ---
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
              dateFormat.format(article.savedAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        // --- MITTELTEIL (z.B. Titel) ---
        if (middleContent != null) ...[
          SizedBox(height: compact ? 4 : 8),
          middleContent!,
        ],

        // --- ZEILE 3: Autoren ---
        if (authorsString.isNotEmpty) ...[
          SizedBox(height: compact ? 4 : 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  authorsString,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
