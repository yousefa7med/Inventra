import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  static Future<void> launchDialer(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: trimmed);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}