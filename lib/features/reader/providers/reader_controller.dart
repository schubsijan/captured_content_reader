import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../database/app_database.dart';
import '../../../main.dart'; // für databaseProvider
import '../../../models/highlight.dart';
import '../../library/providers/library_providers.dart';
import '../../shared/ui/plain_text_note_dialog.dart';
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
          break;
        case 'update':
          final id = data['id'];
          final color = data['color'];
          await highlightService.updateHighlight(id, newColor: color);
          break;
        case 'edit_note':
          final id = data['id'];
          final highlights = await highlightService.loadHighlights();
          final highlight = highlights.firstWhere((h) => h.id == id);
          final hasNote = highlight.note != null && highlight.note!.trim().isNotEmpty;
          final availableTags = await ref.read(allTagsProvider.future);

          if (context.mounted) {
            final result = await showDialog<(String, List<String>)>(
              context: context,
              builder: (context) => PlainTextNoteDialog(
                title: hasNote ? 'Highlight Notiz bearbeiten' : 'Notiz hinzufügen',
                initialText: highlight.note ?? '',
                initialTags: highlight.tags,
                availableTags: availableTags,
                showDeleteButton: hasNote,
              ),
            );

            if (result != null) {
              final newText = result.$1.trim();
              final newTags = result.$2;
              final isNotEmpty = newText.isNotEmpty;

              await highlightService.updateHighlight(
                id,
                newNote: isNotEmpty ? newText : null,
                clearNote: !isNotEmpty,
                newTags: newTags,
              );

              final jsNote = isNotEmpty ? jsonEncode(newText) : 'null';
              final jsTags = jsonEncode(newTags);
              await state.webViewController?.runJavaScript(
                "window.cleanReadEngine.updateNoteIcon('$id', $jsNote, $jsTags);",
              );
              ref.invalidate(allTagsProvider);
            }
          }
          break;
        case 'delete':
          await highlightService.deleteHighlight(data['id']);
          break;
      }
    } catch (e) {
      print("Error handling JS message: $e");
    }
  }
}

final readerControllerProvider =
    NotifierProvider.autoDispose.family<ReaderController, ReaderState, String>(
  ReaderController.new,
);
