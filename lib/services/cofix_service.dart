import 'dart:convert';
import 'package:http/http.dart' as http;

/// 화면에 보여줄 COFIX 금리 정보.
class CofixInfo {
  final double rate; // % (예: 3.05)
  final DateTime? asOf; // 공시일
  final bool isAuto; // true=은행연합회 자동조회, false=부모 수동입력

  const CofixInfo({required this.rate, this.asOf, required this.isAuto});
}

/// COFIX(신규취급액기준)를 전국은행연합회 공시 페이지에서 가져온다. 인증키 불필요.
///
/// 이 페이지는 HTTP 헤더(euc-kr)와 meta(utf-8) 인코딩이 어긋나 있어 한글 디코딩이
/// 깨질 수 있다. 그래서 한글에 의존하지 않고 바이트를 latin1로 1:1 디코딩해 ASCII
/// (날짜/숫자/%)만으로 파싱한다. 페이지에서 처음 나오는 'YYYY. MM. DD. ... X.XX%'
/// 조합이 신규취급액기준 COFIX(표준 COFIX)다.
class CofixService {
  const CofixService();

  static const String _url = 'https://portal.kfb.or.kr/fingoods/cofix.php';
  static final RegExp _pattern =
      RegExp(r'(\d{4})\.\s*(\d{1,2})\.\s*(\d{1,2})\.[\s\S]{0,60}?([0-9]+\.[0-9]+)\s*%');

  Future<CofixInfo?> fetchCofix() async {
    try {
      final res = await http.get(Uri.parse(_url), headers: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
      }).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = latin1.decode(res.bodyBytes, allowInvalid: true); // ASCII만 사용
      final m = _pattern.firstMatch(body);
      if (m == null) return null;
      final rate = double.tryParse(m.group(4)!);
      if (rate == null) return null;
      final y = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      final asOf = (y != null && mo != null && d != null) ? DateTime(y, mo, d) : null;
      return CofixInfo(rate: rate, asOf: asOf, isAuto: true);
    } catch (_) {
      return null;
    }
  }
}
