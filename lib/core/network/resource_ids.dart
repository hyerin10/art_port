/// 서버 UUID·원격 URL 판별.
abstract final class ResourceIds {
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isUuid(String value) => _uuid.hasMatch(value);

  static bool isRemoteUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }
}
