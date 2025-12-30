import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class StorageService {
  static const String _appFolderName = 'CapturedContentReaderData';

  /// Initialisiert den Zugriff und erstellt den Basis-Ordner.
  /// Gibt false zurück, wenn Berechtigungen fehlen.
  Future<bool> init() async {
    if (Platform.isAndroid) {
      // Prüfen auf Manage External Storage (Android 11+)
      if (await Permission.manageExternalStorage.request().isGranted) {
        return await _ensureDirectoryExists();
      }
      // Fallback für ältere Android Versionen
      else if (await Permission.storage.request().isGranted) {
        return await _ensureDirectoryExists();
      }
    }
    return false;
  }

  /// Ermittelt den Pfad zum öffentlichen Documents Ordner.
  /// Wir nutzen nicht getApplicationDocumentsDirectory(), da dies privat ist.
  Future<Directory> get _publicDocDir async {
    if (Platform.isAndroid) {
      // Hack/Standardweg um auf /storage/emulated/0/Documents zu kommen
      // path_provider gibt uns oft nur die Sandbox.
      Directory? extDir = await getExternalStorageDirectory();
      // extDir ist typischerweise: /storage/emulated/0/Android/data/com.app/files
      // Wir wollen aber: /storage/emulated/0/Documents/CapturedContentReaderData

      if (extDir != null) {
        // Wir schneiden den Pfad ab, bis wir bei '0' (root user storage) sind
        // Das ist etwas fragil, aber gängige Praxis für File-Manager-artige Apps
        final List<String> paths = extDir.path.split('/');
        String newPath = '';
        for (String folder in paths) {
          if (folder == 'Android') break;
          newPath += '$folder/';
        }
        return Directory(p.join(newPath, 'Documents'));
      }
    }
    // Fallback (z.B. Linux später, oder wenn oben fehlschlägt)
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _ensureDirectoryExists() async {
    try {
      final docDir = await _publicDocDir;
      final appDir = Directory(p.join(docDir.path, _appFolderName));

      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
        print('Root Directory created at: ${appDir.path}');
      } else {
        print('Root Directory found at: ${appDir.path}');
      }
      return true;
    } catch (e) {
      print('Error creating directory: $e');
      return false;
    }
  }

  /// Gibt den Root-Ordner der App zurück (~/Documents/ReadItLater)
  Future<Directory> getAppDirectory() async {
    final docDir = await _publicDocDir;
    return Directory(p.join(docDir.path, _appFolderName));
  }
}
