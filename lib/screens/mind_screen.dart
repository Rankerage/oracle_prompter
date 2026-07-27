import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/oracle_provider.dart';
import '../providers/app_providers.dart';
import '../models/mind_graph.dart';
import '../widgets/mind_graph/mind_graph_painter.dart';

/// 🧠 마인드 탭 — 실시간 마인드그래프 시각화
class MindScreen extends StatefulWidget {
  const MindScreen({super.key});

  @override
  State<MindScreen> createState() => _MindScreenState();
}

class _MindScreenState extends State<MindScreen> {
  // 시뮬레이션: 실시간으로 노드 추가
  final _demoWords = [
    '오늘', '회의', '프로젝트', '일정', '팀', '아이디어',
    '문제', '해결', '방법', '내일', '준비', '발표',
  ];
  int _wordIndex = 0;
  final _types = NodeType.values;

  @override
  void initState() {
    super.initState();
    // 데모: 2초마다 새 노드 추가
    Future.delayed(const Duration(milliseconds: 500), _addDemoNode);
  }

  void _addDemoNode() {
    if (!mounted) return;
    final graph = context.read<MindGraphProvider>();
    if (graph.nodes.length < 12) {
      graph.addLiveNode(
        _demoWords[_wordIndex % _demoWords.length],
        _types[Random().nextInt(_types.length)],
      );
      _wordIndex++;
    }
    Future.delayed(const Duration(seconds: 2), _addDemoNode);
  }

  @override
  Widget build(BuildContext context) {
    final graph = context.watch<MindGraphProvider>();
    final oracle = context.watch<OracleProvider>();

    return Column(
      children: [
        // 상단: 모드 + 예측 토글
        _buildTopBar(graph, oracle),
        // 중앙: 마인드그래프 캔버스
        Expanded(
          child: graph.nodes.isEmpty
              ? _buildEmptyState()
              : InteractiveViewer(
                  minScale: 0.3,
                  maxScale: 3.0,
                  child: SizedBox(
                    width: 600,
                    height: 600,
                    child: CustomPaint(
                      painter: MindGraphPainter(
                        nodes: graph.nodes,
                        edges: graph.edges,
                        showPredictions: graph.showPredictions,
                      ),
                    ),
                  ),
                ),
        ),
        // 하단: 실시간 코칭 피드
        _buildCoachingFeed(oracle),
      ],
    );
  }

  Widget _buildTopBar(MindGraphProvider graph, OracleProvider oracle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // 모드 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(oracle.currentMode.label,
              style: const TextStyle(color: Color(0xFFD4A574), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          // 예측 토글
          GestureDetector(
            onTap: () => graph.togglePredictions(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: graph.showPredictions
                    ? const Color(0xFFC9A96E).withAlpha(25)
                    : Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: graph.showPredictions
                    ? const Color(0xFFC9A96E).withAlpha(100)
                    : Colors.white.withAlpha(15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 14,
                    color: graph.showPredictions ? const Color(0xFFC9A96E) : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('예측',
                    style: TextStyle(
                      color: graph.showPredictions ? const Color(0xFFC9A96E) : Colors.grey.shade600,
                      fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 클리어
          GestureDetector(
            onTap: () => graph.clearGraph(),
            child: Icon(Icons.refresh, color: Colors.grey.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bubble_chart, size: 64, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text('대화를 시작하면\n마인드그래프가 실시간으로 그려집니다',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCoachingFeed(OracleProvider oracle) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD4A574), Color(0xFFC9A96E)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(child: Text('O.P', style: TextStyle(
                color: Color(0xFF0A0A0A), fontWeight: FontWeight.w900, fontSize: 9))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              oracle.lastCoachingTip ?? '대화 중입니다...',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontStyle: FontStyle.italic),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.headphones, color: const Color(0xFFD4A574).withAlpha(120), size: 16),
        ],
      ),
    );
  }
}
