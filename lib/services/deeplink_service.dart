import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeeplinkService {
  final _appLinks = AppLinks();

  // Stream für die Handler
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  // Für den Kaltstart
  Future<Uri?> getInitialLink() async {
    return await _appLinks.getInitialLink();
  }
}

final deeplinkServiceProvider = Provider((ref) => DeeplinkService());
