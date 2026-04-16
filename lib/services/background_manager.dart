import 'package:captured_content_reader/services/storage_access.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import '../features/library/providers/library_providers.dart';
import 'library_sync_service.dart';

class BackgroundManager {
  final Ref _ref;
  final _service = FlutterBackgroundService();

  BackgroundManager(this._ref) {
    _listenToEvents();
  }

  void _listenToEvents() {
    _service.on('import_success').listen((event) async {
      if (event == null) return;
      final String articleId = event['articleId'];

      _ref.invalidate(unreadArticlesProvider);
      await _ref.read(librarySyncServiceProvider).syncFileSystemToDatabase();
      await _ref
          .read(notificationServiceProvider)
          .showImportSuccess(articleId, "Artikel erfolgreich importiert");
    });
  }

  /// Startet den Datei-Watcher und gibt true zurück, wenn der Service bereit ist.
  Future<bool> startFileWatcher(String fileName) async {
    // 1. Prüfen, ob der Service bereits läuft
    bool isRunning = await _service.isRunning();

    if (!isRunning) {
      // Startvorgang einleiten
      await _service.startService();

      // CRITICAL: Wir geben Android Zeit (1 Sekunde), den Service als
      // Foreground-Prozess zu etablieren, WÄHREND die App noch im Vordergrund ist.
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    final appDir = await _ref.read(storageServiceProvider).getAppDirectory();

    // 2. Befehl an das Isolate senden
    _service.invoke('start_watching', {
      'fileName': fileName,
      'sourcePath': '/storage/emulated/0/Download',
      'targetPath': appDir.path,
    });

    return true;
  }
}

final backgroundManagerProvider = Provider((ref) => BackgroundManager(ref));
