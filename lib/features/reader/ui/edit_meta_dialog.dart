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

  // State für die Autoren
  late List<_AuthorEntry> _authorEntries;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.meta.title);
    _siteNameCtrl = TextEditingController(text: widget.meta.siteName);
    _urlCtrl = TextEditingController(text: widget.meta.url);
    _publishedAt = widget.meta.publishedAt;

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

    final List<String> updatedAuthors = _authorEntries
        .map((e) => e.getFullName())
        .toList();
    updatedAuthors.removeWhere((s) => s.trim().isEmpty);

    // Erstellt neues Meta Objekt
    // Wir übergeben widget.meta.tags, um die Tags beim Speichern der Meta-Daten nicht zu überschreiben
    final newMeta = widget.meta.copyWith(
      title: _titleCtrl.text.trim(),
      siteName: _siteNameCtrl.text.trim().isEmpty
          ? null
          : _siteNameCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      publishedAt: _publishedAt,
      authors: updatedAuthors,
      tags: widget.meta.tags,
    );

    // Speichern via Repository (triggert Dateisystem + DB Index)
    await ref
        .read(articleRepositoryProvider)
        .updateArticleMeta(widget.article.id, newMeta);

    if (mounted) {
      Navigator.pop(context);
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

// --- Hilfsklassen für Autoren ---

enum AuthorMode { person, org }

class _AuthorEntry {
  AuthorMode mode = AuthorMode.org;
  final TextEditingController orgCtrl = TextEditingController();
  final TextEditingController firstCtrl = TextEditingController();
  final TextEditingController lastCtrl = TextEditingController();

  _AuthorEntry({required String initialName}) {
    orgCtrl.text = initialName;
    if (initialName.contains(',')) {
      mode = AuthorMode.person;
      final parts = initialName.split(',');
      lastCtrl.text = parts[0].trim();
      if (parts.length > 1) {
        firstCtrl.text = parts.sublist(1).join(',').trim();
      }
    } else {
      _parseAndSetPersonSpaceFormat(initialName);
    }
  }

  void dispose() {
    orgCtrl.dispose();
    firstCtrl.dispose();
    lastCtrl.dispose();
  }

  void _parseAndSetPersonSpaceFormat(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return;
    if (parts.length == 1) {
      lastCtrl.text = parts[0];
    } else {
      lastCtrl.text = parts.last;
      firstCtrl.text = parts.sublist(0, parts.length - 1).join(' ');
    }
  }

  void parseForToggle() {
    final currentText = orgCtrl.text;
    if (currentText.contains(',')) {
      final parts = currentText.split(',');
      lastCtrl.text = parts[0].trim();
      if (parts.length > 1) firstCtrl.text = parts.sublist(1).join(',').trim();
    } else {
      _parseAndSetPersonSpaceFormat(currentText);
    }
  }

  void _concatAndSetOrg() {
    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();
    orgCtrl.text = first.isEmpty ? last : "$first $last";
  }

  String getFullName() {
    if (mode == AuthorMode.org) return orgCtrl.text.trim();
    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() {
            if (widget.entry.mode == AuthorMode.person) {
              widget.entry._concatAndSetOrg();
              widget.entry.mode = AuthorMode.org;
            } else {
              widget.entry.parseForToggle();
              widget.entry.mode = AuthorMode.person;
            }
          }),
          icon: Text(widget.entry.mode == AuthorMode.person ? "👤" : "🏢"),
        ),
        Expanded(
          child: widget.entry.mode == AuthorMode.person
              ? Row(
                  children: [
                    Expanded(
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
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }
}

