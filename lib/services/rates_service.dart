import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cofix_service.dart';

enum RateKind { baseRate, deposit, cofix }

/// "오늘의 금리" 한 항목 (기준금리 / 정기예금 / COFIX).
class RateInfo {
  final RateKind kind;
  final String label;
  final double rate; // %
  final DateTime? asOf; // 기준 시점(월/공시일)

  const RateInfo({required this.kind, required this.label, required this.rate, this.asOf});
}

/// 금리 지표 모음 조회.
/// - 기준금리·정기예금: 한국은행 ECOS OpenAPI(인증키 필요).
/// - COFIX: 은행연합회 공시 페이지([CofixService], 키 불필요).
/// 개별 실패는 목록에서 빠지므로, 일부만 성공해도 나머지는 정상 표시된다.
class RatesService {
  const RatesService();

  // ECOS 통계/항목 코드 (인증키로 확인 완료)
  static const _baseRateStat = '722Y001';
  static const _baseRateItem = '0101000'; // 한국은행 기준금리
  static const _depositStat = '121Y002';
  static const _depositItem = 'BEABAA2118'; // 정기예금(1년)

  Future<List<RateInfo>> fetchAll(String ecosKey) async {
    final out = <RateInfo>[];

    final base = await _fetchEcosLatest(ecosKey, _baseRateStat, _baseRateItem);
    if (base != null) {
      out.add(RateInfo(
          kind: RateKind.baseRate, label: '기준금리', rate: base.$1, asOf: base.$2));
    }

    final dep = await _fetchEcosLatest(ecosKey, _depositStat, _depositItem);
    if (dep != null) {
      out.add(RateInfo(
          kind: RateKind.deposit, label: '정기예금 1년', rate: dep.$1, asOf: dep.$2));
    }

    final cofix = await const CofixService().fetchCofix();
    if (cofix != null) {
      out.add(RateInfo(
          kind: RateKind.cofix, label: 'COFIX', rate: cofix.rate, asOf: cofix.asOf));
    }

    return out;
  }

  /// ECOS 월간 통계의 가장 최근 유효값 + 기준월. 실패 시 null.
  Future<(double, DateTime?)?> _fetchEcosLatest(String key, String stat, String item) async {
    if (key.trim().isEmpty) return null;
    try {
      final now = DateTime.now();
      final end = _yyyymm(now);
      final start = _yyyymm(DateTime(now.year - 2, now.month));
      final uri = Uri.parse(
        'https://ecos.bok.or.kr/api/StatisticSearch/${key.trim()}/json/kr/1/24/'
        '$stat/M/$start/$end/$item',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final rows = body?['StatisticSearch']?['row'];
      if (rows is! List || rows.isEmpty) return null;
      for (final row in rows.reversed) {
        if (row is! Map) continue;
        final rate = double.tryParse(row['DATA_VALUE']?.toString() ?? '');
        if (rate == null) continue;
        return (rate, _parseYyyymm(row['TIME']?.toString()));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _yyyymm(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}';

  DateTime? _parseYyyymm(String? s) {
    if (s == null || s.length < 6) return null;
    final y = int.tryParse(s.substring(0, 4));
    final m = int.tryParse(s.substring(4, 6));
    return (y == null || m == null) ? null : DateTime(y, m);
  }
}
