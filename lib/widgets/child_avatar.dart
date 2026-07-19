import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/avatar_crop_screen.dart';

/// 자녀 프로필 원형 썸네일. 탭하면 갤러리에서 사진을 골라 원형으로 크롭 후 저장한다.
class ChildAvatar extends ConsumerWidget {
  final Child child;
  final double size;
  final bool editable;

  const ChildAvatar({
    super.key,
    required this.child,
    this.size = 40,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = Theme.of(context).colorScheme;
    final hasPhoto = child.avatarPath != null && File(child.avatarPath!).existsSync();

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.primary.withValues(alpha: 0.14),
        border: Border.all(color: palette.outline, width: 1),
        image: hasPhoto
            ? DecorationImage(image: FileImage(File(child.avatarPath!)), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : Text(
              child.name.isNotEmpty ? child.name.characters.first : '?',
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
                color: palette.primary,
              ),
            ),
    );

    // 자녀 모드에선 사진을 바꿀 수 없다. 아바타 저장은 children 테이블을 건드리는
    // 유일한 자녀측 쓰기 경로라, 동기화 시 아이 기기의 오래된 값(기본 용돈/지급 요일 등)이
    // 부모가 방금 바꾼 설정을 덮어써 버리는 문제가 있었다.
    if (!editable || ref.watch(settingsProvider).isChild) return avatar;

    return GestureDetector(
      onTap: () => _pickAndCrop(context, ref),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.34,
              height: size * 0.34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
              ),
              child: Icon(Icons.camera_alt, size: size * 0.18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndCrop(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!context.mounted) return;

    final cropped = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => AvatarCropScreen(imageData: bytes)),
    );
    if (cropped == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${dir.path}/avatars');
    if (!await avatarsDir.exists()) await avatarsDir.create(recursive: true);

    // 파일명에 타임스탬프를 넣어 이미지 캐시가 갱신되도록 함.
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File('${avatarsDir.path}/${child.id}_$ts.png');
    await file.writeAsBytes(cropped as List<int>);

    // 이전 아바타 파일 정리
    if (child.avatarPath != null) {
      final old = File(child.avatarPath!);
      if (await old.exists()) {
        await old.delete().catchError((_) => old);
      }
    }

    await ref.read(databaseProvider).updateChildAvatar(child.id, file.path);
  }
}
