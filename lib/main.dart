import 'dart:io';

import 'package:captured_content_reader/services/background_manager.dart';
import 'package:captured_content_reader/services/notification_service.dart';
// WICHTIG: Importiere die background.dart, damit initializeBackgroundService bekannt ist
import 'package:captured_content_reader/services/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captured_content_reader/database/app_database.dart';
import 'package:captured_content_reader/features/onboarding/providers/app_startup_provider.dart';
import 'package:captured_content_reader/features/onboarding/ui/onboarding_screen.dart';
import 'package:captured_content_reader/navigation/main_navigation_screen.dart';
import 'package:captured_content_reader/navigation/navigation_handler.dart';

// Dein db/connect.go Äquivalent
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wir erstellen den Container manuell
  final container = ProviderContainer();

  // WICHTIG: Den Service NICHT awaiten, bevor runApp startet,
  // oder sicherstellen, dass die Navigation erst später triggert.
  // Wir starten die Initialisierung parallel zum App-Build.
  container.read(notificationServiceProvider).init();

  if (Platform.isAndroid || Platform.isIOS) {
    await initializeBackgroundService();
    FlutterBackgroundService().startService();
  }

  runApp(
    // WICHTIG: UncontrolledProviderScope nutzen, um unseren container zu übergeben
    UncontrolledProviderScope(
      container: container,
      child: const CleanReadApp(),
    ),
  );
}

class CleanReadApp extends ConsumerWidget {
  const CleanReadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // INITIALISIERUNG DER GLOBALEN HANDLER
    ref.watch(navigationHandlerProvider);
    ref.watch(backgroundManagerProvider);

    final startupState = ref.watch(appStartupProvider);
    final navKey = ref.watch(navigatorKeyProvider);

    return MaterialApp(
      title: 'CleanRead',
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _buildHome(startupState),
    );
  }

  Widget _buildHome(AppStartupState state) {
    switch (state) {
      case AppStartupState.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AppStartupState.onboarding:
        return const OnboardingScreen();
      case AppStartupState.library:
        return const MainNavigationScreen();
    }
  }
}
