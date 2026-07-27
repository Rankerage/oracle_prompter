import 'dart:math';
import 'dart:ui';
import '../../models/mind_graph.dart';

/// D3-force 스타일 Force-Directed Graph 레이아웃 엔진
///
/// 오픈소스 참조: d3-force (Mike Bostock, BSD-3)
/// Dart 포트: d3-force-flutter (MathGaps)
///
/// 노드 간 척력(repulsion), 엣지 인력(attraction),
/// 중앙 중력(gravity)을 시뮬레이션하여 그래프 레이아웃 계산
class ForceSimulation {
  final List<_ForceNode> _nodes = [];
  final List<_ForceLink> _links = [];

  // 시뮬레이션 파라미터
  double alpha = 1.0; // 에너지 (0이 되면 수렴)
  double alphaMin = 0.001;
  double alphaDecay = 0.02;
  double alphaTarget = 0;
  double velocityDecay = 0.4;

  // 힘 강도
  double repulsionStrength = -400.0; // 노드 간 척력
  double attractionStrength = 0.05; // 엣지 인력
  double gravityStrength = 0.08; // 중앙 중력
  double linkDistance = 80.0;

  final Random _random = Random();

  void addNode(MindNode node) {
    _nodes.add(_ForceNode(
      id: node.id,
      x: node.x,
      y: node.y,
    ));
  }

  void addEdge(MindEdge edge) {
    _links.add(_ForceLink(
      sourceId: edge.sourceId,
      targetId: edge.targetId,
      strength: edge.strength,
    ));
  }

  /// 시뮬레이션 1틱 실행
  void tick() {
    alpha += (alphaTarget - alpha) * alphaDecay;
    if (alpha < alphaMin) return;

    _applyRepulsion();
    _applyAttraction();
    _applyGravity();
    _applyVelocity();

    if (alpha < alphaMin) alpha = 0;
  }

  /// 노드 간 척력 (쿨롱의 법칙)
  void _applyRepulsion() {
    const theta2 = 0.81; // Barnes-Hut 근사 임계값
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        final dx = _nodes[j].x - _nodes[i].x;
        final dy = _nodes[j].y - _nodes[i].y;
        var dist = (dx * dx + dy * dy).abs();
        if (dist < 1) dist = 1;

        final force = (repulsionStrength * alpha) / dist;
        final fx = dx * force;
        final fy = dy * force;

        _nodes[i].vx -= fx;
        _nodes[i].vy -= fy;
        _nodes[j].vx += fx;
        _nodes[j].vy += fy;
      }
    }
  }

  /// 엣지 인력 (스프링 힘)
  void _applyAttraction() {
    for (final link in _links) {
      final source = _nodes.where((n) => n.id == link.sourceId).firstOrNull;
      final target = _nodes.where((n) => n.id == link.targetId).firstOrNull;
      if (source == null || target == null) continue;

      final dx = target.x - source.x;
      final dy = target.y - source.y;
      final dist = max(1, (dx * dx + dy * dy).abs());
      final displacement = (dist - linkDistance) / dist * attractionStrength * link.strength * alpha;

      final fx = dx * displacement;
      final fy = dy * displacement;

      source.vx += fx;
      source.vy += fy;
      target.vx -= fx;
      target.vy -= fy;
    }
  }

  /// 중앙 중력
  void _applyGravity() {
    const centerX = 300.0;
    const centerY = 300.0;
    for (final node in _nodes) {
      final dx = centerX - node.x;
      final dy = centerY - node.y;
      node.vx += dx * gravityStrength * alpha;
      node.vy += dy * gravityStrength * alpha;
    }
  }

  /// 속도 적용
  void _applyVelocity() {
    for (final node in _nodes) {
      node.vx *= velocityDecay;
      node.vy *= velocityDecay;
      node.x += node.vx;
      node.y += node.vy;

      // 바운더리 클램프
      node.x = node.x.clamp(20, 580);
      node.y = node.y.clamp(20, 580);
    }
  }

  /// 수렴된 위치 가져오기
  List<Offset> get positions => _nodes.map((n) => Offset(n.x, n.y)).toList();

  /// 노드 개수
  int get nodeCount => _nodes.length;

  /// 특정 노드 위치
  Offset positionOf(String id) {
    final node = _nodes.where((n) => n.id == id).firstOrNull;
    return node != null ? Offset(node.x, node.y) : Offset.zero;
  }

  /// 시뮬레이션 완전 수렴까지 실행
  void settle({int maxTicks = 300}) {
    for (int i = 0; i < maxTicks; i++) {
      alpha = max(alpha, 0.3); // 계속 에너지 공급
      tick();
      if (alpha < alphaMin) break;
    }
  }

  /// 완전 초기화
  void reset() {
    _nodes.clear();
    _links.clear();
    alpha = 1.0;
  }
}

class _ForceNode {
  final String id;
  double x, y;
  double vx = 0, vy = 0;

  _ForceNode({required this.id, required this.x, required this.y});
}

class _ForceLink {
  final String sourceId;
  final String targetId;
  final double strength;

  _ForceLink({
    required this.sourceId,
    required this.targetId,
    this.strength = 0.5,
  });
}
