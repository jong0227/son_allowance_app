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

/// 경제왕 탭에서 보여주는 생활 경제지표 (물가 상승률 + 원/달러 환율).
class EconomyIndicators {
  final double? inflationYoY; // 소비자물가 전년동월 대비 %
  final DateTime? inflationAsOf;
  final double? usdKrw; // 1달러 = 몇 원
  final DateTime? usdAsOf;

  const EconomyIndicators({
    this.inflationYoY,
    this.inflationAsOf,
    this.usdKrw,
    this.usdAsOf,
  });

  bool get isEmpty => inflationYoY == null && usdKrw == null;
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

  /// 물가 상승률(전년동월 대비) + 원/달러 환율. 개별 실패는 null로 남는다.
  Future<EconomyIndicators> fetchIndicators(String ecosKey) async {
    double? inflation;
    DateTime? inflationAt;
    // 소비자물가지수(총지수, 월) 2년치를 받아 같은 달끼리 비교해 상승률을 계산한다.
    final cpi = await _fetchEcosSeries(ecosKey, '901Y009', 'M', '0', 30);
    if (cpi.length > 12) {
      final latest = cpi.last;
      // 12개월 전 같은 달 찾기
      for (var i = cpi.length - 2; i >= 0; i--) {
        final prev = cpi[i];
        if (prev.$2 != null &&
            latest.$2 != null &&
            prev.$2!.year == latest.$2!.year - 1 &&
            prev.$2!.month == latest.$2!.month) {
          if (prev.$1 > 0) {
            inflation = (latest.$1 / prev.$1 - 1) * 100;
            inflationAt = latest.$2;
          }
          break;
        }
      }
    }

    final usd = await _fetchEcosSeries(ecosKey, '731Y001', 'D', '0000001', 10);
    final lastUsd = usd.isEmpty ? null : usd.last;

    return EconomyIndicators(
      inflationYoY: inflation,
      inflationAsOf: inflationAt,
      usdKrw: lastUsd?.$1,
      usdAsOf: lastUsd?.$2,
    );
  }

  /// ECOS 월간 통계의 가장 최근 유효값 + 기준월. 실패 시 null.
  Future<(double, DateTime?)?> _fetchEcosLatest(String key, String stat, String item) async {
    final rows = await _fetchEcosSeries(key, stat, 'M', item, 24);
    return rows.isEmpty ? null : rows.last;
  }

  /// ECOS 시계열을 오래된 것 → 최신 순으로 가져온다.
  /// [cycle]은 'M'(월) 또는 'D'(일). 실패하면 빈 목록.
  Future<List<(double, DateTime?)>> _fetchEcosSeries(
      String key, String stat, String cycle, String item, int count) async {
    if (key.trim().isEmpty) return const [];
    try {
      final now = DateTime.now();
      final isDaily = cycle == 'D';
      final start = isDaily
          ? _yyyymmdd(now.subtract(const Duration(days: 20)))
          : _yyyymm(DateTime(now.year - 3, now.month));
      final end = isDaily ? _yyyymmdd(now) : _yyyymm(now);
      final uri = Uri.parse(
        'https://ecos.bok.or.kr/api/StatisticSearch/${key.trim()}/json/kr/1/$count/'
        '$stat/$cycle/$start/$end/$item',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final rows = body?['StatisticSearch']?['row'];
      if (rows is! List) return const [];
      final out = <(double, DateTime?)>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final v = double.tryParse(row['DATA_VALUE']?.toString() ?? '');
        if (v == null) continue;
        out.add((v, _parseTime(row['TIME']?.toString())));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  String _yyyymm(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}';
  String _yyyymmdd(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  /// ECOS의 TIME 문자열(YYYYMM 또는 YYYYMMDD)을 날짜로.
  DateTime? _parseTime(String? s) {
    if (s == null || s.length < 6) return null;
    final y = int.tryParse(s.substring(0, 4));
    final m = int.tryParse(s.substring(4, 6));
    if (y == null || m == null) return null;
    final d = s.length >= 8 ? int.tryParse(s.substring(6, 8)) ?? 1 : 1;
    return DateTime(y, m, d);
  }
}
