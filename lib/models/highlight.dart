import 'dart:convert';

class Highlight {
  final String id;
  final String text;
  final String xpath;
  final int textNodeIndex;
  final int startOffset;
  final int endOffset;
  final String color;
  final String? note; // Für später

  Highlight({
    required this.id,
    required this.text,
    required this.xpath,
    required this.textNodeIndex,
    required this.startOffset,
    required this.endOffset,
    required this.color,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'xpath': xpath,
      'textNodeIndex': textNodeIndex,
      'startOffset': startOffset,
      'endOffset': endOffset,
      'color': color,
      'note': note,
    };
  }

  factory Highlight.fromJson(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as String,
      text: map['text'] as String,
      xpath: map['xpath'] as String,
      textNodeIndex: map['textNodeIndex'] as int? ?? 0,
      startOffset: map['startOffset'] as int,
      endOffset: map['endOffset'] as int,
      color: map['color'] as String,
      note: map['note'] as String?,
    );
  }
}
