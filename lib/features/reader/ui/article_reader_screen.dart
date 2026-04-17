import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../database/app_database.dart';
import '../../../models/article_meta.dart';
import '../../../services/storage_access.dart';
import '../../library/providers/library_providers.dart';
import '../../shared/ui/article_actions.dart';
import '../../shared/ui/article_meta_display.dart';
import 'edit_meta_dialog.dart';
import 'notes_bottom_sheet.dart';
import '../providers/reader_controller.dart';

class ArticleReaderScreen extends ConsumerStatefulWidget {
  final String articleId;
  final String? scrollToHighlightId;
  final String? scrollToNoteId;

  const ArticleReaderScreen({
    super.key,
    required this.articleId,
    this.scrollToHighlightId,
    this.scrollToNoteId,
  });

  @override
  ConsumerState<ArticleReaderScreen> createState() =>
      _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends ConsumerState<ArticleReaderScreen> {
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    print(
      '[ArticleReaderScreen] initState - scrollToNoteId: ${widget.scrollToNoteId}',
    );
    if (widget.scrollToNoteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('[ArticleReaderScreen] postFrameCallback - opening notes sheet');
        _openNotesSheet();
      });
    }
    _prepareWebView();
  }

  void _openNotesSheet() {
    print('[ArticleReaderScreen] _openNotesSheet called');
    final notifier = ref.read(
      readerControllerProvider(widget.articleId).notifier,
    );
    final noteId = widget.scrollToNoteId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        print('[ArticleReaderScreen] builder called');
        // Set provider directly in builder - will be picked up by the listen in NotesBottomSheet
        if (noteId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('[ArticleReaderScreen] setting provider to: $noteId');
            ref.read(scrollToNoteIdProvider.notifier).state = noteId;
          });
        }
        return NotesBottomSheet(
          noteService: notifier.noteService,
          highlightService: notifier.highlightService,
          webViewController: null,
        );
      },
    );
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
    final notifier = ref.read(
      readerControllerProvider(widget.articleId).notifier,
    );

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'CleanReadApp',
        onMessageReceived: (msg) =>
            notifier.handleJsMessage(msg.message, context),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            await _injectHighlightScripts(controller);

            final highlights = await notifier.highlightService.loadHighlights();
            if (highlights.isNotEmpty) {
              final jsonString = jsonEncode(
                highlights.map((h) => h.toJson()).toList(),
              );
              final sanitizedJson = jsonEncode(jsonString);
              await controller.runJavaScript(
                'window.cleanReadEngine.restoreHighlights(JSON.parse($sanitizedJson));',
              );
            }

            if (widget.scrollToHighlightId != null) {
              await Future.delayed(const Duration(milliseconds: 300));
              await controller.runJavaScript(
                "window.cleanReadEngine.scrollToHighlight('${widget.scrollToHighlightId}');",
              );
            }

            if (mounted) {
              notifier.setLoading(false);
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

    notifier.initWebView(controller);
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
    .cr-highlight {  /* <--- Punkt hinzugefügt */
      touch-action: manipulation; 
      transition: background-color 0.2s;
      position: relative; /* <--- Zwingend für ::before Positionierung */
      display: inline;
    }

    .cr-highlight.type-underline {
      background-color: transparent !important;
      text-decoration: underline;
      text-decoration-thickness: 3px;
      text-underline-offset: 2px;
    }

    .cr-highlight.has-note::before {
      content: '';
      display: inline-block;
      width: 14px;
      height: 16px;
      /* Das ursprüngliche Icon-SVG */
      background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='16' viewBox='0 0 14 16'%3E%3Cpath d='M0.5,0.5 H9.5 L13.5,4.5 V15.5 H0.5 Z' fill='%23FFD54F' stroke='%23D4A719' stroke-width='1'/%3E%3Cpath d='M9.5,0.5 V4.5 H13.5' fill='%23FFE57F' stroke='%23D4A719' stroke-width='1'/%3E%3C/svg%3E");
      background-size: contain;
      background-repeat: no-repeat;
      position: absolute; /* <--- Absolut zum cr-highlight */
      top: -12px;         /* Position über dem Text */
      left: 0;
      pointer-events: none;
      z-index: 5;
    }
  `;
  document.head.appendChild(style);     """);

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

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerControllerProvider(widget.articleId));
    final articleStream = ref.watch(singleArticleProvider(widget.articleId));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: readerState.webViewController == null
                ? const SizedBox()
                : AnimatedOpacity(
                    opacity: readerState.isLoadingFile ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: WebViewWidget(
                      controller: readerState.webViewController!,
                    ),
                  ),
          ),
          if (readerState.isLoadingFile)
            const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedSlide(
              offset: readerState.uiVisible ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildFloatingHeader(context, articleStream, readerState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(
    BuildContext context,
    AsyncValue<Article?> articleStream,
    ReaderState readerState,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ArticleMetaDisplay(
                            article: article,
                            compact: true,
                            showTopRow: true,
                            showAuthors: true,
                            showTags: false,
                          ),
                        ),
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
                              final notifier = ref.read(
                                readerControllerProvider(
                                  widget.articleId,
                                ).notifier,
                              );
                              if (widget.scrollToNoteId != null) {
                                ref
                                        .read(scrollToNoteIdProvider.notifier)
                                        .state =
                                    widget.scrollToNoteId;
                              }
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => NotesBottomSheet(
                                  noteService: notifier.noteService,
                                  highlightService: notifier.highlightService,
                                  webViewController:
                                      readerState.webViewController,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                    ArticleMetaDisplay(
                      article: article,
                      compact: true,
                      showTopRow: false,
                      showAuthors: false,
                      showTags: true,
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
    final isRead = article.readAt != null;
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
