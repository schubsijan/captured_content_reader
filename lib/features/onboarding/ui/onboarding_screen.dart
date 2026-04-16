import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/setup_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupHandlerProvider);
    final handler = ref.read(setupHandlerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildStep(context, state, handler),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    SetupState state,
    SetupHandler handler,
  ) {
    switch (state.currentStep) {
      case 0:
        return _OnboardingLayout(
          icon: Icons.security,
          title: "Speicherzugriff",
          description: "Wir benötigen Zugriff, um deine Artikel zu lesen.",
          child: Column(
            children: [
              ElevatedButton(
                onPressed: handler.requestStoragePermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.storageGranted
                      ? Colors.green[100]
                      : null,
                ),
                child: Text(
                  state.storageGranted
                      ? "Berechtigung erteilt ✓"
                      : "Berechtigung anfragen",
                ),
              ),
            ],
          ),
        );
      case 1:
        return _OnboardingLayout(
          icon: Icons.folder_open,
          title: "Speicherort wählen",
          description: "Wo liegen deine CleanRead-Artikel?",
          child: Column(
            children: [
              ElevatedButton(
                onPressed: handler.pickBaseFolder,
                child: Text(
                  state.selectedPath != null
                      ? "Ordner gewählt ✓"
                      : "Ordner wählen",
                ),
              ),
              if (state.selectedPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.selectedPath!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );

      case 2: // NEU: Benachrichtigungen anfragen
        return _OnboardingLayout(
          icon: Icons.notifications_active,
          title: "Auf dem Laufenden bleiben",
          description:
              "Wir informieren dich, sobald ein Artikel fertig importiert wurde.",
          child: Column(
            children: [
              ElevatedButton(
                onPressed: handler.requestNotificationPermission,
                child: const Text("Benachrichtigungen erlauben"),
              ),
              TextButton(
                onPressed: () =>
                    handler.state = handler.state.copyWith(currentStep: 3),
                child: const Text(
                  "Später vielleicht",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );

      case 3: // Indexing (vorher Case 2)
        return _OnboardingLayout(
          icon: Icons.check_circle_outline,
          title: "Fast fertig!",
          description: "Gewählter Pfad:\n${state.selectedPath}",
          child: Column(
            children: [
              ElevatedButton(
                onPressed: handler.runInitialIndexing,
                child: const Text("Index jetzt aufbauen"),
              ),
              if (state.isIndexing) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// Kleiner Layout-Helfer (dein layout/base.templ)
class _OnboardingLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  const _OnboardingLayout({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}
