import 'dart:convert';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleMetaDisplay extends StatelessWidget {
  final Article article; // Nutze den generierten 'Article' Typ, wenn möglich
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
      if (article.authors.isNotEmpty) {
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
            // 1. Site Name (nur wenn vorhanden)
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

            // 2. Trenner (nur wenn BEIDE vorhanden sind)
            if (article.siteName != null && article.publishedAt != null) ...[
              const SizedBox(width: 8),
              const Text(
                "•",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(width: 8),
            ],

            // 3. Datum (nur wenn vorhanden)
            if (article.publishedAt != null)
              Text(
                dateFormat.format(
                  article.publishedAt!,
                ), // Hier ist ! sicher, da oben geprüft
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
