import 'package:captured_content_reader/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/library_providers.dart';

class ArticleActions {
  // --- 1. LESESTATUS ÄNDERN (MIT SNACKBAR & UNDO) ---
  static void toggleReadStatus(
    BuildContext context,
    WidgetRef ref,
    Article article, // 'dynamic' oder der generierte 'Article' Typ
  ) {
    final bool currentStatus = article.isRead;
    final bool newStatus = !currentStatus;
    final String feedbackText = newStatus ? "Archiviert" : "Wiederhergestellt";

    // 1. Repo Update
    ref.read(articleRepositoryProvider).updateReadStatus(article.id, newStatus);

    // 2. Feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedbackText),
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "RÜCKGÄNGIG",
          textColor: Colors.yellowAccent,
          onPressed: () {
            // Undo Logik
            ref
                .read(articleRepositoryProvider)
                .updateReadStatus(article.id, currentStatus);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // 3. Force Close Timer Hack
    Future.delayed(const Duration(milliseconds: 2500), () {
      try {
        controller.close();
      } catch (_) {}
    });
  }

  // --- 2. LÖSCHEN DIALOG ANZEIGEN (Gibt true zurück, wenn bestätigt) ---
  static Future<bool> confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Löschen?"),
            content: const Text(
              "Dieser Artikel wird endgültig vom Gerät entfernt.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Abbrechen"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Löschen",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false; // Falls Dialog dismissed wird, return false
  }

  // --- 3. LÖSCHEN AUSFÜHREN ---
  static Future<void> executeDelete(
    BuildContext context,
    WidgetRef ref,
    String articleId, {
    bool popScreen = false, // True für Reader-Screen
  }) async {
    // DB & File löschen
    await ref.read(articleRepositoryProvider).deleteArticle(articleId);

    if (context.mounted) {
      // Ggf. Screen verlassen (Reader)
      if (popScreen) Navigator.pop(context);

      // Feedback
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Artikel gelöscht"),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
