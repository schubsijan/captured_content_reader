import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/library_providers.dart';
import 'tag_input_field.dart';

class ArticleTagDialog extends ConsumerStatefulWidget {
  final String articleId;
  final List<String> initialTags;

  const ArticleTagDialog({
    super.key,
    required this.articleId,
    required this.initialTags,
  });

  @override
  ConsumerState<ArticleTagDialog> createState() => _ArticleTagDialogState();
}

class _ArticleTagDialogState extends ConsumerState<ArticleTagDialog> {
  late List<String> _currentTags;

  @override
  void initState() {
    super.initState();
    _currentTags = List.from(widget.initialTags);
  }

  @override
  Widget build(BuildContext context) {
    // Holen der globalen Tags für das Autocomplete
    final allTagsAsync = ref.watch(allTagsProvider);

    return AlertDialog(
      title: const Text(
        "Artikel-Tags bearbeiten",
        style: TextStyle(fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            allTagsAsync.when(
              data: (availableTags) => TagInputField(
                initialTags: _currentTags,
                availableTags:
                    availableTags, // Hier wird das Autocomplete gefüttert
                onTagsChanged: (tags) => _currentTags = tags,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => TagInputField(
                initialTags: _currentTags,
                availableTags: const [],
                onTagsChanged: (tags) => _currentTags = tags,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tippe ein Tag ein und bestätige mit Enter oder wähle einen Vorschlag.",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("ABBRECHEN"),
        ),
        ElevatedButton(
          onPressed: () async {
            // Speichern über das Repository (File-First)
            await ref
                .read(articleRepositoryProvider)
                .updateArticleTags(widget.articleId, _currentTags);

            // Invalidierung damit die globale Liste und die Anzeige aktualisiert werden
            ref.invalidate(allTagsProvider);
            ref.invalidate(tagsForArticleProvider(widget.articleId));

            if (mounted) Navigator.pop(context);
          },
          child: const Text("SPEICHERN"),
        ),
      ],
    );
  }
}
