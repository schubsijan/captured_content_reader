import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/library/ui/library_screen.dart';
import '../features/tags/ui/tag_overview_screen.dart';

enum MainTab { library, archive, tags }

final currentTabProvider = StateProvider<MainTab>((ref) => MainTab.library);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentTab.index,
        children: const [
          LibraryScreen(isArchive: false),
          LibraryScreen(isArchive: true),
          TagOverviewScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab.index,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).state = MainTab.values[index];
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Bibliothek',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: 'Archiv',
          ),
          NavigationDestination(
            icon: Icon(Icons.tag_outlined),
            selectedIcon: Icon(Icons.tag),
            label: 'Tags',
          ),
        ],
      ),
    );
  }
}
