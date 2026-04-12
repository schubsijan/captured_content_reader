import 'dart:io';
import '../../../main.dart';
import 'notes_bottom_sheet.dart';
import 'dart:convert';
import 'package:captured_content_reader/features/reader/ui/edit_meta_dialog.dart';
import 'package:captured_content_reader/features/shared/ui/article_actions.dart';
import 'package:captured_content_reader/features/shared/ui/article_meta_display.dart';
import 'package:captured_content_reader/features/shared/ui/plain_text_note_dialog.dart';
import '../services/article_note_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../database/app_database.dart';
import '../../../models/article_meta.dart';
import '../../../services/storage_access.dart';
import '../../library/providers/library_providers.dart';
import '../../../models/highlight.dart';
import '../services/highlight_service.dart';

class ArticleReaderScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleReaderScreen({super.key, required this.articleId});

  @override
  ConsumerState<ArticleReaderScreen> createState() =>
      _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends ConsumerState<ArticleReaderScreen> {
  WebViewController? _controller;
  bool _isLoadingFile = true;
  late HighlightService _highlightService;
  late ArticleNoteService _noteService;

  bool _uiVisible = true;
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initSequence();
  }

  Future<void> _initSequence() async {
    final syncService = ref.read(librarySyncServiceProvider);

    _highlightService = HighlightService(widget.articleId, syncService);
    await _highlightService.init();

    final db = ref.read(databaseProvider);
    _noteService = ArticleNoteService(widget.articleId, db, syncService);
    await _noteService.init();

    await _prepareWebView();
  }

  Future<void> _prepareWebView() async {
    final storage = StorageService();
    final appDir = await storage.getAppDirectory();
    final htmlFile = File(
      p.join(appDir.path, widget.articleId, 'content.html'),
    );

    if (!await htmlFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fehler: content.html nicht gefunden!")),
        );
      }
      return;
    }

    final controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'CleanReadApp',
        onMessageReceived: _handleJsMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            await _injectHighlightScripts(controller);
            await _restoreHighlights(controller);

            if (mounted) {
              setState(() {
                _isLoadingFile = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('file://')) {
              return NavigationDecision.navigate;
            }

            if (request.url.startsWith('http://') ||
                request.url.startsWith('https://')) {
              final uri = Uri.parse(request.url);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Fehler beim Öffnen des Links: $e")),
                  );
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadFile(htmlFile.path);

    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }
  }

  Future<void> _injectHighlightScripts(WebViewController controller) async {
    try {
      final vanJs = await rootBundle.loadString(
        'assets/js/van-1.6.0.nomodule.min.js',
      );
      final appJs = await rootBundle.loadString('assets/js/highlight.js');
      final scrollJs = await rootBundle.loadString(
        'assets/js/scroll_listener.js',
      );

      await controller.runJavaScript(vanJs);
      await controller.runJavaScript(appJs);
      await controller.runJavaScript(scrollJs);

      await controller.runJavaScript("""
        const style = document.createElement('style');
        style.innerHTML = `
          .cr-highlight {
            touch-action: manipulation;
            /* Verhindert den 300ms Delay bei manchen Browsern und das automatische Zoomen */
          }
          .cr-highlight.has-note::before {
            content: '';
            display: inline-block;
            width: 14px;
            height: 16px;
            background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='16' viewBox='0 0 14 16'%3E%3Cpath d='M0.5,0.5 H9.5 L13.5,4.5 V15.5 H0.5 Z' fill='%23FFD54F' stroke='%23D4A719' stroke-width='1'/%3E%3Cpath d='M9.5,0.5 V4.5 H13.5' fill='%23FFE57F' stroke='%23D4A719' stroke-width='1'/%3E%3C/svg%3E");
            background-size: contain;
            background-repeat: no-repeat;
            margin-right: 4px;
            margin-left: 2px;
            vertical-align: text-bottom;
            position: relative;
            top: -1px;
          }
        `;
        document.head.appendChild(style);
      """);

      final RenderBox? renderBox =
          _headerKey.currentContext?.findRenderObject() as RenderBox?;
      double headerHeight = (renderBox != null && renderBox.hasSize)
          ? renderBox.size.height
          : MediaQuery.of(context).padding.top + kToolbarHeight + 100;

      final double navBarHeight = MediaQuery.of(context).viewPadding.bottom;
      final double bottomPadding = navBarHeight + 30;

      await controller.runJavaScript("""
        document.body.style.paddingTop = '${headerHeight}px';
        document.body.style.paddingBottom = '${bottomPadding}px';
      """);
    } catch (e) {
      print("JS Injection Error: $e");
    }
  }

  Future<void> _restoreHighlights(WebViewController controller) async {
    final highlights = await _highlightService.loadHighlights();
    if (highlights.isNotEmpty) {
      final jsonString = jsonEncode(highlights.map((h) => h.toJson()).toList());
      final sanitizedJson = jsonEncode(jsonString);
      await controller.runJavaScript(
        'window.cleanReadEngine.restoreHighlights(JSON.parse($sanitizedJson));',
      );
    }
  }

  void _handleJsMessage(JavaScriptMessage message) async {
    try {
      final Map<String, dynamic> payload = jsonDecode(message.message);
      final String action = payload['action'];

      if (action == 'ui_control') {
        final String command = payload['data'];
        if (command == 'hide_ui' && _uiVisible) {
          setState(() => _uiVisible = false);
        } else if (command == 'show_ui' && !_uiVisible) {
          setState(() => _uiVisible = true);
        }
        return;
      }

      final dynamic data = payload['data'];

      switch (action) {
        case 'create':
          final highlight = Highlight.fromJson(data);
          await _highlightService.addHighlight(highlight);
          break;
        case 'update':
          final id = data['id'];
          final color = data['color'];
          await _highlightService.updateHighlight(id, newColor: color);
          break;
        case 'edit_note':
          final id = data['id'];
          final highlights = await _highlightService.loadHighlights();
          final highlight = highlights.firstWhere((h) => h.id == id);
          final hasNote =
              highlight.note != null && highlight.note!.trim().isNotEmpty;
          final availableTags = await ref.read(allTagsProvider.future);

          if (mounted) {
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

            if (result != null) {
              final newText = result.$1.trim();
              final newTags = result.$2;
              final isNotEmpty = newText.isNotEmpty;

              await _highlightService.updateHighlight(
                id,
                newNote: isNotEmpty ? newText : null,
                clearNote: !isNotEmpty,
                newTags: newTags,
              );

              final jsNote = isNotEmpty ? jsonEncode(newText) : 'null';
              final jsTags = jsonEncode(newTags);
              await _controller?.runJavaScript(
                "window.cleanReadEngine.updateNoteIcon('$id', $jsNote, $jsTags);",
              );
              ref.invalidate(allTagsProvider);
            }
          }
          break;
        case 'delete':
          await _highlightService.deleteHighlight(data['id']);
          break;
      }
    } catch (e) {
      print("Error handling JS message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final articleStream = ref.watch(singleArticleProvider(widget.articleId));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller == null
                ? const SizedBox()
                : AnimatedOpacity(
                    opacity: _isLoadingFile ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: WebViewWidget(controller: _controller!),
                  ),
          ),
          if (_isLoadingFile) const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedSlide(
              offset: _uiVisible ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildFloatingHeader(context, articleStream),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(
    BuildContext context,
    AsyncValue<Article?> articleStream,
  ) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Container(
      key: _headerKey,
      padding: EdgeInsets.only(top: topPadding, bottom: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ZEILE 1: Zurück, Titel, Hauptmenü
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: articleStream.when(
                  data: (article) => Text(
                    article?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ),
              articleStream.maybeWhen(
                data: (article) => article != null
                    ? _buildOptionsMenu(context, article)
                    : const SizedBox(),
                orElse: () => const SizedBox(),
              ),
            ],
          ),

          articleStream.when(
            data: (article) {
              if (article == null) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BLOCK OBEN: (SiteName & Autor) | Icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Links: Stack aus SiteName und Autor
                        Expanded(
                          child: ArticleMetaDisplay(
                            article: article,
                            compact: true,
                            showTopRow: true,
                            showAuthors: true,
                            showTags: false, // Hier noch keine Tags
                          ),
                        ),
                        // Rechts: Die Icons untereinander
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeaderIcon(Icons.public, () async {
                              final uri = Uri.parse(article.url);
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }),
                            _buildHeaderIcon(Icons.description_outlined, () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => NotesBottomSheet(
                                  noteService: _noteService,
                                  highlightService: _highlightService,
                                  webViewController: _controller,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                    // BLOCK UNTEN: Tags über volle Breite
                    ArticleMetaDisplay(
                      article: article,
                      compact: true,
                      showTopRow: false,
                      showAuthors: false,
                      showTags: true, // Hier NUR die Tags
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context, Article article) {
    final isRead = article.isRead;
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'toggleRead') {
          ArticleActions.toggleReadStatus(context, ref, article);
        } else if (value == 'editMeta') {
          final appDir = await StorageService().getAppDirectory();
          final metaFile = File(p.join(appDir.path, article.id, 'meta.json'));
          ArticleMeta fullMeta = ArticleMeta.fromJson(
            jsonDecode(await metaFile.readAsString()),
          );
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (context) =>
                  EditMetaDialog(article: article, meta: fullMeta),
            );
          }
        } else if (value == 'delete') {
          if (await ArticleActions.confirmDelete(context) && context.mounted) {
            await ArticleActions.executeDelete(
              context,
              ref,
              article.id,
              popScreen: true,
            );
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggleRead',
          child: Row(
            children: [
              Icon(
                isRead ? Icons.mark_email_unread : Icons.check_circle,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 12),
              Text(
                isRead ? 'Als ungelesen markieren' : 'Als gelesen markieren',
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'editMeta',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.grey[700]),
              const SizedBox(width: 12),
              const Text('Metadaten bearbeiten'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 12),
              const Text('Löschen', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
