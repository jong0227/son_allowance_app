import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';

/// 최초 실행 시: 이 기기의 사용자(아빠/엄마/아들)와 자녀 정보를 입력받는다.
/// - 부모(아빠/엄마): 자녀 정보를 직접 만든다. 이후 설정에서 가족 동기화/부모 암호 설정.
/// - 자녀(아들): 부모에게 받은 가족 코드로 연결해 데이터를 받아온다(지급/승인 권한 없음).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _owner;
  final _nameController = TextEditingController(text: '아들');
  final _amountController = TextEditingController(text: '10000');
  final _familyCodeController = TextEditingController();
  int _payDayOfWeek = DateTime.monday;
  bool _busy = false;

  bool get _isChild => _owner == '아들';

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _familyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('처음 설정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text('이 기기는 누가 사용하나요?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                emptySelectionAllowed: true,
                segments: const [
                  ButtonSegment(value: '아빠', label: Text('아빠')),
                  ButtonSegment(value: '엄마', label: Text('엄마')),
                  ButtonSegment(value: '아들', label: Text('아들')),
                ],
                selected: _owner == null ? const {} : {_owner!},
                onSelectionChanged: (s) => setState(() => _owner = s.first),
              ),
              const SizedBox(height: 32),
              if (_isChild) ...[
                const Text('가족 연결',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('부모님 앱의 설정 > 실시간 자동 동기화에서 발급한 6자리 코드를 입력하면 '
                    '용돈 정보를 함께 볼 수 있어요.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                TextField(
                  controller: _familyCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: '가족 코드 (6자리)', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ] else ...[
                const Text('자녀 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: '기본 주간 용돈(원)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _payDayOfWeek,
                  decoration:
                      const InputDecoration(labelText: '지급 요일', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('월요일')),
                    DropdownMenuItem(value: 2, child: Text('화요일')),
                    DropdownMenuItem(value: 3, child: Text('수요일')),
                    DropdownMenuItem(value: 4, child: Text('목요일')),
                    DropdownMenuItem(value: 5, child: Text('금요일')),
                    DropdownMenuItem(value: 6, child: Text('토요일')),
                    DropdownMenuItem(value: 7, child: Text('일요일')),
                  ],
                  onChanged: (v) => setState(() => _payDayOfWeek = v ?? DateTime.monday),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: (_canSubmit && !_busy) ? _submit : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isChild ? '연결하기' : '시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit {
    if (_owner == null) return false;
    if (_isChild) return _familyCodeController.text.trim().length >= 4;
    return _nameController.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      if (_isChild) {
        // 자녀: 가족 코드로 연결해 부모의 데이터를 받아온다.
        final code = _familyCodeController.text.trim().toUpperCase();
        await ref.read(familySyncServiceProvider).joinFamily(code, '아들');
        await ref.read(settingsProvider.notifier).setFamilyCode(code);
        await ref.read(settingsProvider.notifier).setDeviceOwner('아들');
      } else {
        final db = ref.read(databaseProvider);
        final id = const Uuid().v4();
        final now = DateTime.now();
        await db.upsertChild(ChildrenCompanion.insert(
          id: id,
          name: _nameController.text.trim(),
          weeklyAllowanceDefault: Value(int.tryParse(_amountController.text) ?? 10000),
          payDayOfWeek: Value(_payDayOfWeek),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
        await ref.read(settingsProvider.notifier).setDeviceOwner(_owner!);
        ref.read(selectedChildIdProvider.notifier).state = id;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('연결 실패: $e')));
      }
      return;
    }
    if (mounted) setState(() => _busy = false);
  }
}
