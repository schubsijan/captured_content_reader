import 'package:captured_content_reader/features/library/providers/library_providers.dart';
import 'package:captured_content_reader/features/onboarding/providers/app_startup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/storage_access.dart';
import '../../../services/library_sync_service.dart';

class SetupState {
  final int
  currentStep; // 0: Welcome/Storage, 1: Folder, 2: Notifications, 3: Indexing
  final bool storageGranted;
  final String? selectedPath;
  final bool isIndexing;
  final String? error;

  SetupState({
    this.currentStep = 0,
    this.storageGranted = false,
    this.selectedPath,
    this.isIndexing = false,
    this.error,
  });

  SetupState copyWith({
    int? currentStep,
    bool? storageGranted,
    String? selectedPath,
    bool? isIndexing,
    String? error,
  }) {
    return SetupState(
      currentStep: currentStep ?? this.currentStep,
      storageGranted: storageGranted ?? this.storageGranted,
      selectedPath: selectedPath ?? this.selectedPath,
      isIndexing: isIndexing ?? this.isIndexing,
      error: error,
    );
  }
}

class SetupHandler extends StateNotifier<SetupState> {
  final StorageService _storage;
  final LibrarySyncService _sync;

  final Ref _ref;

  SetupHandler(this._storage, this._sync, this._ref) : super(SetupState());

  // Neuer Schritt für Benachrichtigungen
  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // Weiter zum Indexing (Step 3)
      state = state.copyWith(currentStep: 3);
    } else {
      // Optional: Fehler setzen oder trotzdem weiterlassen (User-Entscheidung)
      state = state.copyWith(
        error:
            "Benachrichtigungen sind deaktiviert. Du wirst keine Status-Updates erhalten.",
        currentStep: 3, // Wir lassen ihn trotzdem zum Indexing weiter
      );
    }
  }

  // Schritt 1: Berechtigung anfragen
  Future<void> requestStoragePermission() async {
    final granted = await _storage.init(); // Nutzt deine vorhandene Logik
    if (granted) {
      state = state.copyWith(storageGranted: true, currentStep: 1);
    } else {
      state = state.copyWith(error: "Berechtigung wurde verweigert.");
    }
  }

  // Schritt 2: Ordner wählen
  Future<void> pickBaseFolder() async {
    try {
      String? path = await _storage.pickDirectory();
      if (path != null) {
        // Nach dem Ordner wählen wir jetzt Schritt 2 (Notifications)
        state = state.copyWith(selectedPath: path, currentStep: 2);
      }
    } catch (e) {
      state = state.copyWith(error: "Ordner konnte nicht ausgewählt werden.");
    }
  }

  // Schritt 3: Erster Full-Index (Rehydrierung der DB)
  Future<void> runInitialIndexing() async {
    state = state.copyWith(isIndexing: true, error: null);
    print("Indexing gestartet...");

    try {
      final appDir = await _storage.getAppDirectory();
      print(
        "Verzeichnis-Check: ${appDir.path} -> Exists: ${appDir.existsSync()}",
      );

      // Führe den Sync aus
      await _sync.syncFileSystemToDatabase();

      // Prüfen ob Artikel in die DB geschrieben wurden
      // (Hier könntest du testweise die DB abfragen)

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);

      print("Indexing erfolgreich beendet.");
      _ref.read(appStartupProvider.notifier).completeOnboarding();
    } catch (e, stack) {
      print("FATALER FEHLER beim Indexing: $e");
      print(stack);
      state = state.copyWith(error: e.toString(), isIndexing: false);
    } finally {
      state = state.copyWith(isIndexing: false);
    }
  }
}

final setupHandlerProvider = StateNotifierProvider<SetupHandler, SetupState>((
  ref,
) {
  final storage = ref.watch(storageServiceProvider);
  final sync = ref.watch(librarySyncServiceProvider);
  return SetupHandler(storage, sync, ref);
});

// Provider um zu prüfen, ob wir direkt zur Library dürfen
final isFirstStartProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool('onboarding_complete') ?? false);
});
