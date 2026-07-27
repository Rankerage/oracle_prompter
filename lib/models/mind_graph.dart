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
  // Conversation
  keyword,
  concept,
  question,
  emotion,
  action,
  location,
  person,
  // Cards & Learning
  card_response,   // 사용자의 카드 응답
  card_learned,    // 학습 완료된 항목
  // System
  setting_change,  // 설정 변경
  log_event,       // 시스템 로그
  preference,      // 취향/선호도
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
  NodeType.keyword: Color(0xFFD4A574),
  NodeType.concept: Color(0xFF8BB8EA),
  NodeType.question: Color(0xFFC9A96E),
  NodeType.emotion: Color(0xFFE8847C),
  NodeType.action: Color(0xFF7CCE8C),
  NodeType.location: Color(0xFFB088D4),
  NodeType.person: Color(0xFF6AC9D4),
  NodeType.card_response: Color(0xFFF0A060),
  NodeType.card_learned: Color(0xFF60D080),
  NodeType.setting_change: Color(0xFF8888CC),
  NodeType.log_event: Color(0xFF888888),
  NodeType.preference: Color(0xFFFFB0C0),
};

/// 엣지 타입별 스타일
const edgeStyles = {
  EdgeType.association: {'dash': false, 'width': 1.5},
  EdgeType.causation: {'dash': false, 'width': 2.5},
  EdgeType.sequence: {'dash': true, 'width': 2.0},
  EdgeType.contrast: {'dash': true, 'width': 2.0},
  EdgeType.elaboration: {'dash': false, 'width': 1.0},
};
