import 'dart:convert';
import 'package:http/http.dart' as http;

/// 검색 결과 한 종목.
class StockQuote {
  final String symbol; // 예: AAPL, 005930.KS
  final String name; // 회사명 (영문/국문)
  final String exchange; // 거래소 표시명 (예: NasdaqGS, KSE)
  final String type; // EQUITY, ETF 등

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.type,
  });

  /// 티커 배지에 쓸 짧은 심볼(거래소 접미사 제거). 005930.KS -> 005930
  String get baseSymbol => symbol.split('.').first;

  /// 로고 이미지 URL(best-effort). 미국 종목은 대체로 표시되고, 없으면 위젯에서
  /// errorBuilder로 티커 배지로 대체한다. 한국 종목은 대부분 로고가 없어 배지로 표시됨.
  String get logoUrl => 'https://financialmodelingprep.com/image-stock/$baseSymbol.png';

  /// 한국 거래소 여부(.KS/.KQ)
  bool get isKorea => symbol.endsWith('.KS') || symbol.endsWith('.KQ');
}

/// 야후 파이낸스의 공개 검색 엔드포인트를 사용한 종목 자동완성.
/// - API 키 불필요(공개 저장소 안전), 한글·영어·티커 모두 검색 가능.
/// - 비공식 엔드포인트라 드물게 형식이 바뀌거나 제한될 수 있어, 실패해도
///   앱이 죽지 않도록 빈 목록/예외 처리한다.
class StockSearchService {
  const StockSearchService();

  /// 야후 검색은 한글 입력을 처리하지 못해서(영어명/티커만 가능), 자주 찾는
  /// 한국·미국 기업의 한글명을 영어 검색어로 바꿔주는 별칭表. 여기 없으면
  /// 사용자가 영어명이나 종목코드로 검색하도록 안내한다.
  static const Map<String, String> _koreanAlias = {
    // 한국
    '삼성전자': 'samsung electronics', '삼성': 'samsung', '에스케이하이닉스': 'sk hynix',
    'SK하이닉스': 'sk hynix', '하이닉스': 'sk hynix', '카카오': 'kakao',
    '카카오뱅크': 'kakaobank', '카카오게임즈': 'kakao games', '네이버': 'naver',
    '현대차': 'hyundai motor', '현대자동차': 'hyundai motor', '현대': 'hyundai',
    '기아': 'kia', 'LG에너지솔루션': 'lg energy solution', 'LG화학': 'lg chem',
    'LG전자': 'lg electronics', '엘지': 'lg', '포스코': 'posco', '포스코홀딩스': 'posco holdings',
    '삼성바이오로직스': 'samsung biologics', '삼성SDI': 'samsung sdi', '셀트리온': 'celltrion',
    '현대모비스': 'hyundai mobis', 'KB금융': 'kb financial', '신한지주': 'shinhan',
    '크래프톤': 'krafton', '하이브': 'hybe', '엔씨소프트': 'ncsoft', '넷마블': 'netmarble',
    '두산에너빌리티': 'doosan enerbility', '한화에어로스페이스': 'hanwha aerospace',
    'SK텔레콤': 'sk telecom', 'SK이노베이션': 'sk innovation', '한국전력': 'kepco',
    '삼성물산': 'samsung c&t', '삼성생명': 'samsung life', '에코프로': 'ecopro',
    '에코프로비엠': 'ecopro bm', '삼성전기': 'samsung electro',
    // 미국 (아이들이 자주 찾는)
    '애플': 'apple', '테슬라': 'tesla', '엔비디아': 'nvidia', '구글': 'alphabet',
    '알파벳': 'alphabet', '마이크로소프트': 'microsoft', '아마존': 'amazon', '메타': 'meta',
    '넷플릭스': 'netflix', '디즈니': 'disney', '나이키': 'nike', '스타벅스': 'starbucks',
    '코카콜라': 'coca cola', '맥도날드': 'mcdonalds', '팔란티어': 'palantir',
  };

  bool _hasHangul(String s) => RegExp(r'[가-힣㄰-㆏]').hasMatch(s);

  /// 한글 검색어를 야후가 이해하는 영어 검색어로 변환(가능하면). 못 찾으면 그대로 반환.
  String _normalizeQuery(String q) {
    if (!_hasHangul(q)) return q;
    if (_koreanAlias.containsKey(q)) return _koreanAlias[q]!;
    // 부분 입력(예: "삼성전")도 매칭: 별칭 키가 입력으로 시작하면 채택
    for (final e in _koreanAlias.entries) {
      if (e.key.startsWith(q)) return e.value;
    }
    return q;
  }

  Future<List<StockQuote>> search(String query) async {
    final raw = query.trim();
    if (raw.isEmpty) return const [];
    final q = _normalizeQuery(raw);
    final uri = Uri.parse(
        'https://query1.finance.yahoo.com/v1/finance/search?q=${Uri.encodeQueryComponent(q)}&quotesCount=12&newsCount=0');
    final res = await http.get(uri, headers: {
      // 브라우저 UA가 없으면 종종 403이 나므로 지정
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
      'Accept': 'application/json',
    });
    if (res.statusCode != 200) return const [];
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    final quotes = (body is Map ? body['quotes'] : null);
    if (quotes is! List) return const [];
    final result = <StockQuote>[];
    for (final q in quotes) {
      if (q is! Map) continue;
      final symbol = (q['symbol'] ?? '').toString();
      if (symbol.isEmpty) continue;
      final type = (q['quoteType'] ?? '').toString();
      // 주식/ETF 위주로만 노출(지수·환율·선물 제외)
      if (type != 'EQUITY' && type != 'ETF') continue;
      final name =
          (q['shortname'] ?? q['longname'] ?? q['symbol'] ?? '').toString();
      final exch = (q['exchDisp'] ?? q['exchange'] ?? '').toString();
      result.add(StockQuote(symbol: symbol, name: name, exchange: exch, type: type));
    }
    return result;
  }
}
