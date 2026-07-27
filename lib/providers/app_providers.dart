import 'package:flutter/material.dart';
import '../models/mind_graph.dart';
import '../models/journal_entry.dart';
import '../widgets/mind_graph/force_simulation.dart';

/// 마인드그래프 상태 관리
class MindGraphProvider extends ChangeNotifier {
  final ForceSimulation _simulation = ForceSimulation();
  List<MindNode> _nodes = [];
  List<MindEdge> _edges = [];
  bool _isLive = true;
  bool _showPredictions = true;
  String? _activeGraphId;
  bool _isSimulating = false;

  List<MindNode> get nodes => List.unmodifiable(_nodes);
  List<MindEdge> get edges => List.unmodifiable(_edges);
  bool get isLive => _isLive;
  bool get showPredictions => _showPredictions;
  String? get activeGraphId => _activeGraphId;
  bool get isSimulating => _isSimulating;

  /// 실시간 노드 추가 (음성인식에서 들어오는 단어)
  void addLiveNode(String word, NodeType type) {
    // 임의 초기 위치 → 시뮬레이션이 최적 위치로 이동시킴
    final node = MindNode(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      label: word,
      type: type,
      x: 280 + (_nodes.length * 15.0) % 120,
      y: 280 + (_nodes.length * 25.0) % 120,
      timestamp: DateTime.now(),
    );
    _nodes.add(node);
    _simulation.addNode(node);

    // 이전 노드와 연결
    if (_nodes.length >= 2) {
      final edge = MindEdge(
        id: 'e_${DateTime.now().millisecondsSinceEpoch}',
        sourceId: _nodes[_nodes.length - 2].id,
        targetId: node.id,
        type: EdgeType.association,
        strength: 0.7,
      );
      _edges.add(edge);
      _simulation.addEdge(edge);
    }

    // 시뮬레이션 한 틱 실행으로 위치 재조정
    _simulation.alpha = 0.5;
    for (int i = 0; i < 5; i++) {
      _simulation.tick();
    }
    _syncPositions();
    notifyListeners();
  }

  /// 시뮬레이션 틱 (애니메이션 프레임마다 호출)
  void simulationTick() {
    if (_simulation.alpha < _simulation.alphaMin) {
      _isSimulating = false;
      return;
    }
    _isSimulating = true;
    _simulation.tick();
    _syncPositions();
    notifyListeners();
  }

  /// 시뮬레이션 수렴시키기
  void settleSimulation() {
    _simulation.settle(maxTicks: 200);
    _syncPositions();
    _isSimulating = false;
    notifyListeners();
  }

  /// 시뮬레이션 위치 → 노드 좌표 동기화
  void _syncPositions() {
    final positions = _simulation.positions;
    for (int i = 0; i < _nodes.length && i < positions.length; i++) {
      _nodes[i].x = positions[i].dx;
      _nodes[i].y = positions[i].dy;
    }
  }

  /// 예측 노드 추가
  void addPredictedNode(String word, String connectedToId) {
    _nodes.add(MindNode(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      label: word,
      type: NodeType.concept,
      x: 100 + (_nodes.length * 50.0) % 400,
      y: 100 + (_nodes.length * 60.0) % 500,
      confidence: 0.5,
      timestamp: DateTime.now(),
      isPredicted: true,
    ));
    _edges.add(MindEdge(
      id: 'pe_${DateTime.now().millisecondsSinceEpoch}',
      sourceId: connectedToId,
      targetId: _nodes.last.id,
      type: EdgeType.association,
      isPredicted: true,
    ));
    notifyListeners();
  }

  void togglePredictions() {
    _showPredictions = !_showPredictions;
    notifyListeners();
  }

  void clearGraph() {
    _nodes = [];
    _edges = [];
    _simulation.reset();
    notifyListeners();
  }
}

/// 저널(일기장) 상태 관리
class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  List<Session> _sessions = [];
  String? _activeSessionId;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  List<Session> get sessions => List.unmodifiable(_sessions);
  String? get activeSessionId => _activeSessionId;

  void addEntry(JournalEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }

  void createSession(String title) {
    final session = Session(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      isActive: true,
    );
    _sessions.insert(0, session);
    _activeSessionId = session.id;
    notifyListeners();
  }

  void switchSession(String sessionId) {
    _activeSessionId = sessionId;
    notifyListeners();
  }

  void endSession() {
    _activeSessionId = null;
    notifyListeners();
  }
}
