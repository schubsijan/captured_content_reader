import 'dart:convert';
import 'package:captured_content_reader/services/library_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

import '../../../database/app_database.dart';
import '../../../main.dart'; // für databaseProvider
import '../../../models/highlight.dart';
import '../../library/providers/library_providers.dart';
import '../../shared/ui/plain_text_note_dialog.dart';
import '../../tags/providers/tag_providers.dart';
import '../services/article_note_service.dart';
import '../services/highlight_service.dart';

class ReaderState {
  final bool isLoadingFile;
  final bool uiVisible;
  final WebViewController? webViewController;

  ReaderState({
    this.isLoadingFile = true,
    this.uiVisible = true,
    this.webViewController,
  });

  ReaderState copyWith({
    bool? isLoadingFile,
    bool? uiVisible,
    WebViewController? webViewController,
  }) {
    return ReaderState(
      isLoadingFile: isLoadingFile ?? this.isLoadingFile,
      uiVisible: uiVisible ?? this.uiVisible,
      webViewController: webViewController ?? this.webViewController,
    );
  }
}

class ReaderController extends AutoDisposeFamilyNotifier<ReaderState, String> {
  late HighlightService highlightService;
  late ArticleNoteService noteService;

  @override
  ReaderState build(String arg) {
    _initServices();
    return ReaderState();
  }

  Future<void> _initServices() async {
    final syncService = ref.read(librarySyncServiceProvider);

    highlightService = HighlightService(arg, syncService);
    await highlightService.init();

    final db = ref.read(databaseProvider);
    noteService = ArticleNoteService(arg, db, syncService);
    await noteService.init();
  }

  void initWebView(WebViewController controller) {
    state = state.copyWith(webViewController: controller);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoadingFile: loading);
  }

  Future<void> handleJsMessage(String message, BuildContext context) async {
    try {
      final Map<String, dynamic> payload = jsonDecode(message);
      final String action = payload['action'];

      if (action == 'ui_control') {
        final String command = payload['data'];
        if (command == 'hide_ui' && state.uiVisible) {
          state = state.copyWith(uiVisible: false);
        } else if (command == 'show_ui' && !state.uiVisible) {
          state = state.copyWith(uiVisible: true);
        }
        return;
      }

      final dynamic data = payload['data'];

      switch (action) {
        case 'create':
          final highlight = Highlight.fromJson(data);
          await highlightService.addHighlight(highlight);
          ref.invalidate(tagListProvider);
          break;
        case 'update':
          final id = data['id'];
          final color = data['color'];
          final typeStr = data['type'];
          await highlightService.updateHighlight(
            id,
            newColor: color,
            newType: typeStr != null
                ? HighlightType.values.byName(typeStr)
                : null,
          );
          break;
        case 'edit_note':
          final id = data['id'];
          final highlights = await highlightService.loadHighlights();
          final highlight = highlights.firstWhere((h) => h.id == id);
          final hasNote =
              highlight.note != null && highlight.note!.trim().isNotEmpty;
          final availableTags = await ref.read(allTagsProvider.future);

          if (context.mounted) {
            final result = await showDialog<(String, List<String>)>(
              context: context,
              builder: (context) => PlainTextNoteDialog(
                title: hasNote
                    ? 'Highlight Notiz bearbeiten'
                    : 'Notiz hinzufügen',
                initialText: highlight.note ?? '',
                initialTags: highlight.tags,
                availableTags: availableTags,
                showDeleteButton: hasNote,
              ),
            );

            // In case 'edit_note':
            if (result != null) {
              final newText = result.$1.trim();
              final newTags = result.$2;

              await highlightService.updateHighlight(
                id,
                newNote: newText.isNotEmpty ? newText : null,
                clearNote: newText.isEmpty,
                newTags: newTags,
              );

              // WICHTIG: Übergib newTags direkt als Array-Struktur für JS
              final jsNote = newText.isNotEmpty ? jsonEncode(newText) : 'null';
              final jsTags = jsonEncode(newTags); // Das erzeugt "[tag1, tag2]"

              print("sending updateNoteIcon");
              await state.webViewController?.runJavaScript(
                "window.cleanReadEngine.updateNoteIcon('$id', $jsNote, $jsTags);",
              );

              ref.invalidate(allTagsProvider);
              ref.invalidate(tagListProvider);
            }
          }
          break;
        case 'delete':
          await highlightService.deleteHighlight(data['id']);
          ref.invalidate(tagListProvider);
          break;
        case 'copy_to_clipboard':
          final String textToCopy = data['text'];
          await Clipboard.setData(ClipboardData(text: textToCopy));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Text in Zwischenablage kopiert"),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                width: 250, // Kompakt halten
              ),
            );
          }
          break;
      }
    } catch (e) {
      print("Error handling JS message: $e");
    }
  }
}

final readerControllerProvider = NotifierProvider.autoDispose
    .family<ReaderController, ReaderState, String>(ReaderController.new);

final scrollToNoteIdProvider = StateProvider<String?>((ref) => null);
