import 'package:flutter/material.dart';
import '../../models/mind_graph.dart';

/// 마인드그래프 렌더링 — 노드(원) + 엣지(선) + 예측 노드(점선)
class MindGraphPainter extends CustomPainter {
  final List<MindNode> nodes;
  final List<MindEdge> edges;
  final bool showPredictions;

  MindGraphPainter({
    required this.nodes,
    required this.edges,
    this.showPredictions = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 그리드
    _drawGrid(canvas, size);

    // 엣지 먼저 그림 (노드 아래에)
    for (final edge in edges) {
      if (!showPredictions && edge.isPredicted) continue;
      _drawEdge(canvas, edge);
    }

    // 노드 그림
    for (final node in nodes) {
      if (!showPredictions && node.isPredicted) continue;
      _drawNode(canvas, node);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 0.5;
    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawEdge(Canvas canvas, MindEdge edge) {
    final source = nodes.where((n) => n.id == edge.sourceId).firstOrNull;
    final target = nodes.where((n) => n.id == edge.targetId).firstOrNull;
    if (source == null || target == null) return;

    final style = edgeStyles[edge.type]!;
    final paint = Paint()
      ..color = edge.isPredicted
          ? const Color(0xFFC9A96E).withAlpha(80)
          : Colors.white.withAlpha(60 + (edge.strength * 60).round())
      ..strokeWidth = (style['width'] as double) * (0.5 + edge.strength * 0.5);

    if (style['dash'] == true) {
      _drawDashedLine(canvas, Offset(source.x, source.y), Offset(target.x, target.y), paint);
    } else {
      canvas.drawLine(Offset(source.x, source.y), Offset(target.x, target.y), paint);
    }

    // 엣지 라벨
    if (edge.label != null) {
      final midX = (source.x + target.x) / 2;
      final midY = (source.y + target.y) / 2;
      final tp = TextPainter(
        text: TextSpan(text: edge.label, style: TextStyle(
          color: Colors.white.withAlpha(100), fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(midX - tp.width / 2, midY - tp.height / 2));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = (dx * dx + dy * dy).abs();
    if (distance == 0) return;
    final len = distance > 0 ? (1 / distance) : 0.0;
    final dashLength = 8.0;
    final gapLength = 4.0;
    double drawn = 0;
    while (drawn < distance) {
      final t1 = drawn * len;
      drawn = (drawn + dashLength).clamp(0, distance);
      final t2 = drawn * len;
      canvas.drawLine(
        Offset(start.dx + dx * t1, start.dy + dy * t1),
        Offset(start.dx + dx * t2, start.dy + dy * t2),
        paint,
      );
      drawn += gapLength;
    }
  }

  void _drawNode(Canvas canvas, MindNode node) {
    final color = nodeColors[node.type]!;
    final alpha = node.isPredicted ? 120 : 220;

    // 그림자 (활성 노드만)
    if (!node.isPredicted) {
      final shadowPaint = Paint()
        ..color = color.withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(node.x, node.y), node.radius + 6, shadowPaint);
    }

    // 외곽 원
    final outerPaint = Paint()
      ..color = node.isPredicted
          ? color.withAlpha(alpha)
          : const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(node.x, node.y), node.radius, outerPaint);

    // 외곽선
    final borderPaint = Paint()
      ..color = color.withAlpha(node.isPredicted ? alpha : 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = node.isPredicted ? 1.0 : 2.5;
    canvas.drawCircle(Offset(node.x, node.y), node.radius, borderPaint);

    // 예측 노드 점선 효과
    if (node.isPredicted) {
      final dashPaint = Paint()
        ..color = color.withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      _drawDashedCircle(canvas, Offset(node.x, node.y), node.radius + 2, dashPaint);
    }

    // 신뢰도 인디케이터 (예측 노드)
    if (node.confidence < 1.0) {
      final confPaint = Paint()
        ..color = color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(node.x, node.y), radius: node.radius - 4),
        -1.57, node.confidence * 6.28, false, confPaint,
      );
    }

    // 노드 라벨
    final textStyle = TextStyle(
      color: node.isPredicted ? color.withAlpha(180) : Colors.white,
      fontSize: node.type == NodeType.keyword ? 13 : 11,
      fontWeight: node.type == NodeType.keyword ? FontWeight.bold : FontWeight.w500,
    );
    final tp = TextPainter(
      text: TextSpan(text: node.label, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: node.radius * 2.5);

    tp.paint(canvas, Offset(
      node.x - tp.width / 2,
      node.y - tp.height / 2,
    ));

    // 타입 아이콘 (작은 원 위에)
    if (node.type == NodeType.emotion) {
      _drawEmotionIcon(canvas, node, color);
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const segments = 24;
    for (int i = 0; i < segments; i += 2) {
      final startAngle = (i / segments) * 6.28;
      final endAngle = ((i + 1) / segments) * 6.28;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, endAngle - startAngle, false, paint,
      );
    }
  }

  void _drawEmotionIcon(Canvas canvas, MindNode node, Color color) {
    // 작은 이모지 표시
    final tp = TextPainter(
      text: const TextSpan(text: '💭', style: TextStyle(fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(node.x - tp.width / 2, node.y - node.radius - 16));
  }

  @override
  bool shouldRepaint(covariant MindGraphPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.edges != edges
        || oldDelegate.showPredictions != showPredictions;
  }
}
