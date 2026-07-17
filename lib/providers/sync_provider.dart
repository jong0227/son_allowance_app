import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import 'database_provider.dart';

final familySyncServiceProvider = Provider<FamilySyncService>((ref) {
  final service = FamilySyncService(ref.watch(databaseProvider));
  ref.onDispose(service.dispose);
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(familySyncServiceProvider).statusStream;
});
