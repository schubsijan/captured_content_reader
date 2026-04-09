import 'package:flutter/material.dart';
import 'tag_input_field.dart';

class PlainTextNoteDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final List<String> initialTags;
  final List<String> availableTags;
  final bool showDeleteButton;

  const PlainTextNoteDialog({
    super.key,
    required this.title,
    this.initialText = '',
    this.initialTags = const [],
    this.availableTags = const [],
    this.showDeleteButton = false,
  });

  @override
  State<PlainTextNoteDialog> createState() => _PlainTextNoteDialogState();
}

class _PlainTextNoteDialogState extends State<PlainTextNoteDialog> {
  late TextEditingController _controller;
  late List<String> _currentTags;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _currentTags = List.from(widget.initialTags);

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
          title: Text(widget.title, style: const TextStyle(fontSize: 18)),
          actions: [
            if (widget.showDeleteButton)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => Navigator.pop(context, ('', <String>[])),
              ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, (_controller.text, _currentTags)),
              child: const Text("SPEICHERN"),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TagInputField(
                initialTags: _currentTags,
                availableTags: widget.availableTags,
                onTagsChanged: (tags) => _currentTags = tags,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }
}
