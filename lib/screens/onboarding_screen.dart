import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';

/// 최초 실행 시: 이 기기의 사용자(아빠/엄마)와 자녀 정보를 입력받는다.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _owner;
  final _nameController = TextEditingController(text: '아들');
  final _amountController = TextEditingController(text: '10000');
  int _payDayOfWeek = DateTime.monday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('처음 설정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text('이 기기는 누가 사용하나요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                emptySelectionAllowed: true,
                segments: const [
                  ButtonSegment(value: '아빠', label: Text('아빠')),
                  ButtonSegment(value: '엄마', label: Text('엄마')),
                ],
                selected: _owner == null ? const {} : {_owner!},
                onSelectionChanged: (s) => setState(() => _owner = s.first),
              ),
              const SizedBox(height: 32),
              const Text('자녀 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '기본 주간 용돈(원)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _payDayOfWeek,
                decoration: const InputDecoration(labelText: '지급 요일', border: OutlineInputBorder()),
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
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit => _owner != null && _nameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
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
}
