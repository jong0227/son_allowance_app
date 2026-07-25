import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/theme/app_theme.dart';

void main() {
  group('AppPalette.tagsFor', () {
    test('간식과 기타처럼 실제로 해시 충돌났던 카테고리도 서로 다른 색을 받는다', () {
      final map = AppPalette.light.tagsFor(['간식', '기타']);
      expect(map['간식'], isNotNull);
      expect(map['기타'], isNotNull);
      expect(map['간식'], isNot(equals(map['기타'])));
    });

    test('기본 지출 카테고리(간식/문구/게임/기타)는 서로 다 겹치지 않는다', () {
      final map = AppPalette.light.tagsFor(['간식', '문구', '게임', '기타']);
      final colors = map.values.toSet();
      expect(colors.length, 4, reason: '4개 카테고리가 4개의 서로 다른 색을 받아야 함');
    });

    test('간식과 기타는 색상환에서도 서로 멀리 떨어진 색을 받는다', () {
      // 정렬 순서(간식·게임·기타·문구)상 간식=0번, 기타=2번 슬롯이라
      // 색상환을 순서대로만 채우면 두 색이 45˚밖에 안 떨어져 파스텔끼리
      // 비슷해 보였다. 최대한 멀리 떨어진 슬롯부터 채워야 한다.
      final tags = AppPalette.light.tags;
      final map = AppPalette.light.tagsFor(['간식', '게임', '기타', '문구']);
      final snackIdx = tags.indexOf(map['간식']!);
      final etcIdx = tags.indexOf(map['기타']!);
      final n = tags.length;
      final dist = ((snackIdx - etcIdx).abs()).clamp(0, n) ;
      final wrapped = dist > n / 2 ? n - dist : dist;
      expect(wrapped, greaterThanOrEqualTo(n ~/ 4),
          reason: '색상환 4분의 1바퀴 이상 떨어져 있어야 눈으로 확실히 구분됨');
    });

    test('항목 수가 팔레트 크기 이하면 절대 겹치지 않는다', () {
      final keys = List.generate(AppPalette.light.tags.length, (i) => 'cat$i');
      final map = AppPalette.light.tagsFor(keys);
      final colors = map.values.toSet();
      expect(colors.length, keys.length);
    });

    test('같은 목록이면 항상 같은 항목이 같은 색을 받는다(순서 무관)', () {
      final a = AppPalette.light.tagsFor(['간식', '문구', '기타']);
      final b = AppPalette.light.tagsFor(['기타', '간식', '문구']);
      expect(a, equals(b));
    });

    test('다크 모드도 16색 팔레트로 겹치지 않는다', () {
      final map = AppPalette.dark.tagsFor(['간식', '기타']);
      expect(map['간식'], isNot(equals(map['기타'])));
    });
  });
}
