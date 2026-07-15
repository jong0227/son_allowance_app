import 'package:intl/intl.dart';
import '../data/app_database.dart';

final _krwFormat = NumberFormat.decimalPattern('ko_KR');

String formatWon(int amount) => '${_krwFormat.format(amount)}원';

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
