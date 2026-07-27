import 'dart:ui';

/// 마인드그래프의 노드 (단어/개념)
class MindNode {
  final String id;
  final String label;
  final NodeType type;
  double x;
  double y;
  final double radius;
  final double confidence;
  final DateTime timestamp;
  final bool isPredicted;
  final String? linkedAudioPath;

  MindNode({
    required this.id,
    required this.label,
    this.type = NodeType.concept,
    required this.x,
    required this.y,
    this.radius = 40,
    this.confidence = 1.0,
    required this.timestamp,
    this.isPredicted = false,
    this.linkedAudioPath,
  });
}

enum NodeType {
  keyword,   // 핵심 키워드 (크게)
  concept,   // 일반 개념
  question,  // 질문
  emotion,   // 감정
  action,    // 행동/결정
  location,  // 장소
  person,    // 인물
}

/// 마인드그래프의 엣지 (연관 관계)
class MindEdge {
  final String id;
  final String sourceId;
  final String targetId;
  final EdgeType type;
  final String? label;
  final double strength; // 0.0 ~ 1.0
  final bool isPredicted;

  const MindEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.type = EdgeType.association,
    this.label,
    this.strength = 0.5,
    this.isPredicted = false,
  });
}

enum EdgeType {
  association,  // 연상
  causation,    // 인과
  sequence,     // 순서
  contrast,     // 대조
  elaboration,  // 상세화
}

/// 노드 타입별 색상
const nodeColors = {
  NodeType.keyword: Color(0xFFD4A574),   // 골드
  NodeType.concept: Color(0xFF8BB8EA),   // 블루
  NodeType.question: Color(0xFFC9A96E),  // 옐로우
  NodeType.emotion: Color(0xFFE8847C),   // 코랄
  NodeType.action: Color(0xFF7CCE8C),    // 그린
  NodeType.location: Color(0xFFB088D4),  // 퍼플
  NodeType.person: Color(0xFF6AC9D4),    // 시안
};

/// 엣지 타입별 스타일
const edgeStyles = {
  EdgeType.association: {'dash': false, 'width': 1.5},
  EdgeType.causation: {'dash': false, 'width': 2.5},
  EdgeType.sequence: {'dash': true, 'width': 2.0},
  EdgeType.contrast: {'dash': true, 'width': 2.0},
  EdgeType.elaboration: {'dash': false, 'width': 1.0},
};
