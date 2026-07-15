import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/app_database.dart';
import 'export_import_service.dart';

/// Export(공유용)와는 별개로, 기기 분실/앱 삭제에 대비해 내부 저장소에
/// 전체 데이터의 자동 스냅샷을 주기적으로 남긴다. 최근 [_maxSnapshots]개만 보관.
class BackupService {
  const BackupService();

  static const _maxSnapshots = 10;
  static const _minIntervalHours = 12;
  static const _exportService = ExportImportService();

  Future<void> autoBackupIfNeeded(AppDatabase db, {required String editedBy}) async {
    final dir = await _backupDir();
    final files = dir.listSync().whereType<File>().toList()
      ..sort((a, b) => b.path.compareTo(a.path));

    if (files.isNotEmpty) {
      final lastModified = await files.first.lastModified();
      if (DateTime.now().difference(lastModified).inHours < _minIntervalHours) {
        return;
      }
    }

    final data = await _exportService.serializeAll(db, editedBy);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/snapshot_$ts.json');
    await file.writeAsString(jsonEncode(data));

    if (files.length >= _maxSnapshots) {
      for (final f in files.skip(_maxSnapshots - 1)) {
        await f.delete();
      }
    }
  }

  Future<List<File>> listSnapshots() async {
    final dir = await _backupDir();
    final files = dir.listSync().whereType<File>().toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  Future<Directory> _backupDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/auto_backups');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
