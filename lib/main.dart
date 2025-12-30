import 'package:captured_content_reader/services/background.dart';
import 'package:captured_content_reader/services/import_starter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:captured_content_reader/database/app_database.dart'; // DB Import
import 'package:captured_content_reader/features/library/ui/library_screen.dart'; // Screen Import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'features/reader/ui/article_reader_screen.dart';

// DATABASE PROVIDER
// Wir machen ihn global oder in einer providers.dart Datei.
// Wichtig: KeepAlive, damit die Verbindung nicht geschlossen wird.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// --- Native Helper ---
class AndroidUtils {
  static const _platform = MethodChannel(
    'com.example.captured_content_reader/android',
  );

  static Future<void> minimizeApp() async {
    try {
      await _platform.invokeMethod('minimizeApp');
    } catch (e) {
      print("Minimize Error: $e");
    }
  }

  static Future<void> closeAppCompletely() async {
    try {
      await _platform.invokeMethod('finishAndRemoveTask');
    } catch (e) {
      SystemNavigator.pop();
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  if (Platform.isAndroid || Platform.isIOS) {
    await initializeBackgroundService();
  } else if (Platform.isLinux) {
    // TODO: Hier später den HTTP Server starten
    // await HttpImportServer.start();
    print("Linux erkannt: Starte HTTP Server Modus...");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ImportStarter _importStarter = ImportStarter();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Steuert, ob wir den weißen Hintergrund (Bibliothek) sehen
  bool _showMainUI = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.notification.request();
      _initLocalNotifications();

      // ... Logik für Notification Launch (Mobile Only) ...
      final notifLaunchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

      if (notifLaunchDetails?.didNotificationLaunchApp == true) {
        // Das ist die Fortsetzung von Szenario 2!
        gIsOverlaySession = true; // Wir sind immer noch im "Geister-Modus"

        final payload = notifLaunchDetails!.notificationResponse?.payload;
        if (payload != null) {
          Future.delayed(Duration.zero, () => _openTaggingOverlay(payload));
        }
        _importStarter.init(onCheckComplete: null);
        return;
      }
    }

    // Für Linux setzen wir UI direkt auf true, da es keine "Hidden Mode" Szenarien gibt
    if (Platform.isLinux) {
      setState(() {
        _showMainUI = true;
      });
      // Linux braucht den ImportStarter nicht, wenn du alles über HTTP machst.
    }

    // CHECK: Normaler Start oder Deep Link?
    _importStarter.init(
      onCheckComplete: (foundLink) {
        if (foundLink) {
          // Szenario 2 (Phase 1): Browser Link -> App geht gleich wieder zu.
        } else {
          // Szenario 1: Normaler Start -> Bibliothek anzeigen
          if (mounted) {
            setState(() {
              _showMainUI = true;
            });
          }
        }
      },
    );
  }

  void _initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Szenario 3 (Notification Klick während App läuft)
          // oder Szenario 2 (wenn App noch nicht gekillt war)
          _openTaggingOverlay(response.payload!);
        }
      },
    );
  }

  void _openTaggingOverlay(String articleId) {
    // Wenn die Library offen war, machen wir sie "unsichtbar" für den Overlay-Effekt
    if (_showMainUI) {
      setState(() {
        _showMainUI = false;
      });
    }

    navigatorKey.currentState?.push(
      PageRouteBuilder(
        opaque: false,
        // Wir deaktivieren die Standard-Animation für schnelleres Erscheinen
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, __) => TaggingOverlay(
          articleId: articleId,
          // Fall 1: Hintergrund geklickt -> Weg hier (Minimieren/Kill)
          onDismiss: () {
            Navigator.pop(context);
            _handleOverlayClosed();
          },
          // Fall 2: Lesen geklickt -> App öffnen & Reader starten
          onRead: () {
            Navigator.pop(context); // Overlay weg

            // 1. Main UI sichtbar machen (wichtig für Context)
            setState(() {
              _showMainUI = true;
            });

            // 2. Zum Reader navigieren
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ArticleReaderScreen(articleId: articleId),
              ),
            );
          },
        ),
      ),
    );
  }

  // WICHTIG: Das passiert, wenn das Overlay geschlossen wird
  void _handleOverlayClosed() {
    if (gIsOverlaySession) {
      // Szenario 2: Wir waren nur für das Overlay da -> Komplett weg!
      AndroidUtils.closeAppCompletely();
    } else {
      // Szenario 3: Wir sind eigentlich eine Bibliothek -> UI wiederherstellen & Minimieren
      setState(() {
        _showMainUI = true; // Weißer Hintergrund an (für Recents Vorschau)
      });

      // Kurzer Delay, damit Flutter den Frame malt, bevor wir minimieren
      Future.delayed(const Duration(milliseconds: 50), () {
        AndroidUtils.minimizeApp();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanRead',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        scaffoldBackgroundColor: _showMainUI
            ? Colors.white
            : Colors.transparent,
      ),
      home: _showMainUI
          ? const LibraryScreen() // <--- HIER: Neuer Screen
          : const Scaffold(backgroundColor: Colors.transparent),
    );
  }
}

// --- Screens ---

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CleanRead Library")),
      body: const Center(child: Text("Deine Bibliothek (Szenario 1 & 3)")),
    );
  }
}

class TaggingOverlay extends StatelessWidget {
  final String articleId;
  final VoidCallback onDismiss; // Schließen & Minimieren
  final VoidCallback onRead; // App öffnen & Lesen

  const TaggingOverlay({
    super.key,
    required this.articleId,
    required this.onDismiss,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Wichtig für Transparenz
      body: Stack(
        children: [
          // 1. HINTERGRUND (Klick schließt Overlay)
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.black54, // Halb-transparentes Abdunkeln
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 2. CONTENT (Unten angedockt)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16), // Etwas Abstand vom Rand
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Nur so hoch wie nötig
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titel Zeile
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.green.shade800),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gespeichert!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Artikel bereit zum Lesen.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Button (Volle Breite)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: onRead,
                      icon: const Icon(Icons.chrome_reader_mode),
                      label: const Text(
                        "Jetzt Lesen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
