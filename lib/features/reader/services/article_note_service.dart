import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../models/article_note.dart';
import '../../../services/storage_access.dart';
import '../../../database/app_database.dart';
import '../../../services/library_sync_service.dart';

class ArticleNoteService {
  final String articleId;
  final AppDatabase db;
  final LibrarySyncService syncService;
  late final File _file;

  ArticleNoteService(this.articleId, this.db, this.syncService);

  Future<void> init() async {
    final storage = StorageService();
    final appDir = await storage.getAppDirectory();
    _file = File(p.join(appDir.path, articleId, 'notes.json'));
  }

  Future<List<ArticleNote>> loadNotes() async {
    if (!await _file.exists()) return [];
    try {
      final content = await _file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => ArticleNote.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addNote(String content, {List<String> tags = const []}) async {
    final notes = await loadNotes();
    final newNote = ArticleNote(
      id: const Uuid().v4(),
      content: content,
      createdAt: DateTime.now(),
      tags: tags,
    );
    notes.add(newNote);
    await _save(notes);
  }

  Future<void> updateNote(
    String id,
    String content, {
    List<String>? tags,
  }) async {
    final notes = await loadNotes();
    final idx = notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notes[idx] = notes[idx].copyWith(
        content: content,
        tags: tags ?? notes[idx].tags,
      );
      await _save(notes);
    }
  }

  Future<void> deleteNote(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n.id == id);
    await _save(notes);
  }

  Future<void> _save(List<ArticleNote> notes) async {
    final jsonString = jsonEncode(notes.map((e) => e.toJson()).toList());
    final tempFile = File('${_file.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    await tempFile.rename(_file.path);

    await syncService.syncSingleArticle(articleId);
  }
}
