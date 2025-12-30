import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:captured_content_reader/main.dart'; // Zugriff auf AndroidUtils
import 'package:captured_content_reader/services/storage_access.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/services.dart';

// GLOBALER STATUS:
// true = Die App läuft nur temporär für diesen Import (Szenario 2)
// false = Die App läuft "echt" als Bibliothek (Szenario 1 & 3)
bool gIsOverlaySession = false;

class ImportStarter {
  final _appLinks = AppLinks();
  final StorageService _storageService = StorageService();
  StreamSubscription? _linkSubscription;

  void init({Function(bool foundLink)? onCheckComplete}) {
    _checkInitialLink(onCheckComplete);

    // Warm Start Listener (Szenario 3)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      // Wenn wir hier einen Link bekommen, läuft die App bereits!
      // Also KEINE reine Overlay-Session, sondern wir wollen die App behalten.
      gIsOverlaySession = false;
      _handleDeepLink(uri);
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  Future<void> _checkInitialLink(Function(bool)? onCheckComplete) async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        // Szenario 2: Kaltstart durch Link
        gIsOverlaySession = true; // Wir sind nur ein Geist

        if (onCheckComplete != null) onCheckComplete(true);
        _handleDeepLink(uri);
      } else {
        // Szenario 1: Normaler Start über Icon
        gIsOverlaySession = false;

        if (onCheckComplete != null) onCheckComplete(false);
      }
    } catch (e) {
      print('Link Error: $e');
      if (onCheckComplete != null) onCheckComplete(false);
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.host == 'import') {
      final fileName = uri.queryParameters['file'];
      if (fileName != null && fileName.isNotEmpty) {
        bool hasAccess = await _storageService.init();
        if (!hasAccess) return;

        if (Platform.isAndroid || Platform.isIOS) {
          final service = FlutterBackgroundService();
          if (!await service.isRunning()) {
            await service.startService();
          }

          service.invoke("start_watching", {"fileName": fileName});

          // WICHTIG:
          // In Szenario 2 (Cold) wollen wir die App sofort schließen/killen, bis die Notification kommt.
          // In Szenario 3 (Warm) wollen wir nur minimieren, damit der User-State erhalten bleibt.
          if (gIsOverlaySession) {
            SystemNavigator.pop(); // oder AndroidUtils.closeAppCompletely();
          } else {
            AndroidUtils.minimizeApp();
          }
        }
      }
    }
  }
}
