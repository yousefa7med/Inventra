import 'package:unorm_dart/unorm_dart.dart';

extension ArabicNormalizer on String {
  static final _diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
  static final _tatweel = RegExp(r'\u0640');

  String normalizeArabic() {
    var normalized = nfc(this);
    normalized = normalized
        .replaceAll(_diacritics, '')
        .replaceAll(_tatweel, '')
        .replaceAll('\u0625', '\u0627')
        .replaceAll('\u0623', '\u0627')
        .replaceAll('\u0622', '\u0627')
        .replaceAll('\u0629', '\u0647')
        .replaceAll('\u0649', '\u064A')
        .toLowerCase();
    return normalized;
  }
}