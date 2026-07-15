import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 용돈 지급일 리마인더 + 이체 권장 알림을 담당.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {
      // 기본 로케이션으로 폴백
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// 매주 [isoWeekday](1=월..7=일) 오전 9시에 용돈 지급 리마인더를 반복 예약.
  Future<void> scheduleWeeklyAllowanceReminder({
    required String childName,
    required int isoWeekday,
    int hour = 9,
  }) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (scheduled.weekday != isoWeekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      1001,
      '용돈 지급일이에요',
      '$childName에게 이번 주 용돈을 줄 차례입니다.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'allowance_reminder',
          '용돈 지급 리마인더',
          channelDescription: '주간 용돈 지급일 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelAllowanceReminder() => _plugin.cancel(1001);

  /// 매주 일요일 저녁 주간 리포트 리마인더.
  Future<void> scheduleWeeklyReport({int isoWeekday = 7, int hour = 19}) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (scheduled.weekday != isoWeekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      3001,
      '이번 주 용돈 리포트',
      '이번 주 용돈과 지출 내역을 확인해보세요.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_report',
          '주간 리포트',
          channelDescription: '매주 용돈/지출 요약 리마인더',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelWeeklyReport() => _plugin.cancel(3001);

  /// 잔액이 임계금액을 넘으면 즉시 표시하는 이체 권장 알림.
  Future<void> showTransferRecommended({
    required String childName,
    required int balance,
    required int threshold,
  }) async {
    await init();
    await _plugin.show(
      2001,
      '주식계좌 이체를 고려해보세요',
      '$childName의 잔액이 ${_won(balance)}원으로 기준(${_won(threshold)}원)을 넘었습니다.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'transfer_recommend',
          '이체 권장 알림',
          channelDescription: '잔액이 임계금액을 넘으면 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  String _won(int v) => v.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}
