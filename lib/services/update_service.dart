import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String? apkUrl; // 최신 릴리즈의 APK 다운로드 링크
  final String releaseUrl; // 릴리즈 페이지

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.apkUrl,
    required this.releaseUrl,
  });
}

/// GitHub 최신 릴리즈를 확인해 현재 설치 버전과 비교한다.
class UpdateService {
  const UpdateService();

  static const _repo = 'jong0227/son_allowance_app';
  static const releasesPage = 'https://github.com/$_repo/releases/latest';

  Future<UpdateInfo?> check() async {
    final info = await PackageInfo.fromPlatform();
    final res = await http.get(
      Uri.parse('https://api.github.com/repos/$_repo/releases/latest'),
      headers: const {'Accept': 'application/vnd.github+json'},
    );
    if (res.statusCode != 200) return null;
    final j = jsonDecode(utf8.decode(res.bodyBytes));
    if (j is! Map) return null;
    final tag = (j['tag_name'] ?? '').toString().replaceFirst('v', '').trim();
    final releaseUrl = (j['html_url'] ?? releasesPage).toString();
    String? apkUrl;
    final assets = j['assets'];
    if (assets is List) {
      for (final a in assets) {
        if (a is Map && (a['name'] ?? '').toString().toLowerCase().endsWith('.apk')) {
          apkUrl = a['browser_download_url']?.toString();
          break;
        }
      }
    }
    return UpdateInfo(
      currentVersion: info.version,
      latestVersion: tag.isEmpty ? info.version : tag,
      hasUpdate: tag.isNotEmpty && _isNewer(tag, info.version),
      apkUrl: apkUrl,
      releaseUrl: releaseUrl,
    );
  }

  /// latest가 current보다 높은 버전이면 true. (숫자.숫자.숫자 비교)
  bool _isNewer(String latest, String current) {
    List<int> parts(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final a = parts(latest);
    final b = parts(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}
