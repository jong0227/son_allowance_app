import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/changelog.dart';

/// 앱 안 "새로운 소식"은 릴리즈할 때마다 손으로 한 칸 추가해야 한다.
/// 빼먹기 딱 좋은 자리라, 빼먹으면 테스트가 깨지게 해 둔다.
void main() {
  String pubspecVersion() {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    return line.split(':')[1].split('+').first.trim();
  }

  test('지금 앱 버전의 소식이 changelog에 들어 있다', () {
    final v = pubspecVersion();
    expect(
      kReleaseNotes.any((n) => n.version == v),
      true,
      reason: 'pubspec 버전이 $v인데 changelog.dart에 그 버전 소식이 없다. '
          '릴리즈 전에 kReleaseNotes 맨 위에 한 칸 추가할 것 '
          '(아들이 폰에서 브라우저를 못 써서 앱 안에서만 볼 수 있다).',
    );
  });

  test('최신 소식이 목록 맨 위에 있다', () {
    expect(kReleaseNotes, isNotEmpty);
    expect(kReleaseNotes.first.version, pubspecVersion(),
        reason: '새 소식은 맨 위에 넣어야 아이가 열었을 때 바로 보인다');
  });

  test('버전이 중복되지 않는다', () {
    final versions = kReleaseNotes.map((n) => n.version).toList();
    expect(versions.toSet().length, versions.length);
  });

  test('모든 소식에 날짜·제목·내용이 채워져 있다', () {
    for (final n in kReleaseNotes) {
      expect(n.date.trim(), isNotEmpty, reason: 'v${n.version} 날짜가 비었다');
      expect(n.headline.trim(), isNotEmpty, reason: 'v${n.version} 제목이 비었다');
      expect(n.changes, isNotEmpty, reason: 'v${n.version} 내용이 비었다');
      for (final c in n.changes) {
        expect(c.trim(), isNotEmpty);
      }
    }
  });
}
