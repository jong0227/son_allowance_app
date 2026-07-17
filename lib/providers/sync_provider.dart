import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

final familySyncServiceProvider = Provider<FamilySyncService>((ref) {
  final service = FamilySyncService(ref.watch(databaseProvider));
  // 부모 암호(해시)를 가족 문서로 전파/수신하도록 연결.
  service.readPasscode = () {
    final s = ref.read(settingsProvider);
    if (s.parentPasscodeHash != null && s.parentPasscodeSalt != null) {
      return (s.parentPasscodeHash!, s.parentPasscodeSalt!);
    }
    return null;
  };
  service.onRemotePasscode = (hash, salt) =>
      ref.read(settingsProvider.notifier).adoptParentPasscode(hash, salt);
  ref.onDispose(service.dispose);
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(familySyncServiceProvider).statusStream;
});
