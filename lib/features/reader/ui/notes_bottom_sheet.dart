import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/article_note.dart';
import '../../../models/highlight.dart';
import '../../shared/ui/plain_text_note_dialog.dart';
import '../services/article_note_service.dart';
import '../services/highlight_service.dart';

class NotesBottomSheet extends StatefulWidget {
  final ArticleNoteService noteService;
  final HighlightService highlightService;
  final WebViewController? webViewController;

  const NotesBottomSheet({
    super.key,
    required this.noteService,
    required this.highlightService,
    required this.webViewController,
  });

  @override
  State<NotesBottomSheet> createState() => _NotesBottomSheetState();
}

class _NotesBottomSheetState extends State<NotesBottomSheet> {
  List<ArticleNote> _articleNotes = [];
  List<Highlight> _highlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNotes();
  }

  Future<void> _loadAllNotes() async {
    setState(() => _isLoading = true);

    // 1. Artikel-Notizen laden
    final aNotes = await widget.noteService.loadNotes();
    aNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 2. Highlights laden
    final hNotesFull = await widget.highlightService.loadHighlights();

    // 3. Echte DOM-Reihenfolge vom Browser abfragen
    if (widget.webViewController != null) {
      try {
        // Wir lassen JS alle Highlights von oben nach unten scannen
        final result = await widget.webViewController!
            .runJavaScriptReturningResult('''
          (function() {
            const marks = document.querySelectorAll('.cr-highlight');
            const ids = [];
            marks.forEach(m => {
              const id = m.getAttribute('data-id');
              if (id && !ids.includes(id)) ids.push(id);
            });
            return JSON.stringify(ids);
          })();
          ''');

        // Android/iOS WebView gibt den JSON-String oft als Dart-String mit Escaping zurück
        String raw = result.toString();
        if (raw.startsWith('"') && raw.endsWith('"')) {
          raw = jsonDecode(raw); // Escaping entfernen
        }

        final List<dynamic> decodedList = jsonDecode(raw);
        final List<String> sortedIds = decodedList
            .map((e) => e.toString())
            .toList();

        // Sortieren streng nach der visuellen Position im Browser
        hNotesFull.sort((a, b) {
          int indexA = sortedIds.indexOf(a.id);
          int indexB = sortedIds.indexOf(b.id);

          // Fallback, falls ein Highlight im DOM fehlt (sollte nicht passieren)
          if (indexA == -1) indexA = 999999;
          if (indexB == -1) indexB = 999999;

          if (indexA != indexB) {
            return indexA.compareTo(indexB);
          }
          return a.startOffset.compareTo(b.startOffset);
        });
      } catch (e) {
        print("DOM Sort Error: $e");
        _fallbackSort(hNotesFull); // Wenn JS fehlschlägt
      }
    } else {
      _fallbackSort(hNotesFull);
    }

    if (mounted) {
      setState(() {
        _articleNotes = aNotes;
        _highlights = hNotesFull;
        _isLoading = false;
      });
    }
  }

  // --- Die alte Logik als Fallback auslagern ---
  void _fallbackSort(List<Highlight> list) {
    list.sort((a, b) {
      int xpathComp = _compareNatural(a.xpath, b.xpath);
      if (xpathComp != 0) return xpathComp;
      return a.startOffset.compareTo(b.startOffset);
    });
  }

  // --- Hilfsmethode zum Konvertieren des JS Hex-Strings (#F8CF01) in Flutter Color ---
  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor'; // 100% Opacity Prefix hinzufügen
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.yellow; // Fallback
    }
  }

  // --- Hilfsmethode für natürliche Sortierung von XPaths ---
  // --- Robuste Methode für natürliche Sortierung von XPaths ---
  int _compareNatural(String xpathA, String xpathB) {
    // 1. Pfade an den Slashes aufteilen
    final partsA = xpathA.split('/');
    final partsB = xpathB.split('/');

    final minLength = partsA.length < partsB.length
        ? partsA.length
        : partsB.length;

    // 2. Ebene für Ebene vergleichen (z.B. "HTML" -> "BODY" -> "DIV[1]")
    for (int i = 0; i < minLength; i++) {
      final a = partsA[i];
      final b = partsB[i];

      if (a != b) {
        // Die Ebenen unterscheiden sich. Wir trennen den Tag-Namen vom Index.
        // z.B. "DIV[12]" wird zu ["DIV", "12"]
        final regExp = RegExp(r'^([A-Za-z]+)(?:\[(\d+)\])?$');

        final matchA = regExp.firstMatch(a);
        final matchB = regExp.firstMatch(b);

        if (matchA != null && matchB != null) {
          final tagA = matchA.group(1)!;
          final tagB = matchB.group(1)!;

          // Wenn die HTML-Tags unterschiedlich sind (z.B. P vs DIV), normal alphabetisch sortieren
          if (tagA != tagB) {
            return tagA.compareTo(tagB);
          }

          // Tags sind gleich (z.B. beides P), wir vergleichen die Zahlen in den Klammern
          final numA = matchA.group(2) != null
              ? int.parse(matchA.group(2)!)
              : 1; // [keine Klammer] entspricht [1]
          final numB = matchB.group(2) != null
              ? int.parse(matchB.group(2)!)
              : 1;

          return numA.compareTo(numB);
        }

        // Fallback, falls der Regex nicht greift (sollte bei Standard-XPaths nicht passieren)
        return a.compareTo(b);
      }
    }

    // Wenn alle Ebenen bis zur minimalen Länge gleich sind, gewinnt der kürzere Pfad
    return partsA.length.compareTo(partsB.length);
  }

  Future<void> _addArticleNote() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const PlainTextNoteDialog(title: "Neue Notiz"),
    );

    if (result != null && result.trim().isNotEmpty) {
      await widget.noteService.addNote(result);
      await _loadAllNotes();
    }
  }

  Future<void> _editArticleNote(ArticleNote note) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => PlainTextNoteDialog(
        title: "Notiz bearbeiten",
        initialText: note.content,
        showDeleteButton: true, // <--- NEU
      ),
    );

    if (result != null) {
      if (result.trim().isEmpty) {
        await widget.noteService.deleteNote(note.id);
      } else {
        await widget.noteService.updateNote(note.id, result);
      }
      await _loadAllNotes();
    }
  }

  Future<void> _editHighlightNote(Highlight highlight) async {
    final hasNote = highlight.note != null && highlight.note!.trim().isNotEmpty;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => PlainTextNoteDialog(
        title: hasNote ? "Highlight Notiz bearbeiten" : "Notiz hinzufügen",
        initialText: highlight.note ?? '',
        showDeleteButton:
            hasNote, // <--- NEU: Nur zeigen, wenn schon Text existiert
      ),
    );

    if (result != null) {
      final trimmed = result.trim();
      final isNotEmpty = trimmed.isNotEmpty;

      // Update in der JSON
      await widget.highlightService.updateHighlight(
        highlight.id,
        newNote: isNotEmpty ? trimmed : null,
        clearNote: !isNotEmpty,
      );

      // Live-Update im Hintergrund-WebView
      final jsNote = isNotEmpty ? jsonEncode(trimmed) : 'null';
      widget.webViewController?.runJavaScript(
        "window.cleanReadEngine.updateNoteIcon('${highlight.id}', $jsNote);",
      );

      // UI aktualisieren (Liste neu aufbauen)
      await _loadAllNotes();
    }
  }

  void _jumpToHighlight(String id) {
    if (widget.webViewController != null) {
      widget.webViewController!.runJavaScript(
        "window.cleanReadEngine.scrollToHighlight('$id');",
      );
      Navigator.pop(context); // Optional: Sheet schließen beim Springen
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notizen & Highlights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).colorScheme.primary,
                      iconSize: 28,
                      onPressed: _addArticleNote,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        children: _buildListContent(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildListContent() {
    if (_articleNotes.isEmpty && _highlights.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              "Keine Notizen oder Markierungen vorhanden.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    List<Widget> items = [];

    // --- 1. Artikel Notizen ---
    for (var note in _articleNotes) {
      final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(note.createdAt);

      items.add(
        ListTile(
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          onTap: () => _editArticleNote(note),
          onLongPress: () async {
            await widget.noteService.deleteNote(note.id);
            await _loadAllNotes();
          },
        ),
      );
      items.add(const Divider(height: 1));
    }

    // --- 2. Alle Highlights (mit und ohne Notiz) ---
    if (_highlights.isNotEmpty) {
      if (_articleNotes.isNotEmpty) {
        items.add(const SizedBox(height: 8));
      }

      items.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Markierungen",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
      items.add(const Divider(height: 1));

      for (var h in _highlights) {
        final cleanText = h.text.replaceAll('\n', ' ').trim();
        final hasNote = h.note != null && h.note!.trim().isNotEmpty;

        // Transparenz (Alpha) für den Highlight-Background auf ca. 40% setzen, damit Text gut lesbar bleibt
        final highlightColor = _parseColor(h.color).withOpacity(0.4);

        items.add(
          ListTile(
            // Der markierte Text mit realem Background
            title: Text(
              '"$cleanText"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
                backgroundColor: highlightColor,
                fontSize: 13,
                height: 1.4, // Etwas mehr Zeilenabstand für den Marker-Effekt
              ),
            ),

            // Subtitle erscheint nur, wenn es eine Notiz gibt
            subtitle: hasNote
                ? Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      h.note!,
                      style: TextStyle(color: Colors.grey.shade900),
                    ),
                  )
                : null,

            onTap: () => _jumpToHighlight(h.id),
            onLongPress: () => _editHighlightNote(h),

            // Dynamisches Icon basierend auf Notiz-Status
            trailing: IconButton(
              icon: Icon(
                hasNote ? Icons.edit_outlined : Icons.add_comment_outlined,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: () => _editHighlightNote(h),
            ),
          ),
        );
        items.add(const Divider(height: 1));
      }
    }

    return items;
  }
}
