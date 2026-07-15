import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// 갤러리에서 고른 이미지를 원형으로 크롭하는 전용 화면.
/// 완료 시 크롭된 PNG 바이트를 Navigator.pop 으로 반환한다.
class AvatarCropScreen extends StatefulWidget {
  final Uint8List imageData;
  const AvatarCropScreen({super.key, required this.imageData});

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('사진 위치 조정', style: TextStyle(color: Colors.white)),
        actions: [
          if (_cropping)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: () {
                setState(() => _cropping = true);
                _controller.crop();
              },
              child: const Text('완료',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Crop(
        image: widget.imageData,
        controller: _controller,
        aspectRatio: 1,
        withCircleUi: true,
        baseColor: Colors.black,
        maskColor: Colors.black.withValues(alpha: 0.6),
        onCropped: (cropped) {
          Navigator.of(context).pop(cropped);
        },
      ),
    );
  }
}
