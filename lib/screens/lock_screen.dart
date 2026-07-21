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

  /// [manual]이면(버튼으로 직접 눌렀으면) 실패 이유를 스낵바로 보여준다.
  /// 자동 시도(화면 진입 시)는 조용히 실패하고 PIN 입력으로 넘어간다.
  Future<void> _tryBiometric({bool manual = false}) async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = supported && await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        if (manual && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('이 기기에서 생체인증을 쓸 수 없어요. 기기 설정에서 지문/얼굴을 등록해주세요.')));
        }
        return;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: '앱 잠금을 해제하려면 인증해주세요',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (ok) widget.onUnlocked();
    } catch (e) {
      if (manual && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('생체인증 실패: $e')));
      }
      // 자동 시도 실패 시엔 조용히 PIN 입력으로 진행
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
                  onPressed: () => _tryBiometric(manual: true),
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
