import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  static const String _prefsKey = 'custom_storage_path';

  /// Initialer Permission-Check für das Onboarding
  Future<bool> init() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted)
        return true;
      if (await Permission.storage.request().isGranted) return true;
    }
    return Platform.isLinux; // Auf Linux gehen wir von Zugriff aus
  }

  /// Der eigentliche Ordner-Picker
  Future<String?> pickDirectory() async {
    String? selectedPath = await FilePicker.platform.getDirectoryPath();
    print("Picker Result: $selectedPath"); // Prüfe das in der Konsole!

    if (selectedPath != null) {
      // Falls der Pfad auf Android mit "content://" beginnt, haben wir ein Problem.
      // Normalerweise sollte file_picker das auflösen, außer bei speziellen Ordnern.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, selectedPath);
      return selectedPath;
    }
    return null;
  }

  /// Liefert das Verzeichnis für die Artikel
  Future<Directory> getAppDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_prefsKey);

    if (savedPath != null) {
      final dir = Directory(savedPath);
      if (await dir.exists()) return dir;
    }

    // Fallback falls kein Pfad gewählt wurde (sollte nach Onboarding nicht passieren)
    final docDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(docDir.path, 'CleanReadData'));
  }
}

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);
