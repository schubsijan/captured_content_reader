import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../database/app_database.dart';
import '../../../models/article_meta.dart';
import '../../library/providers/library_providers.dart';

class EditMetaDialog extends ConsumerStatefulWidget {
  final Article article;
  final ArticleMeta meta; // Das vollständige Meta-Objekt aus JSON

  const EditMetaDialog({super.key, required this.article, required this.meta});

  @override
  ConsumerState<EditMetaDialog> createState() => _EditMetaDialogState();
}

class _EditMetaDialogState extends ConsumerState<EditMetaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _siteNameCtrl;
  late TextEditingController _urlCtrl;
  DateTime? _publishedAt;

  // Wir halten den State der Autoren lokal im Widget
  late List<_AuthorEntry> _authorEntries;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.meta.title);
    _siteNameCtrl = TextEditingController(text: widget.meta.siteName);
    _urlCtrl = TextEditingController(text: widget.meta.url);
    _publishedAt = widget.meta.publishedAt;

    // Autoren initialisieren: Wir gehen standardmäßig von "Organisation" (Single String) aus,
    // es sei denn, wir erkennen ein Komma-Format o.ä., aber hier starten wir simpel.
    _authorEntries = widget.meta.authors.map((name) {
      return _AuthorEntry(initialName: name);
    }).toList();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _siteNameCtrl.dispose();
    _urlCtrl.dispose();
    for (var entry in _authorEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Autoren wieder zu Strings zusammenbauen
    final List<String> updatedAuthors = _authorEntries
        .map((e) => e.getFullName())
        .toList();
    // Leere Einträge entfernen
    updatedAuthors.removeWhere((s) => s.trim().isEmpty);

    // Neues Meta Objekt erstellen (kopieren vom alten)
    final newMeta = widget.meta.copyWith(
      title: _titleCtrl.text.trim(),
      siteName: _siteNameCtrl.text.trim().isEmpty
          ? null
          : _siteNameCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      publishedAt: _publishedAt,
      authors: updatedAuthors,
    );

    // Speichern via Repository
    await ref
        .read(articleRepositoryProvider)
        .updateArticleMeta(widget.article.id, newMeta);

    if (mounted) {
      Navigator.pop(context); // Dialog schließen
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Metadaten gespeichert")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Scaffold(
        // Scaffold innerhalb des Dialogs für schöne Toolbar
        appBar: AppBar(
          title: const Text("Metadaten bearbeiten"),
          actions: [
            TextButton(onPressed: _save, child: const Text("SPEICHERN")),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- TITEL ---
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Titel",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty
                    ? "Titel darf nicht leer sein"
                    : null,
              ),
              const SizedBox(height: 16),

              // --- SITE NAME ---
              TextFormField(
                controller: _siteNameCtrl,
                decoration: const InputDecoration(
                  labelText: "Webseite / Quelle",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- URL ---
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  labelText: "Original URL",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- DATUM ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Veröffentlichungsdatum"),
                subtitle: Text(
                  _publishedAt == null
                      ? "Kein Datum"
                      : DateFormat('dd.MM.yyyy HH:mm').format(_publishedAt!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_publishedAt != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _publishedAt = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _publishedAt ?? now,
                          firstDate: DateTime(1990),
                          lastDate: now.add(const Duration(days: 1)),
                        );
                        if (d != null && context.mounted) {
                          // Optional: TimePicker hinterher
                          setState(() => _publishedAt = d);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),

              // --- AUTOREN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Autoren",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _authorEntries.add(_AuthorEntry(initialName: ""));
                      });
                    },
                  ),
                ],
              ),
              ..._authorEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final authorEntry = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AuthorRow(
                    entry: authorEntry,
                    onDelete: () {
                      setState(() {
                        _authorEntries.removeAt(index);
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// --- LOGIK FÜR EINE AUTOREN-ZEILE ---

enum AuthorMode { person, org }

class _AuthorEntry {
  AuthorMode mode = AuthorMode.org;

  // Controller für Org-Modus
  final TextEditingController orgCtrl = TextEditingController();

  // Controller für Person-Modus
  final TextEditingController firstCtrl = TextEditingController();
  final TextEditingController lastCtrl = TextEditingController();

  _AuthorEntry({required String initialName}) {
    orgCtrl.text = initialName;

    // --- LOGIK ÄNDERUNG HIER ---
    // Prüfung: Enthält der Name ein Komma? (z.B. "Werthmann, Julia")
    if (initialName.contains(',')) {
      mode = AuthorMode.person;

      // Splitten am Komma für Nachname, Vorname
      final parts = initialName.split(',');
      lastCtrl.text = parts[0].trim();

      if (parts.length > 1) {
        // Alles nach dem ersten Komma ist der Vorname
        firstCtrl.text = parts.sublist(1).join(',').trim();
      }
    } else {
      // Kein Komma -> Standardmäßig Organisation / Single Name
      // Wir bereiten aber die Person-Felder vor, falls es das Format "Vorname Nachname" hat
      mode = AuthorMode.org;
      _parseAndSetPersonSpaceFormat(initialName);
    }
  }

  void dispose() {
    orgCtrl.dispose();
    firstCtrl.dispose();
    lastCtrl.dispose();
  }

  /// Fallback Parser: Nimmt "Vorname Nachname" (Space getrennt) an
  void _parseAndSetPersonSpaceFormat(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) {
      firstCtrl.text = "";
      lastCtrl.text = "";
    } else if (parts.length == 1) {
      firstCtrl.text = "";
      lastCtrl.text = parts[0];
    } else {
      lastCtrl.text = parts.last;
      firstCtrl.text = parts.sublist(0, parts.length - 1).join(' ');
    }
  }

  /// Baut den String für den Wechsel von Person -> Org
  void _concatAndSetOrg() {
    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();

    // Hier entscheiden wir, wie wir speichern wollen, wenn wir zurück zu Org wechseln.
    // Standardmäßig meist "Vorname Nachname".
    if (first.isEmpty) {
      orgCtrl.text = last;
    } else {
      orgCtrl.text = "$first $last";
    }
  }

  /// Wird aufgerufen, wenn man vom Org-Modus (Textfeld) in den Person-Modus klickt.
  /// Wir müssen entscheiden, ob wir ein Komma parsen oder Leerzeichen.
  void parseForToggle() {
    final currentText = orgCtrl.text;
    if (currentText.contains(',')) {
      // Format: Nachname, Vorname
      final parts = currentText.split(',');
      lastCtrl.text = parts[0].trim();
      if (parts.length > 1) {
        firstCtrl.text = parts.sublist(1).join(',').trim();
      }
    } else {
      // Format: Vorname Nachname
      _parseAndSetPersonSpaceFormat(currentText);
    }
  }

  String getFullName() {
    // Wenn Org-Modus aktiv ist: Einfach den Text zurückgeben
    if (mode == AuthorMode.org) return orgCtrl.text.trim();

    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();

    // Fallback, wenn Felder leer sind
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;

    // WICHTIG: Wir speichern als "Nachname, Vorname".
    // Das garantiert, dass beim nächsten Laden das Komma gefunden wird
    // und der Modus wieder korrekt auf "Person" (👤) gesetzt wird.
    return "$last, $first";
  }
}

class AuthorRow extends StatefulWidget {
  final _AuthorEntry entry;
  final VoidCallback onDelete;

  const AuthorRow({super.key, required this.entry, required this.onDelete});

  @override
  State<AuthorRow> createState() => _AuthorRowState();
}

class _AuthorRowState extends State<AuthorRow> {
  void _toggleMode() {
    setState(() {
      if (widget.entry.mode == AuthorMode.person) {
        // Person -> Org: Zusammenfügen
        widget.entry._concatAndSetOrg();
        widget.entry.mode = AuthorMode.org;
      } else {
        // Org -> Person: Parsen (Jetzt mit neuer Methode)
        widget.entry.parseForToggle(); // <--- HIER GEÄNDERT
        widget.entry.mode = AuthorMode.person;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle Button
        IconButton(
          onPressed: _toggleMode,
          icon: Text(
            widget.entry.mode == AuthorMode.person ? "👤" : "🏢",
            style: const TextStyle(fontSize: 20),
          ),
          tooltip: widget.entry.mode == AuthorMode.person
              ? "Zu Organisation wechseln"
              : "Zu Person wechseln",
        ),

        // Input Felder
        Expanded(
          child: widget.entry.mode == AuthorMode.person
              ? Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: widget.entry.lastCtrl,
                        decoration: const InputDecoration(
                          hintText: "Nachname",
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(","),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: widget.entry.firstCtrl,
                        decoration: const InputDecoration(
                          hintText: "Vorname",
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                )
              : TextField(
                  controller: widget.entry.orgCtrl,
                  decoration: const InputDecoration(
                    hintText: "Name oder Organisation",
                    isDense: true,
                  ),
                ),
        ),

        // Delete Button
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }
}
