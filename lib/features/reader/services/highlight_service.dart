import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../models/highlight.dart';
import '../../../services/storage_access.dart';
import '../../../services/library_sync_service.dart';

class HighlightService {
  final String articleId;
  final LibrarySyncService syncService;
  late final File _file;

  HighlightService(this.articleId, this.syncService);

  Future<void> init() async {
    final storage = StorageService();
    final appDir = await storage.getAppDirectory();
    _file = File(p.join(appDir.path, articleId, 'highlights.json'));
  }

  Future<List<Highlight>> loadHighlights() async {
    if (!await _file.exists()) return [];
    try {
      final content = await _file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => Highlight.fromJson(e)).toList();
    } catch (e) {
      print("Error loading highlights: $e");
      return [];
    }
  }

  Future<void> addHighlight(Highlight highlight) async {
    final list = await loadHighlights();
    list.add(highlight);
    await _saveList(list);
  }

  Future<void> updateHighlight(
    String id, {
    String? newColor,
    String? newNote,
    HighlightType? newType,
    bool clearNote = false,
    List<String>? newTags,
  }) async {
    final list = await loadHighlights();
    final index = list.indexWhere((h) => h.id == id);
    if (index != -1) {
      final old = list[index];
      list[index] = Highlight(
        id: old.id,
        text: old.text,
        xpath: old.xpath,
        textNodeIndex: old.textNodeIndex,
        startOffset: old.startOffset,
        endOffset: old.endOffset,
        color: newColor ?? old.color,
        type: newType ?? old.type,
        note: clearNote ? null : (newNote ?? old.note),
        tags: newTags ?? old.tags,
      );
      await _saveList(list);
    }
  }

  Future<void> deleteHighlight(String id) async {
    final list = await loadHighlights();
    list.removeWhere((h) => h.id == id);
    await _saveList(list);
  }

  Future<void> _saveList(List<Highlight> list) async {
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    final tempFile = File('${_file.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    await tempFile.rename(_file.path);

    await syncService.syncSingleArticle(articleId);
  }
}
