import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

enum AppStartupState { loading, onboarding, library }

final appStartupProvider =
    StateNotifierProvider<AppStartupNotifier, AppStartupState>((ref) {
      return AppStartupNotifier();
    });

class AppStartupNotifier extends StateNotifier<AppStartupState> {
  AppStartupNotifier() : super(AppStartupState.loading) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isComplete = prefs.getBool('onboarding_complete') ?? false;
    final savedPath = prefs.getString('custom_storage_path');

    if (isComplete && savedPath != null && Directory(savedPath).existsSync()) {
      state = AppStartupState.library;
    } else {
      state = AppStartupState.onboarding;
    }
  }

  void completeOnboarding() {
    state = AppStartupState.library;
  }
}
