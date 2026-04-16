import 'dart:async';
import 'package:captured_content_reader/services/background_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/deeplink_service.dart';
import '../../features/reader/ui/article_reader_screen.dart';
import '../utils/android_utils.dart';

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

final navigationHandlerProvider = Provider<NavigationHandler>((ref) {
  return NavigationHandler(ref);
});

class NavigationHandler {
  final Ref _ref;
  StreamSubscription? _linkSubscription;

  NavigationHandler(this._ref) {
    _init();
  }

  void _init() {
    final deeplinkService = _ref.read(deeplinkServiceProvider);

    deeplinkService.getInitialLink().then((uri) {
      if (uri != null) _handleRouting(uri);
    });

    _linkSubscription = deeplinkService.linkStream.listen((uri) {
      _handleRouting(uri);
    });
  }

  /// Hier ist die wichtigste Änderung: async und kontrolliertes Minimieren
  Future<void> _handleRouting(Uri uri) async {
    if (uri.host == 'import') {
      final fileName = uri.queryParameters['file'];
      if (fileName != null && fileName.isNotEmpty) {
        // 1. Service im Vordergrund stabilisieren
        final success = await _ref
            .read(backgroundManagerProvider)
            .startFileWatcher(fileName);

        // 2. Erst wenn der Service "fest im Sattel sitzt", minimieren wir die App
        if (success) {
          AndroidUtils.minimizeApp();
        }
      }
    }

    if (uri.host == 'open') {
      final id = uri.queryParameters['id'];
      if (id != null) openReader(id);
    }
  }

  void openReader(String articleId) {
    final navKey = _ref.read(navigatorKeyProvider);

    if (navKey.currentState != null) {
      print("Navigiere zu Artikel: $articleId");
      // Wir nutzen pushReplacement oder stellen sicher, dass wir nicht
      // doppelt navigieren, falls der Klick mehrfach registriert wird.
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ArticleReaderScreen(articleId: articleId),
        ),
      );
    } else {
      print("NAVIGATOR ERROR: currentState ist null!");
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
