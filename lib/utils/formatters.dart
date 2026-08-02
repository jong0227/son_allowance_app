import 'package:intl/intl.dart';
import '../data/app_database.dart';

final _krwFormat = NumberFormat.decimalPattern('ko_KR');

String formatWon(int amount) => '${_krwFormat.format(amount)}원';

/// 앞 단어의 받침에 맞는 조사를 고른다. ('코스피는' / '코스닥은')
///
/// 지수 이름이 7개나 되고 받침이 제각각이라(코스피·인도는 받침 없음, 코스닥·나스닥·
/// 중국·유럽·베트남은 있음) 하나로 고정하면 아이가 읽는 문장이 어색해진다.
/// 한글이 아닌 글자로 끝나면 받침 없는 쪽을 쓴다(ETF → "ETF를").
String josa(String word, String withBatchim, String withoutBatchim) {
  if (word.isEmpty) return withoutBatchim;
  final code = word.codeUnitAt(word.length - 1);
  if (code < 0xAC00 || code > 0xD7A3) return withoutBatchim;
  return (code - 0xAC00) % 28 == 0 ? withoutBatchim : withBatchim;
}

/// 모의투자에서 아이가 실제로 사고파는 "상품" 이름.
///
/// 지수(코스피)는 숫자라서 가질 수 없다. 가질 수 있는 건 그 지수를 따라가도록
/// 우리가 만든 ETF뿐이다. "코스피 2주 보유"라고 쓰면 아이가 지수 자체를
/// 소유한다고 오해하므로, 소유·거래를 말하는 자리에서는 항상 이 이름을 쓴다.
/// (지수 값·차트 눈금처럼 지수를 가리키는 자리에서는 원래 이름을 그대로 쓴다)
String etfName(String indexLabel) => '아빠표 $indexLabel ETF';

/// 이자율 등 퍼센트 표기. 불필요한 0을 없앤다. 1.20 -> "1.2", 1.00 -> "1".
String formatPercent(double v) {
  final s = v.toStringAsFixed(2);
  if (!s.contains('.')) return s;
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

final _dateFormat = DateFormat('yyyy.MM.dd (E)', 'ko_KR');
String formatDate(DateTime d) => _dateFormat.format(d);

final _dateShortFormat = DateFormat('MM.dd', 'ko_KR');
String formatDateShort(DateTime d) => _dateShortFormat.format(d);

const weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

String weekdayName(int isoWeekday) => weekdayNames[(isoWeekday - 1).clamp(0, 6)];

String txSubtitle(TransactionEntry t) {
  final parts = <String>[formatDate(t.date)];
  if (t.giver != null && t.giver!.isNotEmpty) parts.add(t.giver!);
  if (t.memo != null && t.memo!.isNotEmpty) parts.add(t.memo!);
  return parts.join(' · ');
}
