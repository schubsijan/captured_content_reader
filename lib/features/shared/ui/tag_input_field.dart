import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  final List<String> initialTags;
  final List<String> availableTags;
  final ValueChanged<List<String>> onTagsChanged;
  final bool autofocus;

  const TagInputField({
    super.key,
    required this.initialTags,
    this.availableTags = const [],
    required this.onTagsChanged,
    this.autofocus = false,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  late List<String> _selectedTags;

  TextEditingController? _autoCompleteController;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);

    _internalFocusNode = FocusNode();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _internalFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_selectedTags.contains(trimmed)) {
      setState(() => _selectedTags.add(trimmed));
      widget.onTagsChanged(_selectedTags);
    }
  }

  void _removeTag(String tag) {
    setState(() => _selectedTags.remove(tag));
    widget.onTagsChanged(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ..._selectedTags.map(
            (tag) => Chip(
              label: Text(tag, style: const TextStyle(fontSize: 12)),
              onDeleted: () => _removeTag(tag),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          // Natives Autocomplete mit erzwungenem Overlay für Dialoge
          SizedBox(
            width: 200,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return widget.availableTags.where(
                  (tag) =>
                      tag.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ) &&
                      !_selectedTags.contains(tag),
                );
              },
              onSelected: (selection) {
                _addTag(selection);
                _autoCompleteController?.clear();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _autoCompleteController = controller;

                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: widget.autofocus,
                      decoration: const InputDecoration(
                        hintText: "Tags eingeben...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (value) {
                        _addTag(value);
                        controller.clear();
                        focusNode.requestFocus();
                      },
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surface,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 250,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Text(
                                '#$option',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
