import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Windows: not available
// import 'package:file_picker/file_picker.dart';    // Windows: not available
import '../widgets/conversation_card.dart';

/// 📎 Media Attach — ▲ 질문에 이미지·음성·파일 첨부
///
/// 삼각형 누르면 하단에 첨부바 표시.
class MediaAttach {
  static final _picker = ImagePicker();

  /// Show attachment bar under card
  static void showBar(BuildContext ctx, void Function(MediaFile file) onAttached) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('무엇을 첨부할까요?',
              style: TextStyle(color: Color(0xFFD4A574), fontSize: 16)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _attachBtn(ctx, Icons.camera_alt, '카메라', Colors.blue,
                () => _takePhoto(ctx, onAttached)),
            _attachBtn(ctx, Icons.photo_library, '사진', Colors.green,
                () => _pickImage(ctx, onAttached)),
            _attachBtn(ctx, Icons.mic, '음성', Colors.red,
                () => _recordVoice(ctx, onAttached)),
            _attachBtn(ctx, Icons.attach_file, '파일', Colors.orange,
                () => _pickFile(ctx, onAttached)),
          ]),
        ],
      )),
    );
  }

  static Widget _attachBtn(BuildContext ctx, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(onTap: () { Navigator.pop(ctx); onTap(); },
      child: Column(children: [
        Container(width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: color.withAlpha(30), border: Border.all(color: color.withAlpha(60))),
          child: Icon(icon, color: color, size: 26)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ]));
  }

  static Future<void> _takePhoto(BuildContext ctx, void Function(MediaFile) cb) async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img != null) cb(MediaFile(path: img.path, type: MediaType.image));
  }

  static Future<void> _pickImage(BuildContext ctx, void Function(MediaFile) cb) async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) cb(MediaFile(path: img.path, type: MediaType.image));
  }

  static Future<void> _recordVoice(BuildContext ctx, void Function(MediaFile) cb) async {
    // Show recording UI, then return file
    // Simplified: prompts user to describe what they'd record
    showCard(ctx, type: CardType.askMe,
      statement: '음성을 입력해주세요.',
      backAnswer: '지금은 텍스트로 대신 받을게요.\n음성 녹음은 곧 지원됩니다.',
      pos: '○', neg: '✕');
  }

  static Future<void> _pickFile(BuildContext ctx, void Function(MediaFile) cb) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      cb(MediaFile(path: result.files.first.path!, type: MediaType.file));
    }
  }
}

enum MediaType { image, audio, file }

class MediaFile {
  final String path;
  final MediaType type;
  const MediaFile({required this.path, required this.type});
}
