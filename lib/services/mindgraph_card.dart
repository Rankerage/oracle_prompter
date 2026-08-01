import 'dart:math';
import 'package:flutter/material.dart';

/// 🧠 MindGraph Card — 카드 뒷면에 보여줄 마인드그래프
///
/// 사용자가 오늘 소비한 컨텐츠들의 연관성을
/// 노드와 엣지로 시각화. "TikiTaka가 내 머릿속을 정리하고 있구나."
class MindGraphPainter extends CustomPainter {
  final List<_Node> nodes;
  final List<_Edge> edges;

  MindGraphPainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw edges first (behind nodes)
    for (final edge in edges) {
      final paint = Paint()
        ..color = const Color(0xFFD4A574).withAlpha(40)
        ..strokeWidth = edge.strength * 1.5;
      canvas.drawLine(edge.from.pos, edge.to.pos, paint);
    }

    // Draw nodes
    for (final node in nodes) {
      final paint = Paint()
        ..color = _colorForType(node.type)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node.pos, node.radius, paint);

      // Label
      final tp = TextPainter(
        text: TextSpan(text: node.label, style: TextStyle(
            color: Colors.white70, fontSize: 10 - node.radius * 0.3)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);
      tp.paint(canvas, Offset(node.pos.dx - tp.width / 2, node.pos.dy - tp.height / 2));
    }
  }

  Color _colorForType(String type) => switch (type) {
    'news' => const Color(0xFF7CCE8C),
    'learn' => const Color(0xFFB088D4),
    'interest' => const Color(0xFFD4A574),
    _ => const Color(0xFF6AC9D4),
  };

  @override bool shouldRepaint(covariant MindGraphPainter old) => true;
}

class _Node {
  final Offset pos;
  final String label;
  final String type;
  final double radius;
  const _Node({required this.pos, required this.label, required this.type, required this.radius});
}

class _Edge {
  final Offset from, to;
  final double strength;
  const _Edge({required this.from, required this.to, required this.strength});
}

/// 📰 News Flow + MindGraph Integration
class NewsMindGraph {
  final List<String> _consumed = [];
  final Map<String, int> _interests = {};
  final _rng = Random();

  /// Record news consumption
  void consume(String topic, String category) {
    _consumed.add(topic);
    _interests[category] = (_interests[category] ?? 0) + 1;
  }

  /// Record feedback (○=like, ✕=dislike)
  void feedback(String topic, bool liked) {
    if (liked) {
      _interests[topic] = (_interests[topic] ?? 0) + 2;
    }
  }

  /// Generate graph for today's consumption
  Widget buildGraph() {
    final nodes = <_Node>[];
    final edges = <_Edge>[];

    // Center: "오늘"
    final center = const Offset(150, 150);
    nodes.add(_Node(pos: center, label: '오늘', type: 'interest', radius: 18));

    // Interest nodes around center
    final topInterests = _interests.entries
        .where((e) => e.value > 0)
        .take(5)
        .toList();

    for (int i = 0; i < topInterests.length; i++) {
      final angle = (i / topInterests.length) * 2 * pi - pi / 2;
      final dist = 70.0 + _rng.nextDouble() * 40;
      final pos = Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist,
      );
      final entry = topInterests[i];
      nodes.add(_Node(
        pos: pos, label: entry.key,
        type: 'interest',
        radius: 10 + min(entry.value * 2, 8).toDouble(),
      ));
      edges.add(_Edge(from: center, to: pos, strength: entry.value / 10));
    }

    // Recent consumed topics
    final recent = _consumed.reversed.take(3).toList();
    for (int i = 0; i < recent.length; i++) {
      final angle = pi + (i / 3) * pi;
      final dist = 55.0;
      final pos = Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist,
      );
      nodes.add(_Node(pos: pos, label: recent[i].length > 6
          ? '${recent[i].substring(0, 6)}...' : recent[i],
        type: 'news', radius: 8));
      edges.add(_Edge(from: center, to: pos, strength: 0.5));
    }

    return SizedBox(
      width: 300, height: 300,
      child: CustomPaint(
        painter: MindGraphPainter(nodes: nodes, edges: edges),
      ),
    );
  }

  /// Generate card back text with graph summary
  String summary() {
    if (_consumed.isEmpty) return '아직 소비한 컨텐츠가 없어요.';
    final top = _interests.entries
        .where((e) => e.value > 0)
        .take(3)
        .map((e) => e.key)
        .join(', ');
    return '오늘 ${_consumed.length}개의 컨텐츠를 보셨어요.\n'
        '관심 주제: $top\n\n'
        '아래 그래프는 오늘의 연결이에요.';
  }
}
