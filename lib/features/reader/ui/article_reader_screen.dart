import 'dart:io';
import 'dart:convert';
import 'package:captured_content_reader/features/shared/ui/article_actions.dart';
import 'package:captured_content_reader/features/shared/ui/article_meta_display.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart';
import '../../../database/app_database.dart';
import '../../../services/storage_access.dart'; // Dein StorageService
import '../../library/providers/library_providers.dart'; // Zugriff auf DB/Repo
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

  bool _uiVisible = true;
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _highlightService = HighlightService(widget.articleId);
    _initSequence();
  }

  Future<void> _initSequence() async {
    await _highlightService.init();
    await _prepareWebView();
  }

  /// Bereitet den Controller vor und sucht den Pfad zur HTML-Datei
  Future<void> _prepareWebView() async {
    // 1. Pfad ermitteln (wie gehabt)
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

    // 2. Controller instanziieren (OHNE Kaskaden für den Delegate)
    final controller = WebViewController();

    // 3. Controller konfigurieren
    // Jetzt ist 'controller' bereits deklariert und kann im Callback verwendet werden.
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
            // HIER ist der Zugriff jetzt erlaubt:
            await _injectHighlightScripts(controller);
            await _restoreHighlights(controller);

            if (mounted) {
              setState(() {
                _isLoadingFile = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('file://')) {
              return NavigationDecision.navigate;
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

  /// Lädt die JS-Dateien aus den Assets und führt sie aus
  Future<void> _injectHighlightScripts(WebViewController controller) async {
    try {
      // Wir laden die Dateien frisch aus den Assets
      // Tipp: Strings könnten gecached werden, aber für Dev ist live laden besser
      final vanJs = await rootBundle.loadString(
        'assets/js/van-1.6.0.nomodule.min.js',
      );
      final appJs = await rootBundle.loadString('assets/js/highlight.js');
      final scrollJs = await rootBundle.loadString(
        'assets/js/scroll_listener.js',
      );

      // Reihenfolge wichtig: Erst Framework, dann App
      await controller.runJavaScript(vanJs);
      await controller.runJavaScript(appJs);
      await controller.runJavaScript(scrollJs);

      // --- 3. DYNAMISCHE HÖHENBERECHNUNG ---
      // Wir holen uns die RenderBox des Headers
      final RenderBox? renderBox =
          _headerKey.currentContext?.findRenderObject() as RenderBox?;

      double headerHeight = 0;

      if (renderBox != null && renderBox.hasSize) {
        headerHeight = renderBox.size.height;
      } else {
        // Fallback, falls UI noch nicht fertig gerendert wurde (sollte selten passieren)
        // Statusbar + AppBar Standardhöhe
        headerHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 60;
      }

      // Wir addieren noch z.B. 20px "Luft", damit es nicht klebt
      final double finalPadding = headerHeight;

      // viewPadding.bottom gibt uns die Höhe der System-Gesten-Leiste / Buttons
      final double navBarHeight = MediaQuery.of(context).viewPadding.bottom;
      // Wir geben noch 30px extra dazu, damit der Text nicht am Rand klebt
      final double bottomPadding = navBarHeight + 30;

      // --- CSS INJECTION ---
      // Wir setzen beides in einem Rutsch
      await controller.runJavaScript("""
        document.body.style.paddingTop = '${finalPadding}px';
        document.body.style.paddingBottom = '${bottomPadding}px';
      """);

      print("JS Engine injected.");
    } catch (e) {
      print("JS Injection Error: $e");
    }
  }

  /// Liest JSON vom File und sendet es an JS
  Future<void> _restoreHighlights(WebViewController controller) async {
    final highlights = await _highlightService.loadHighlights();
    if (highlights.isNotEmpty) {
      final jsonString = jsonEncode(highlights.map((h) => h.toJson()).toList());
      // Escaping für JS String Injection
      final sanitizedJson = jsonEncode(jsonString);
      // Aufruf deiner JS Funktion: window.cleanReadEngine.restoreHighlights(...)
      await controller.runJavaScript(
        'window.cleanReadEngine.restoreHighlights(JSON.parse($sanitizedJson));',
      );
    }
  }

  /// Empfängt Nachrichten von cleanReadEngine._sendToFlutter
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
          await _highlightService.updateHighlight(id, color);
          break;
        case 'delete':
          final id = data['id'];
          await _highlightService.deleteHighlight(id);
          break;
        default:
          print("Unknown action: $action");
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
      // Wir dehnen den Body bis ganz nach oben aus (hinter die Statusbar)
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // --- EBENE 1: WebView (Vollbild) ---
          // Nutzt den ganzen Platz, auch hinter der Statusbar
          Positioned.fill(
            child: _controller == null
                ? const SizedBox() // Leerer Platzhalter solange Controller init
                : AnimatedOpacity(
                    // Wenn wir noch laden (oder Scripts injizieren), ist Opacity 0.
                    // Sobald _isLoadingFile false wird, faden wir auf 1.0.
                    opacity: _isLoadingFile ? 0.0 : 1.0,
                    duration: const Duration(
                      milliseconds: 400,
                    ), // Sanfte Einblendung
                    curve: Curves.easeOut,
                    child: WebViewWidget(controller: _controller!),
                  ),
          ),

          // Lade-Indikator, solange der "Vorhang" noch zu ist
          if (_isLoadingFile) const Center(child: CircularProgressIndicator()),

          // --- EBENE 2: Animierter Header (Dynamische Höhe!) ---
          // Align platziert das Kind standardmäßig oben mittig.
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedSlide(
              // offset: Offset(x, y)
              // y = 0.0 -> Normalposition (Sichtbar)
              // y = -1.0 -> Verschiebung um 100% der eigenen Höhe nach oben (Unsichtbar)
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

  // Der Header baut sich jetzt so groß wie er Inhalt hat.
  // Wir müssen nur sicherstellen, dass er die Statusbar berücksichtigt.
  Widget _buildFloatingHeader(
    BuildContext context,
    AsyncValue<Article?> articleStream,
  ) {
    // Wir holen uns das "System Padding" (Statusbar Höhe)
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Container(
      key: _headerKey,
      // Padding oben = Statusbar + etwas Luft
      padding: EdgeInsets.only(top: topPadding, bottom: 10),
      width: double.infinity, // Volle Breite
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96), // Fast deckend
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
        mainAxisSize: MainAxisSize.min, // WICHTIG: Schrumpft auf Inhalts-Höhe
        children: [
          // 1. Fake AppBar Zeile
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
              // Menü Button
              articleStream.maybeWhen(
                data: (article) {
                  if (article == null) return const SizedBox();
                  return _buildOptionsMenu(context, article);
                },
                orElse: () => const SizedBox(),
              ),
            ],
          ),

          // 2. Meta Informationen (Optional, wenn vorhanden)
          articleStream.when(
            data: (article) {
              if (article == null) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ArticleMetaDisplay(article: article, compact: true),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context, Article article) {
    final isRead = article.isRead;

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'toggleRead') {
          // NEU: Einzeiler Aufruf
          ArticleActions.toggleReadStatus(context, ref, article);
        } else if (value == 'delete') {
          // NEU: Dialog + Löschen Logik
          final confirm = await ArticleActions.confirmDelete(context);
          if (confirm && context.mounted) {
            await ArticleActions.executeDelete(
              context,
              ref,
              article.id,
              popScreen: true,
            );
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
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
        const PopupMenuDivider(),
        PopupMenuItem<String>(
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
