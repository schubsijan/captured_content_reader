import 'package:flutter/material.dart';

class PlainTextNoteDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final bool showDeleteButton;

  const PlainTextNoteDialog({
    super.key,
    required this.title,
    this.initialText = '',
    this.showDeleteButton = false, // Standardmäßig false für neue Notizen
  });

  @override
  State<PlainTextNoteDialog> createState() => _PlainTextNoteDialogState();
}

class _PlainTextNoteDialogState extends State<PlainTextNoteDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);

    // Setzt den Cursor ans Ende des Textes, falls bereits Text vorhanden ist
    if (widget.initialText.isNotEmpty) {
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.initialText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            if (widget.showDeleteButton)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  // Ein leerer String signalisiert dem BottomSheet, dass gelöscht werden soll
                  Navigator.pop(context, '');
                },
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text("SPEICHERN"),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            autofocus: true,
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: "Notiz eingeben...",
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
