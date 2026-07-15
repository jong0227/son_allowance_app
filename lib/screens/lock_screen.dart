import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/settings_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  String? _error;
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return;
      final ok = await _localAuth.authenticate(
        localizedReason: '앱 잠금을 해제하려면 인증해주세요',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (ok) widget.onUnlocked();
    } catch (_) {
      // 생체인증 실패/미지원 시 PIN 입력으로 진행
    }
  }

  void _submitPin() {
    final ok = ref.read(settingsProvider.notifier).verifyPin(_pinController.text);
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() => _error = 'PIN이 일치하지 않습니다');
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                const Text('PIN을 입력하세요', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    counterText: '',
                    errorText: _error,
                  ),
                  onSubmitted: (_) => _submitPin(),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _submitPin, child: const Text('확인')),
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('생체인증으로 잠금 해제'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
