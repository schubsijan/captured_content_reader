import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
      ..setBackgroundColor(const Color(0x00000000))
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
        _isLoadingFile = false;
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

      // Reihenfolge wichtig: Erst Framework, dann App
      await controller.runJavaScript(vanJs);
      await controller.runJavaScript(appJs);
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
      final dynamic data = payload['data'];

      print("JS Action: $action");

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
    // Wir holen uns den spezifischen Artikel aus der DB via ID
    // Tipp: Hier könnte man einen optimierten "Single Article Provider" bauen,
    // aber wir filtern der Einfachheit halber die Liste oder nutzen ein Future.
    // Für Phase 1: Wir nehmen an, das Objekt wird übergeben oder wir nutzen StreamBuilder.
    // Hier ein simpler Stream-Ansatz direkt auf die DB Query für diesen einen Artikel:

    final articleStream = ref.watch(singleArticleProvider(widget.articleId));

    return Scaffold(
      appBar: AppBar(
        title: articleStream.when(
          loading: () => const Text('Reader'),
          error: (err, _) => const Text('Reader'),
          data: (article) {
            if (article == null) return const Text('Reader');
            return Text(article.title);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Menü für Tags bearbeiten / Löschen
            },
          ),
        ],
      ),
      body: articleStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Fehler: $err")),
        data: (article) {
          if (article == null)
            return const Center(child: Text("Artikel nicht gefunden"));

          return Column(
            children: [
              // --- Metadata Header ---
              _buildMetaHeader(context, article),
              const Divider(height: 1),

              // --- WebView Content ---
              Expanded(
                child: _isLoadingFile
                    ? const Center(child: CircularProgressIndicator())
                    : WebViewWidget(controller: _controller!),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaHeader(BuildContext context, Article article) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              if (article.siteName != null)
                Chip(
                  label: Text(
                    article.siteName!,
                    style: const TextStyle(fontSize: 10),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              if (article.siteName != null) const SizedBox(width: 8),
              Text(
                "Gespeichert: ${dateFormat.format(article.savedAt)}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          // Hier könnten Tags als Wrap-Widget folgen
        ],
      ),
    );
  }
}
