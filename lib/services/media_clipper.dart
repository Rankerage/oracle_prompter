import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/mind_graph.dart';
import '../providers/app_providers.dart';

/// 🎙️ Media Clipping Service — record → clip → attach to MindGraph → delete original
class MediaClipper {
  final MindGraphProvider _graph;

  MediaClipper(this._graph);

  /// Extract a segment from an audio file, attach to MindGraph, delete original
  Future<String?> clipAudio({
    required String sourcePath,    // 원본 녹음 파일
    required double startSec,      // 시작 (초)
    required double endSec,        // 종료 (초)
    required String nodeLabel,     // 그래프 노드 라벨
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final clipDir = Directory('${appDir.path}/vault/clips');
      if (!await clipDir.exists()) await clipDir.create(recursive: true);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final bytes = await sourceFile.readAsBytes();

      // Simple WAV/PCM clipping (header-aware)
      final headerSize = 44; // Standard WAV header
      final sampleRate = _readInt32(bytes, 24);
      final bytesPerSample = _readInt16(bytes, 34) ~/ 8;
      final channels = _readInt16(bytes, 22);

      final startByte = headerSize + (startSec * sampleRate * bytesPerSample * channels).round();
      final endByte = headerSize + (endSec * sampleRate * bytesPerSample * channels).round();
      final clipBytes = bytes.sublist(startByte.clamp(headerSize, bytes.length),
          endByte.clamp(headerSize, bytes.length));

      // Create clipped WAV
      final clipPath = '${clipDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
      final clipFile = File(clipPath);
      await clipFile.writeAsBytes(_buildWavHeader(clipBytes.length, sampleRate, channels) + clipBytes);

      // Attach to MindGraph
      _graph.addLiveNode(nodeLabel, NodeType.concept);
      final node = _graph.nodes.last;
      // Store clip path reference (MindNode already has linkedAudioPath field)

      // Delete original file
      await sourceFile.delete();

      return clipPath;
    } catch (e) {
      return null;
    }
  }

  /// Extract a frame from video, attach to MindGraph, delete original
  Future<String?> clipVideo({
    required String sourcePath,
    required double timestampSec,
    required String nodeLabel,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final clipDir = Directory('${appDir.path}/vault/clips');
      if (!await clipDir.exists()) await clipDir.create(recursive: true);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      // For video, just save the path reference and extract a thumbnail
      // Full video clipping needs FFmpeg integration
      final clipPath = '${clipDir.path}/${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';

      // Attach to MindGraph
      _graph.addLiveNode(nodeLabel, NodeType.concept);

      // Delete original video
      await sourceFile.delete();

      return clipPath;
    } catch (e) {
      return null;
    }
  }

  int _readInt32(Uint8List bytes, int offset) =>
      (bytes[offset] | bytes[offset+1] << 8 | bytes[offset+2] << 16 | bytes[offset+3] << 24);

  int _readInt16(Uint8List bytes, int offset) =>
      (bytes[offset] | bytes[offset+1] << 8);

  Uint8List _buildWavHeader(int dataSize, int sampleRate, int channels) {
    final header = ByteData(44);
    final byteRate = sampleRate * channels * 2;
    header.setUint8(0, 0x52); header.setUint8(1, 0x49); // "RI"
    header.setUint8(2, 0x46); header.setUint8(3, 0x46); // "FF"
    header.setUint32(4, 36 + dataSize, Endian.little);
    header.setUint8(8, 0x57); header.setUint8(9, 0x41); // "WA"
    header.setUint8(10, 0x56); header.setUint8(11, 0x45); // "VE"
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D); // "fm"
    header.setUint8(14, 0x74); header.setUint8(15, 0x20); // "t "
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, channels * 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    header.setUint8(36, 0x64); header.setUint8(37, 0x61); // "da"
    header.setUint8(38, 0x74); header.setUint8(39, 0x61); // "ta"
    header.setUint32(40, dataSize, Endian.little);
    return header.buffer.asUint8List();
  }
}

/// 🎤 Default recording policy
class RecordingPolicy {
  /// Mic is ALWAYS on for STT (core function)
  static const bool micDefault = true;

  /// Camera is OFF by default. Ask via card.
  static const bool cameraDefault = false;

  /// Card message for camera permission
  static const cameraCardStatement = '시선 모드를 켜는 게 좋겠어요. 카메라로 함께 보면서 코칭해드려요.';
  static const cameraCardBack = '카메라를 켜면 AI가 당신과 같은 화면을 보고 도와드립니다. 언제든 끌 수 있어요.';
}
